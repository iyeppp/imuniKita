import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imunikita/core/constants/app_constants.dart';
import 'package:imunikita/core/constants/vaccine_schedule.dart';
import 'package:imunikita/core/services/local_storage_service.dart';
import 'package:imunikita/core/services/notification_service.dart';
import 'package:imunikita/core/utils/age_calculator.dart';
import 'package:imunikita/core/utils/notification_helper.dart';
import 'package:imunikita/features/baby_profile/domain/entities/baby_entity.dart';
import 'package:imunikita/features/immunization/domain/entities/vaccine_schedule_entity.dart';
import 'package:imunikita/features/immunization/domain/repositories/i_immunization_repository.dart';
import 'package:imunikita/features/immunization/domain/usecases/generate_schedule_usecase.dart';
import 'package:imunikita/features/immunization/domain/usecases/reschedule_all_reminders_usecase.dart';
import 'package:imunikita/features/immunization/domain/usecases/schedule_reminder_usecase.dart';
import 'package:imunikita/features/immunization/domain/usecases/sync_baby_schedule_usecase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Repository in-memory — supaya use case bisa diuji tanpa Hive.
class _FakeImmunizationRepository implements IImmunizationRepository {
  final List<VaccineScheduleEntity> tersimpan = [];
  int jumlahSimpan = 0;
  int jumlahUpdate = 0;

  @override
  Future<List<VaccineScheduleEntity>> getSchedulesByBaby(String babyId) async =>
      tersimpan.where((s) => s.babyId == babyId).toList();

  @override
  Future<VaccineScheduleEntity?> getScheduleById(String scheduleId) async {
    for (final jadwal in tersimpan) {
      if (jadwal.scheduleId == scheduleId) return jadwal;
    }
    return null;
  }

  @override
  Future<void> saveSchedules(List<VaccineScheduleEntity> schedules) async {
    jumlahSimpan++;
    tersimpan.removeWhere(
      (lama) => schedules.any((baru) => baru.scheduleId == lama.scheduleId),
    );
    tersimpan.addAll(schedules);
  }

  @override
  Future<VaccineScheduleEntity> updateSchedule(
    VaccineScheduleEntity schedule,
  ) async {
    jumlahUpdate++;
    tersimpan.removeWhere((s) => s.scheduleId == schedule.scheduleId);
    tersimpan.add(schedule);
    return schedule;
  }

  @override
  Future<void> deleteSchedulesByBaby(String babyId) async {
    tersimpan.removeWhere((s) => s.babyId == babyId);
  }
}

