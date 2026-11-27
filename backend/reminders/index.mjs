/**
 * Pengirim pengingat imunisasi H-7/H-1 lewat FCM HTTP v1.
 *
 * Dijalankan oleh GitHub Actions (cron harian) — **bukan** Cloud Functions /
 * Cloud Scheduler, sehingga tetap di Spark/free tier.
 *
 * Alur:
 * 1. Iterasi `users/{uid}/babies/{babyId}/vaccineSchedules` berstatus BELUM.
 * 2. Hitung tanggal pengingat H-7 dan H-1 relatif terhadap `tanggalTarget`
 *    (zona waktu Asia/Jakarta).
 * 3. Bila jatuh tempo hari ini dan flag `reminderH7Sent` / `reminderH1Sent`
 *    belum `true`, ambil token dari `users/{uid}/devices/*` yang
 *    `notificationsEnabled != false`.
 * 4. Kirim lewat `sendEachForMulticast`, lalu tandai flag di Firestore.
 *
 * Prasyarat environment:
 * - `GOOGLE_APPLICATION_CREDENTIALS`: path service account (repository secret).
 * - `FIREBASE_PROJECT_ID`: opsional, default `imunikita-dev-f`.
 * - `DRY_RUN=true`: hanya mencetak, tidak mengirim/menulis.
 */

import { applicationDefault, initializeApp } from 'firebase-admin/app';
import { FieldValue, getFirestore } from 'firebase-admin/firestore';
import { getMessaging } from 'firebase-admin/messaging';

const PROJECT_ID = process.env.FIREBASE_PROJECT_ID || 'imunikita-dev-f';
const DRY_RUN = String(process.env.DRY_RUN || '').toLowerCase() === 'true';
const TIME_ZONE = 'Asia/Jakarta';
const REMINDER_DAYS = [7, 1];

initializeApp({
  credential: applicationDefault(),
  projectId: PROJECT_ID,
});

const db = getFirestore();

/** Tanggal `YYYY-MM-DD` menurut zona waktu Asia/Jakarta. */
function dateKey(date) {
  return new Intl.DateTimeFormat('en-CA', {
    timeZone: TIME_ZONE,
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
  }).format(date);
}

/** Geser date-key sejumlah hari (aritmetika tanggal murni, aman DST). */
function shiftDateKey(key, days) {
  const [year, month, day] = key.split('-').map(Number);
  const date = new Date(Date.UTC(year, month - 1, day));
  date.setUTCDate(date.getUTCDate() + days);
  return date.toISOString().slice(0, 10);
}

function buildBody(namaVaksin, daysBefore) {
  const kapan = daysBefore === 7 ? 'minggu' : 'besok';
  return `Vaksin ${namaVaksin} dijadwalkan ${kapan}! Siapkan buku KIA-mu.`;
}

function toDate(value) {
  if (!value) return null;
  if (typeof value.toDate === 'function') return value.toDate();
  if (value instanceof Date) return value;
  return null;
}

async function tokensForUser(uid) {
  const snapshot = await db
    .collection('users')
    .doc(uid)
    .collection('devices')
    .get();

  return snapshot.docs;
}

async function deleteStaleToken(uid, token) {
  try {
    await db
      .collection('users')
      .doc(uid)
      .collection('devices')
      .doc(token)
      .delete();
    console.log(`  ↳ token basi dihapus (${token.slice(0, 8)}…)`);
  } catch (error) {
    console.warn(`  ↳ gagal menghapus token basi: ${error.message}`);
  }
}

