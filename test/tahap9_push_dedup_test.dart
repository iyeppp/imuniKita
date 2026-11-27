import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imunikita/core/services/local_storage_service.dart';
import 'package:imunikita/core/services/notification_service.dart';
import 'package:imunikita/core/services/push_service.dart';
import 'package:imunikita/core/utils/notification_helper.dart';
import 'package:imunikita/features/immunization/domain/entities/vaccine_schedule_entity.dart';
import 'package:imunikita/features/immunization/domain/repositories/i_immunization_repository.dart';
import 'package:imunikita/features/immunization/domain/usecases/schedule_reminder_usecase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Fake push service — menguji deduplikasi B9-4 tanpa Firebase.
class _FakePushService implements IPushService {
  _FakePushService({required this.active});

  bool active;

  @override
  Future<void> init() async {}

  @override
  Future<bool> isPushActive() async => active;

  @override
  Future<void> syncNotificationsPreference(bool enabled) async {}

  @override
  Future<void> onLogout() async {}

  @override
  Future<void> dispose() async {}
}

class _FakeImmunizationRepository implements IImmunizationRepository {
  final List<VaccineScheduleEntity> tersimpan = [];
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

/// Test Tahap 9 — notifikasi H-7/H-1 dan deduplikasi lokal vs FCM.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const kanal = MethodChannel('dexterous.com/flutter/local_notifications');

  late List<MethodCall> panggilan;
  late _FakeImmunizationRepository repository;

  VaccineScheduleEntity jadwal({String id = 's-1'}) {
    return VaccineScheduleEntity(
      scheduleId: id,
      babyId: 'baby-1',
      namaVaksin: 'BCG',
      deskripsi: 'Deskripsi',
      usiaBulanTarget: 1,
      tanggalTarget: DateTime.now().add(const Duration(days: 10)),
      status: VaccineStatus.belum,
    );
  }

  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    AndroidFlutterLocalNotificationsPlugin.registerWith();
  });

  setUp(() async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    NotificationService.resetScheduleModeForTest();
    panggilan = [];
    repository = _FakeImmunizationRepository();
    await LocalStorageService.setNotificationEnabled(true);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(kanal, (call) async {
          panggilan.add(call);
          return null;
        });
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(kanal, null);
    NotificationService.resetScheduleModeForTest();
  });

  int jumlahZonedSchedule() =>
      panggilan.where((c) => c.method == 'zonedSchedule').length;

  group('B9-4 — deduplikasi lokal vs FCM', () {
    test('pengingat lokal dijadwalkan saat push tidak aktif', () async {
      final useCase = ScheduleReminderUseCase(
        repository: repository,
        pushService: _FakePushService(active: false),
      );

      await useCase.execute(namaAnak: 'Aira', schedules: [jadwal()]);

      // H-7 dan H-1 sama-sama di masa depan → dua notifikasi.
      expect(jumlahZonedSchedule(), 2);
      expect(repository.jumlahUpdate, 1);
    });

    test('pengingat lokal dilewati saat push aktif (tidak dobel)', () async {
      final useCase = ScheduleReminderUseCase(
        repository: repository,
        pushService: _FakePushService(active: true),
      );

      await useCase.execute(namaAnak: 'Aira', schedules: [jadwal()]);

      expect(jumlahZonedSchedule(), 0);
      // Flag lokal tidak di-set agar fallback bisa dipulihkan nanti.
      expect(repository.jumlahUpdate, 0);
    });

    test(
      'tanpa pushService tetap menjadwalkan lokal (kompatibel lama)',
      () async {
        const useCase = ScheduleReminderUseCase();

        await useCase.execute(namaAnak: 'Aira', schedules: [jadwal()]);

        expect(jumlahZonedSchedule(), 2);
      },
    );

    test('preferensi notifikasi mati mengalahkan semua jalur', () async {
      await LocalStorageService.setNotificationEnabled(false);

      final useCase = ScheduleReminderUseCase(
        repository: repository,
        pushService: _FakePushService(active: false),
      );

      await useCase.execute(namaAnak: 'Aira', schedules: [jadwal()]);

      expect(jumlahZonedSchedule(), 0);
      expect(repository.jumlahUpdate, 0);
    });
  });

  group('B9-1 — helper notifikasi lokal', () {
    test('ID notifikasi deterministik dan berbeda untuk H-7 vs H-1', () {
      final h7 = NotificationHelper.notificationId('schedule-abc', 7);
      final h1 = NotificationHelper.notificationId('schedule-abc', 1);
      final h7Lain = NotificationHelper.notificationId('schedule-abc', 7);

      expect(h7, h7Lain);
      expect(h7, isNot(h1));
    });

    test('tanggal pengingat mengurangi offset hari pada jam yang sama', () {
      final target = DateTime(2026, 12, 20);
      final h7 = NotificationHelper.reminderDate(
        tanggalTarget: target,
        daysBefore: 7,
      );
      final h1 = NotificationHelper.reminderDate(
        tanggalTarget: target,
        daysBefore: 1,
      );

      expect(h7, DateTime(2026, 12, 13, 8));
      expect(h1, DateTime(2026, 12, 19, 8));
    });

    test('body membedakan H-7 (minggu) dan H-1 (besok)', () {
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

  group('B9-2 — PushService aman saat FCM nonaktif (default)', () {
    test('isPushActive false bila ENABLE_PUSH tidak di-set', () async {
      // Unit test tidak mengirim --dart-define=ENABLE_PUSH=true.
      expect(await PushService.instance.isPushActive(), isFalse);
    });

    test(
      'init & syncNotificationsPreference tidak melempar tanpa Firebase',
      () async {
        await PushService.instance.init();
        await PushService.instance.syncNotificationsPreference(false);
        await PushService.instance.onLogout();
        expect(await PushService.instance.isPushActive(), isFalse);
        await PushService.instance.dispose();
      },
    );
  });
}
