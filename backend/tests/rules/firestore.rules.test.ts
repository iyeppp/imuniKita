import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { afterAll, beforeAll, beforeEach, describe, it } from 'vitest';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
  type RulesTestEnvironment,
} from '@firebase/rules-unit-testing';
import { Timestamp, doc, getDoc, setDoc, deleteDoc, updateDoc } from 'firebase/firestore';

const OWNER = 'owner-uid';
const OTHER = 'other-uid';

let env: RulesTestEnvironment;

const validUser = {
  namaLengkap: 'Ibu Test',
  email: 'ibu@example.com',
  nomorTelepon: '081234567890',
  lokasiKota: 'Malang',
  createdAt: Timestamp.now(),
  updatedAt: Timestamp.now(),
  schemaVersion: 1,
};

const validBaby = {
  namaAnak: 'Bayi Test',
  tanggalLahir: Timestamp.fromDate(new Date('2025-01-01')),
  jenisKelamin: 'Perempuan',
  schemaVersion: 1,
};

beforeAll(async () => {
  env = await initializeTestEnvironment({
    projectId: 'imunikita-rules-test',
    firestore: {
      rules: readFileSync(resolve(__dirname, '../../firestore.rules'), 'utf8'),
      host: '127.0.0.1',
      port: 8080,
    },
  });
});

afterAll(async () => {
  await env.cleanup();
});

beforeEach(async () => {
  await env.clearFirestore();
  // Seed data sebagai admin (rules dilewati) agar tiap skenario mandiri.
  await env.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    await setDoc(doc(db, `users/${OWNER}`), validUser);
    await setDoc(doc(db, `users/${OWNER}/babies/baby-1`), validBaby);
    await setDoc(doc(db, `users/${OWNER}/babies/baby-1/growthRecords/g-1`), {
      tanggalPengukuran: Timestamp.now(),
      beratBadan: 4.2,
      schemaVersion: 1,
    });
  });
});

describe('users/{uid}', () => {
  it('pemilik boleh membaca profilnya sendiri', async () => {
    const db = env.authenticatedContext(OWNER).firestore();
    await assertSucceeds(getDoc(doc(db, `users/${OWNER}`)));
  });

  it('user lain tidak boleh membaca profil orang lain', async () => {
    const db = env.authenticatedContext(OTHER).firestore();
    await assertFails(getDoc(doc(db, `users/${OWNER}`)));
  });

  it('anonim tidak boleh membaca data apa pun', async () => {
    const db = env.unauthenticatedContext().firestore();
    await assertFails(getDoc(doc(db, `users/${OWNER}`)));
  });

  it('dokumen users tidak boleh dihapus dari klien', async () => {
    const db = env.authenticatedContext(OWNER).firestore();
    await assertFails(deleteDoc(doc(db, `users/${OWNER}`)));
  });

  it('menolak field di luar daftar yang diizinkan', async () => {
    const db = env.authenticatedContext(OWNER).firestore();
    await assertFails(
      updateDoc(doc(db, `users/${OWNER}`), { isAdmin: true }),
    );
  });
});

describe('users/{uid}/babies/{babyId}', () => {
  it('pemilik boleh membuat bayi yang valid', async () => {
    const db = env.authenticatedContext(OWNER).firestore();
    await assertSucceeds(
      setDoc(doc(db, `users/${OWNER}/babies/baby-2`), validBaby),
    );
  });

  it('user lain tidak boleh membaca bayi milik orang lain', async () => {
    const db = env.authenticatedContext(OTHER).firestore();
    await assertFails(getDoc(doc(db, `users/${OWNER}/babies/baby-1`)));
  });

  it('menolak bayi dengan nama kosong atau jenis kelamin tidak valid', async () => {
    const db = env.authenticatedContext(OWNER).firestore();
    await assertFails(
      setDoc(doc(db, `users/${OWNER}/babies/baby-3`), { ...validBaby, namaAnak: '' }),
    );
    await assertFails(
      setDoc(doc(db, `users/${OWNER}/babies/baby-4`), { ...validBaby, jenisKelamin: 'X' }),
    );
  });

  it('menolak bayi tanpa schemaVersion', async () => {
    const db = env.authenticatedContext(OWNER).firestore();
    const { schemaVersion: _omit, ...withoutVersion } = validBaby;
    await assertFails(
      setDoc(doc(db, `users/${OWNER}/babies/baby-5`), withoutVersion),
    );
  });

  it('pemilik boleh menghapus bayi (cascade dilakukan klien)', async () => {
    const db = env.authenticatedContext(OWNER).firestore();
    await assertSucceeds(deleteDoc(doc(db, `users/${OWNER}/babies/baby-1`)));
  });
});

describe('subkoleksi bayi (growthRecords, dll.)', () => {
  it('pemilik boleh menambah rekam pertumbuhan', async () => {
    const db = env.authenticatedContext(OWNER).firestore();
    await assertSucceeds(
      setDoc(doc(db, `users/${OWNER}/babies/baby-1/growthRecords/g-2`), {
        tanggalPengukuran: Timestamp.now(),
        beratBadan: 5.0,
        schemaVersion: 1,
      }),
    );
  });

  it('user lain tidak boleh membaca rekam pertumbuhan', async () => {
    const db = env.authenticatedContext(OTHER).firestore();
    await assertFails(
      getDoc(doc(db, `users/${OWNER}/babies/baby-1/growthRecords/g-1`)),
    );
  });
});

describe('koleksi tidak dikenal', () => {
  it('path di luar skema ditolak secara default', async () => {
    const db = env.authenticatedContext(OWNER).firestore();
    await assertFails(setDoc(doc(db, 'secretCollection/x'), { a: 1 }));
  });
});