async function sendReminder({ uid, tokenDocs, babyId, babyName, schedule }) {
  const tokens = tokenDocs
    .filter((doc) => doc.get('notificationsEnabled') !== false)
    .map((doc) => doc.id);
  if (tokens.length === 0) return false;

  const { daysBefore } = schedule;
  const title = `🔔 Pengingat Imunisasi ${babyName}`;
  const body = buildBody(schedule.namaVaksin, daysBefore);

  if (DRY_RUN) {
    console.log(
      `[dry-run] uid=${uid} baby=${babyId} vaksin=${schedule.namaVaksin} ` +
        `H-${daysBefore} token=${tokens.length}`,
    );
    return false;
  }

  const response = await getMessaging().sendEachForMulticast({
    tokens,
    notification: { title, body },
    data: {
      type: 'vaccine_reminder',
      scheduleId: schedule.scheduleId,
      babyId,
      daysBefore: String(daysBefore),
    },
    android: {
      priority: 'high',
      notification: {
        channelId: 'imunikita_reminders',
        // Tag sama untuk jadwal yang sama → Android menggabungkan notifikasi.
        tag: schedule.scheduleId,
      },
    },
    apns: {
      payload: { aps: { sound: 'default' } },
    },
  });

  for (let i = 0; i < response.responses.length; i += 1) {
    const result = response.responses[i];
    if (result.success) continue;
    const code = result.error?.code || '';
    if (
      code === 'messaging/registration-token-not-registered' ||
      code === 'messaging/invalid-argument'
    ) {
      await deleteStaleToken(uid, tokens[i]);
    }
  }

  if (response.successCount === 0) {
    console.warn(
      `  ↳ tidak ada token yang berhasil (${response.failureCount} gagal)`,
    );
    return false;
  }

  console.log(
    `  ↳ ${schedule.namaVaksin} H-${daysBefore}: ` +
      `${response.successCount} terkirim, ${response.failureCount} gagal`,
  );
  return true;
}

async function processSchedule({ uid, tokenDocs, babyId, babyName, scheduleDoc }) {
  const data = scheduleDoc.data() || {};
  const tanggalTarget = toDate(data.tanggalTarget);
  if (!tanggalTarget) return;

  const targetKey = dateKey(tanggalTarget);
  const today = dateKey(new Date());

  for (const daysBefore of REMINDER_DAYS) {
    if (shiftDateKey(targetKey, -daysBefore) !== today) continue;

    const field = daysBefore === 7 ? 'reminderH7Sent' : 'reminderH1Sent';
    if (data[field] === true) {
      console.log(
        `  ↳ ${data.namaVaksin || scheduleDoc.id} H-${daysBefore} sudah ditandai, dilewati`,
      );
      continue;
    }

    const sent = await sendReminder({
      uid,
      tokenDocs,
      babyId,
      babyName,
      schedule: {
        scheduleId: data.scheduleId || scheduleDoc.id,
        namaVaksin: data.namaVaksin || 'imunisasi',
        daysBefore,
      },
    });

    if (sent) {
      await scheduleDoc.ref.update({
        [field]: true,
        [`${field}At`]: FieldValue.serverTimestamp(),
      });
    }
  }
}

async function main() {
  console.log(
    `Vaccine reminder mulai — project=${PROJECT_ID} dryRun=${DRY_RUN}`,
  );

  const users = await db.collection('users').get();
  let processed = 0;

  for (const userDoc of users.docs) {
    const uid = userDoc.id;
    const babies = await userDoc.ref.collection('babies').get();

    for (const babyDoc of babies.docs) {
      const babyName = babyDoc.get('namaAnak') || 'si kecil';
      const schedules = await babyDoc.ref
        .collection('vaccineSchedules')
        .where('status', '==', 'BELUM')
        .get();

      if (schedules.empty) continue;

      const tokenDocs = await tokensForUser(uid);
      if (tokenDocs.length === 0) continue;

      for (const scheduleDoc of schedules.docs) {
        await processSchedule({
          uid,
          tokenDocs,
          babyId: babyDoc.id,
          babyName,
          scheduleDoc,
        });
        processed += 1;
      }
    }
  }

  console.log(`Selesai. ${processed} jadwal diperiksa.`);
}

main().catch((error) => {
  console.error('Vaccine reminder gagal:', error);
  process.exitCode = 1;
});