/// Test Temuan #9 — unit test use case inti Sprint 1–2
/// (`GenerateScheduleUseCase` & `ScheduleReminderUseCase`).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // `LocalStorageService` menyimpan instance prefs — set sekali saja.
    SharedPreferences.setMockInitialValues({});
    // `NotificationService` memakai `tz.local` → samakan dengan `main.dart`.
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    // Daftarkan implementasi platform Android (biasanya oleh plugin registrant)
    // supaya `FlutterLocalNotificationsPlatform.instance` tersedia di test.
    AndroidFlutterLocalNotificationsPlugin.registerWith();
  });

  // ── GenerateScheduleUseCase ─────────────────────────────────────────────

  group('GenerateScheduleUseCase', () {
    late _FakeImmunizationRepository repository;
    late GenerateScheduleUseCase useCase;

    const babyId = 'baby-1';
    final tanggalLahir = DateTime(2026, 1, 10);

    setUp(() {
      repository = _FakeImmunizationRepository();
      useCase = GenerateScheduleUseCase(repository);
    });

    test('membuat 13 jadwal sesuai jadwal nasional', () async {
      final hasil = await useCase.execute(
        babyId: babyId,
        tanggalLahir: tanggalLahir,
      );

      expect(hasil.length, VaccineMaster.jadwalNasional.length);
      expect(hasil.length, 13);
      expect(
        hasil.map((s) => s.namaVaksin).toList(),
        VaccineMaster.jadwalNasional.map((v) => v.nama).toList(),
      );
      expect(
        hasil.map((s) => s.usiaBulanTarget).toList(),
        VaccineMaster.jadwalNasional.map((v) => v.usiaBulan).toList(),
      );
      expect(repository.jumlahSimpan, 1);
    });

    test('tanggal target dihitung dari tanggal lahir + usia target', () async {
      final hasil = await useCase.execute(
        babyId: babyId,
        tanggalLahir: tanggalLahir,
      );

      for (final jadwal in hasil) {
        expect(
          jadwal.tanggalTarget,
          AgeCalculator.addMonths(tanggalLahir, jadwal.usiaBulanTarget),
        );
      }

      expect(
        hasil.firstWhere((s) => s.usiaBulanTarget == 0).tanggalTarget,
        DateTime(2026, 1, 10),
      );
      expect(
        hasil.firstWhere((s) => s.namaVaksin == 'MR').tanggalTarget,
        DateTime(2026, 10, 10),
      );
      expect(
        hasil.firstWhere((s) => s.usiaBulanTarget == 18).tanggalTarget,
        DateTime(2027, 7, 10),
      );
    });

    test('aman untuk tanggal lahir akhir bulan', () async {
      final hasil = await useCase.execute(
        babyId: babyId,
        tanggalLahir: DateTime(2026, 1, 31),
      );

      // 31 Jan + 1 bulan → 28 Feb (2026 bukan tahun kabisat).
      expect(
        hasil.firstWhere((s) => s.usiaBulanTarget == 1).tanggalTarget,
        DateTime(2026, 2, 28),
      );
      // 31 Jan + 9 bulan → 31 Okt (Okttober 31 hari).
      expect(
        hasil.firstWhere((s) => s.usiaBulanTarget == 9).tanggalTarget,
        DateTime(2026, 10, 31),
      );
    });

    test('status awal BELUM dan belum ada realisasi/KIPI', () async {
      final hasil = await useCase.execute(
        babyId: babyId,
        tanggalLahir: tanggalLahir,
      );

      expect(hasil.every((s) => s.status == VaccineStatus.belum), isTrue);
      expect(hasil.every((s) => s.tanggalRealisasi == null), isTrue);
      expect(hasil.every((s) => s.catatanReaksi == null), isTrue);
    });

    test('setiap jadwal punya id unik & babyId yang benar', () async {
      final hasil = await useCase.execute(
        babyId: babyId,
        tanggalLahir: tanggalLahir,
      );

      expect(hasil.map((s) => s.scheduleId).toSet().length, 13);
      expect(hasil.every((s) => s.babyId == babyId), isTrue);
    });

    test(
      'tidak generate ulang bila jadwal sudah ada (guard double tap)',
      () async {
        final pertama = await useCase.execute(
          babyId: babyId,
          tanggalLahir: tanggalLahir,
        );
        final kedua = await useCase.execute(
          babyId: babyId,
          tanggalLahir: DateTime(2026, 3, 15),
        );

        expect(kedua.length, pertama.length);
        // Mengembalikan jadwal lama — bukan menghitung ulang dari tanggal baru.
        expect(kedua.first.scheduleId, pertama.first.scheduleId);
        expect(kedua.first.tanggalTarget, DateTime(2026, 1, 10));
        expect(repository.jumlahSimpan, 1);
        expect(repository.tersimpan.length, 13);
      },
    );

    test('tidak mengganggu jadwal bayi lain', () async {
      await useCase.execute(babyId: 'baby-1', tanggalLahir: tanggalLahir);
      await useCase.execute(
        babyId: 'baby-2',
        tanggalLahir: DateTime(2026, 5, 1),
      );

      expect(await repository.getSchedulesByBaby('baby-1'), hasLength(13));
      expect(await repository.getSchedulesByBaby('baby-2'), hasLength(13));
      expect(repository.tersimpan.length, 26);
    });
  });

  // ── NotificationHelper (logika murni) ───────────────────────────────────

  group('NotificationHelper', () {
    test('reminderDate = tanggal target - N hari pada jam pengingat', () {
      final h7 = NotificationHelper.reminderDate(
        tanggalTarget: DateTime(2026, 6, 10),
        daysBefore: 7,
      );
      final h1 = NotificationHelper.reminderDate(
        tanggalTarget: DateTime(2026, 6, 10),
        daysBefore: 1,
      );

      expect(h7, DateTime(2026, 6, 3, AppConstants.reminderHour));
      expect(h1, DateTime(2026, 6, 9, AppConstants.reminderHour));
      expect(NotificationHelper.supportedDaysBefore, [7, 1]);
    });

    test('notificationId stabil & berbeda per jadwal maupun offset hari', () {
      final h7Pertama = NotificationHelper.notificationId('s-1', 7);
      final h7Kedua = NotificationHelper.notificationId('s-1', 7);

      expect(h7Pertama, h7Kedua);
      expect(h7Pertama, isNot(NotificationHelper.notificationId('s-1', 1)));
      expect(h7Pertama, isNot(NotificationHelper.notificationId('s-2', 7)));
      expect(h7Pertama, greaterThanOrEqualTo(0));
    });

    test('judul & isi notifikasi membedakan H-7 dan H-1', () {
      expect(NotificationHelper.buildTitle(namaAnak: 'Aira'), contains('Aira'));
      expect(
        NotificationHelper.buildBody(namaVaksin: 'BCG', daysBefore: 7),
        contains('minggu'),
      );
      expect(
        NotificationHelper.buildBody(namaVaksin: 'BCG', daysBefore: 1),
        contains('besok'),
      );
    });
  });

  // ── ScheduleReminderUseCase (dengan mock kanal notifikasi) ──────────────

  group('ScheduleReminderUseCase', () {
    const kanal = MethodChannel('dexterous.com/flutter/local_notifications');
    const useCase = ScheduleReminderUseCase();

    late List<MethodCall> panggilan;

    VaccineScheduleEntity jadwal({
      required DateTime tanggalTarget,
      String status = VaccineStatus.belum,
      String scheduleId = 's-1',
      String namaVaksin = 'BCG',
    }) {
      return VaccineScheduleEntity(
        scheduleId: scheduleId,
        babyId: 'baby-1',
        namaVaksin: namaVaksin,
        deskripsi: 'Deskripsi',
        usiaBulanTarget: 1,
        tanggalTarget: tanggalTarget,
        status: status,
      );
    }

    Map<Object?, Object?> argsUntuk(int daysBefore) {
      final id = NotificationHelper.notificationId('s-1', daysBefore);
      return panggilan
              .firstWhere((c) => (c.arguments as Map)['id'] == id)
              .arguments
          as Map<Object?, Object?>;
    }

    /// `NotificationService` mengonversi waktu ke zona waktu lokal perangkat
    /// (`Asia/Jakarta` pada test ini), jadi pembandingnya pun dikonversi sama.
    String isoJakarta(DateTime waktu) => tz.TZDateTime.from(
      waktu,
      tz.getLocation('Asia/Jakarta'),
    ).toIso8601String();

    setUp(() async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      NotificationService.resetScheduleModeForTest();
      panggilan = [];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(kanal, (call) async {
            panggilan.add(call);
            return null;
          });
      await LocalStorageService.setNotificationEnabled(true);
    });

    tearDown(() {
      debugDefaultTargetPlatformOverride = null;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(kanal, null);
    });

    test('menjadwalkan H-7 & H-1 untuk jadwal yang masih depan', () async {
      final target = DateTime.now().add(const Duration(days: 10));
      final reminderH7 = NotificationHelper.reminderDate(
        tanggalTarget: target,
        daysBefore: 7,
      );
      final reminderH1 = NotificationHelper.reminderDate(
        tanggalTarget: target,
        daysBefore: 1,
      );

      await useCase.execute(
        namaAnak: 'Aira',
        schedules: [jadwal(tanggalTarget: target)],
      );

      expect(panggilan, hasLength(2));
      expect(panggilan.every((c) => c.method == 'zonedSchedule'), isTrue);

      final argsH7 = argsUntuk(7);
      expect(argsH7['title'], contains('Aira'));
      expect(argsH7['body'], contains('minggu'));
      expect(argsH7['payload'], 's-1');
      expect(argsH7['timeZoneName'], 'Asia/Jakarta');
      expect(argsH7['scheduledDateTimeISO8601'], isoJakarta(reminderH7));

      final argsH1 = argsUntuk(1);
      expect(argsH1['body'], contains('besok'));
      expect(argsH1['scheduledDateTimeISO8601'], isoJakarta(reminderH1));

      // Pastikan konfigurasi kanal Android ikut terkirim.
      final specifics = argsH7['platformSpecifics'] as Map;
      expect(specifics['channelId'], 'imunikita_reminders');
      expect(specifics['importance'], 5);
      expect(
        specifics['scheduleMode'].toString(),
        contains('exactAllowWhileIdle'),
      );
    });

    test('hanya menjadwalkan H-1 bila pengingat H-7 sudah lewat', () async {
      final target = DateTime.now().add(const Duration(days: 2));

      await useCase.execute(
        namaAnak: 'Aira',
        schedules: [jadwal(tanggalTarget: target)],
      );

      expect(panggilan, hasLength(1));
      expect(
        (panggilan.single.arguments as Map)['id'],
        NotificationHelper.notificationId('s-1', 1),
      );
    });

    test('melewati jadwal yang sudah SELESAI atau TERLEWAT', () async {
      final target = DateTime.now().add(const Duration(days: 30));

      await useCase.execute(
        namaAnak: 'Aira',
        schedules: [
          jadwal(
            scheduleId: 's-selesai',
            tanggalTarget: target,
            status: VaccineStatus.selesai,
          ),
          jadwal(
            scheduleId: 's-terlewat',
            tanggalTarget: target,
            status: VaccineStatus.terlewat,
          ),
        ],
      );

      expect(panggilan, isEmpty);
    });

    test('melewati jadwal yang seluruh pengingatnya sudah lewat', () async {
      await useCase.execute(
        namaAnak: 'Aira',
        schedules: [
          jadwal(
            tanggalTarget: DateTime.now().subtract(const Duration(days: 30)),
          ),
        ],
      );

      expect(panggilan, isEmpty);
    });

    test(
      'tidak menjadwalkan apa pun saat preferensi notifikasi dimatikan',
      () async {
        await LocalStorageService.setNotificationEnabled(false);

        await useCase.execute(
          namaAnak: 'Aira',
          schedules: [
            jadwal(tanggalTarget: DateTime.now().add(const Duration(days: 30))),
          ],
        );

        expect(panggilan, isEmpty);
        expect(await LocalStorageService.isNotificationEnabled(), isFalse);
      },
    );

    test('menjadwalkan untuk beberapa jadwal sekaligus', () async {
      final target = DateTime.now().add(const Duration(days: 40));

      await useCase.execute(
        namaAnak: 'Aira',
        schedules: [
          jadwal(scheduleId: 's-1', tanggalTarget: target),
          jadwal(scheduleId: 's-2', tanggalTarget: target, namaVaksin: 'MR'),
        ],
      );

      expect(panggilan, hasLength(4));
      expect(panggilan.map((c) => (c.arguments as Map)['payload']).toSet(), {
        's-1',
        's-2',
      });
    });
  });

  // ── ScheduleReminderUseCase + flag anti-duplikasi (Bug #11) ─────────────

  group('ScheduleReminderUseCase - flag reminderH7Sent/reminderH1Sent', () {
    const kanal = MethodChannel('dexterous.com/flutter/local_notifications');

    late List<MethodCall> panggilan;
    late _FakeImmunizationRepository repository;
    late ScheduleReminderUseCase useCase;

    VaccineScheduleEntity jadwal({
      required DateTime tanggalTarget,
      String status = VaccineStatus.belum,
      String scheduleId = 's-1',
      bool reminderH7Sent = false,
      bool reminderH1Sent = false,
    }) {
      return VaccineScheduleEntity(
        scheduleId: scheduleId,
        babyId: 'baby-1',
        namaVaksin: 'BCG',
        deskripsi: 'Deskripsi',
        usiaBulanTarget: 1,
        tanggalTarget: tanggalTarget,
        status: status,
        reminderH7Sent: reminderH7Sent,
        reminderH1Sent: reminderH1Sent,
      );
    }

    setUp(() async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      NotificationService.resetScheduleModeForTest();
      panggilan = [];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(kanal, (call) async {
            panggilan.add(call);
            return null;
          });
      await LocalStorageService.setNotificationEnabled(true);
      repository = _FakeImmunizationRepository();
      useCase = ScheduleReminderUseCase(repository: repository);
    });

    tearDown(() {
      debugDefaultTargetPlatformOverride = null;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(kanal, null);
    });

    test('menandai reminderH7Sent & reminderH1Sent true setelah berhasil dijadwalkan', () async {
      final target = DateTime.now().add(const Duration(days: 10));
      final jadwalAwal = jadwal(tanggalTarget: target);
      await repository.saveSchedules([jadwalAwal]);

      await useCase.execute(namaAnak: 'Aira', schedules: [jadwalAwal]);

      final hasil = await repository.getScheduleById('s-1');
      expect(hasil!.reminderH7Sent, isTrue);
      expect(hasil.reminderH1Sent, isTrue);
    });

    test(
      'tidak menjadwalkan ulang pengingat yang flag-nya sudah true',
      () async {
        final target = DateTime.now().add(const Duration(days: 10));
        final jadwalSudahH7 = jadwal(
          tanggalTarget: target,
          reminderH7Sent: true,
        );
        await repository.saveSchedules([jadwalSudahH7]);

        await useCase.execute(namaAnak: 'Aira', schedules: [jadwalSudahH7]);

        // Hanya H-1 yang dijadwalkan; H-7 dilewati karena sudah true.
        expect(panggilan, hasLength(1));
        expect(
          (panggilan.single.arguments as Map)['id'],
          NotificationHelper.notificationId('s-1', 1),
        );

        final hasil = await repository.getScheduleById('s-1');
        expect(hasil!.reminderH7Sent, isTrue);
        expect(hasil.reminderH1Sent, isTrue);
      },
    );

    test(
      'tidak memanggil repository sama sekali bila kedua flag sudah true',
      () async {
        final target = DateTime.now().add(const Duration(days: 10));
        final jadwalLengkap = jadwal(
          tanggalTarget: target,
          reminderH7Sent: true,
          reminderH1Sent: true,
        );
        await repository.saveSchedules([jadwalLengkap]);
        final jumlahUpdateSebelum = repository.jumlahUpdate;

        await useCase.execute(namaAnak: 'Aira', schedules: [jadwalLengkap]);

        expect(panggilan, isEmpty);
        expect(repository.jumlahUpdate, jumlahUpdateSebelum);
      },
    );
  });

  // ── Fallback alarm presisi (Bug #29) ────────────────────────────────────

  group('NotificationService — fallback exact → inexact alarm', () {
    const kanal = MethodChannel('dexterous.com/flutter/local_notifications');

    late List<MethodCall> panggilan;

    VaccineScheduleEntity jadwal({required DateTime tanggalTarget}) {
      return VaccineScheduleEntity(
        scheduleId: 's-1',
        babyId: 'baby-1',
        namaVaksin: 'BCG',
        deskripsi: 'Deskripsi',
        usiaBulanTarget: 1,
        tanggalTarget: tanggalTarget,
        status: VaccineStatus.belum,
      );
    }

    setUp(() async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      NotificationService.resetScheduleModeForTest();
      panggilan = [];
      await LocalStorageService.setNotificationEnabled(true);
    });

    tearDown(() {
      debugDefaultTargetPlatformOverride = null;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(kanal, null);
      NotificationService.resetScheduleModeForTest();
    });

    List<String> modeTerkirim() => panggilan
        .where((c) => c.method == 'zonedSchedule')
        .map(
          (c) =>
              ((c.arguments as Map)['platformSpecifics'] as Map)['scheduleMode']
                  .toString(),
        )
        .toList();

    test('memakai inexactAllowWhileIdle bila OS menolak exact alarm', () async {
      var pertama = true;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(kanal, (call) async {
            if (call.method == 'zonedSchedule') panggilan.add(call);
            if (pertama) {
              pertama = false;
              throw PlatformException(code: 'exact_alarms_not_permitted');
            }
            return null;
          });

      // Target 2 hari lagi → hanya pengingat H-1 yang belum lewat.
      const useCase = ScheduleReminderUseCase();
      await useCase.execute(
        namaAnak: 'Aira',
        schedules: [
          jadwal(tanggalTarget: DateTime.now().add(const Duration(days: 2))),
        ],
      );

      final modes = modeTerkirim();
      expect(modes, hasLength(2));
      expect(modes.first, contains('exactAllowWhileIdle'));
      expect(modes.last, contains('inexactAllowWhileIdle'));
    });

    test('tidak terpengaruh fallback untuk kegagalan error lain', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(kanal, (call) async {
            if (call.method == 'zonedSchedule') panggilan.add(call);
            if (panggilan.length == 1) {
              throw PlatformException(code: 'some_other_error');
            }
            return null;
          });

      const useCase = ScheduleReminderUseCase();
      await useCase.execute(
        namaAnak: 'Aira',
        schedules: [
          jadwal(tanggalTarget: DateTime.now().add(const Duration(days: 2))),
        ],
      );

      // Error lain tidak memicu retry: hanya satu percobaan (exact) yang dicatat.
      expect(modeTerkirim(), hasLength(1));
      expect(modeTerkirim().single, contains('exactAllowWhileIdle'));
    });
  });

  // ── Use case gabungan alur jadwal (Bug #34) ─────────────────────────────

  group('SyncBabyScheduleUseCase (#34)', () {
    const kanal = MethodChannel('dexterous.com/flutter/local_notifications');

    late _FakeImmunizationRepository repository;
    late List<MethodCall> panggilan;

    setUp(() async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      NotificationService.resetScheduleModeForTest();
      panggilan = [];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(kanal, (call) async {
            panggilan.add(call);
            return null;
          });
      await LocalStorageService.setNotificationEnabled(true);
      repository = _FakeImmunizationRepository();
    });

    tearDown(() {
      debugDefaultTargetPlatformOverride = null;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(kanal, null);
    });

    SyncBabyScheduleUseCase useCase() => SyncBabyScheduleUseCase(
      generateSchedule: GenerateScheduleUseCase(repository),
      scheduleReminder: ScheduleReminderUseCase(repository: repository),
    );

    test('membangun 13 jadwal sekaligus mendaftarkan pengingat', () async {
      final hasil = await useCase().execute(
        babyId: 'baby-1',
        namaAnak: 'Aira',
        tanggalLahir: DateTime.now(),
      );

      expect(hasil, hasLength(13));
      expect(await repository.getSchedulesByBaby('baby-1'), hasLength(13));
      expect(panggilan.where((c) => c.method == 'zonedSchedule'), isNotEmpty);
    });

    test('jadwal tetap dibuat walau preferensi notifikasi dimatikan', () async {
      await LocalStorageService.setNotificationEnabled(false);

      final hasil = await useCase().execute(
        babyId: 'baby-1',
        namaAnak: 'Aira',
        tanggalLahir: DateTime.now(),
      );

      expect(hasil, hasLength(13));
      expect(panggilan.where((c) => c.method == 'zonedSchedule'), isEmpty);
    });
  });

  group('RescheduleAllRemindersUseCase (#34)', () {
    const kanal = MethodChannel('dexterous.com/flutter/local_notifications');

    late _FakeImmunizationRepository repository;
    late List<MethodCall> panggilan;

    setUp(() async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      NotificationService.resetScheduleModeForTest();
      panggilan = [];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(kanal, (call) async {
            panggilan.add(call);
            return null;
          });
      await LocalStorageService.setNotificationEnabled(true);
      repository = _FakeImmunizationRepository();
    });

    tearDown(() {
      debugDefaultTargetPlatformOverride = null;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(kanal, null);
    });

    BabyEntity bayi(String id, String nama) => BabyEntity(
      babyId: id,
      userId: 'user-1',
      namaAnak: nama,
      tanggalLahir: DateTime(2026, 1, 10),
      jenisKelamin: BabyGender.laki,
      createdAt: DateTime(2026, 1, 10),
    );

    VaccineScheduleEntity jadwal(String id, String babyId) =>
        VaccineScheduleEntity(
          scheduleId: id,
          babyId: babyId,
          namaVaksin: 'BCG',
          deskripsi: 'Deskripsi',
          usiaBulanTarget: 1,
          tanggalTarget: DateTime.now().add(const Duration(days: 30)),
        );

    test('menghitung jadwal BELUM dan mendaftarkan pengingatnya', () async {
      await repository.saveSchedules([
        jadwal('s-1', 'baby-1'),
        jadwal('s-2', 'baby-2'),
      ]);

      final useCase = RescheduleAllRemindersUseCase(
        repository: repository,
        reminder: ScheduleReminderUseCase(repository: repository),
      );

      final jumlah = await useCase.execute([
        bayi('baby-1', 'Aira'),
        bayi('baby-2', 'Bima'),
      ]);

      expect(jumlah, 2);
      expect(panggilan.where((c) => c.method == 'zonedSchedule'), isNotEmpty);
    });

    test('bayi tanpa jadwal dilewati tanpa error', () async {
      await repository.saveSchedules([jadwal('s-1', 'baby-1')]);

      final useCase = RescheduleAllRemindersUseCase(
        repository: repository,
        reminder: ScheduleReminderUseCase(repository: repository),
      );

      final jumlah = await useCase.execute([
        bayi('baby-1', 'Aira'),
        bayi('baby-tanpa-jadwal', 'Bima'),
      ]);

      expect(jumlah, 1);
    });

    test('daftar bayi kosong → 0 tanpa memanggil apa pun', () async {
      final useCase = RescheduleAllRemindersUseCase(
        repository: repository,
        reminder: ScheduleReminderUseCase(repository: repository),
      );

      expect(await useCase.execute([]), 0);
      expect(panggilan, isEmpty);
    });
  });
}
