import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:imunikita/core/constants/app_constants.dart';
import 'package:imunikita/core/errors/failures.dart';
import 'package:imunikita/core/services/local_storage_service.dart';
import 'package:imunikita/features/auth/data/models/user_model.dart';
import 'package:imunikita/features/auth/domain/entities/user_entity.dart';
import 'package:imunikita/features/auth/presentation/providers/auth_provider.dart';
import 'package:imunikita/hive_registrar.g.dart';
import 'package:imunikita/widgets/confirm_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Test untuk poin 8 — Profil & Pengaturan: sesi (SharedPreferences),
/// pembaruan profil (Hive CE), dan dialog konfirmasi keluar.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUpAll(() async {
    // Satu store prefs untuk semua test (instance SharedPreferences di-cache
    // oleh LocalStorageService, jadi mock tidak boleh diganti di tengah).
    SharedPreferences.setMockInitialValues({});

    tempDir = await Directory.systemTemp.createTemp('imunikita_settings_test');
    Hive.init(tempDir.path);
    Hive.registerAdapters();
  });

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  Future<SharedPreferences> prefs() => SharedPreferences.getInstance();

  setUp(() async {
    final store = await prefs();
    await store.clear();
    await Hive.deleteBoxFromDisk(AppConstants.usersBox);
  });

  Future<UserModel> seedUser({
    String localId = 'user-1',
    String nama = 'Ibu Sari',
    String email = 'sari@email.com',
  }) async {
    final box = await Hive.openBox<UserModel>(AppConstants.usersBox);
    final user = UserModel(
      localId: localId,
      namaLengkap: nama,
      email: email,
      nomorTelepon: '081234567890',
      lokasiKota: 'Bandung',
      createdAt: DateTime(2026, 9, 1),
    );
    await box.put(user.localId, user);
    return user;
  }

  group('LocalStorageService — preferensi & sesi', () {
    test('notifikasi aktif secara default', () async {
      expect(await LocalStorageService.isNotificationEnabled(), isTrue);
    });

    test('setNotificationEnabled menyimpan pilihan user', () async {
      await LocalStorageService.setNotificationEnabled(false);
      expect(await LocalStorageService.isNotificationEnabled(), isFalse);

      await LocalStorageService.setNotificationEnabled(true);
      expect(await LocalStorageService.isNotificationEnabled(), isTrue);
    });

    test('setCurrentUserName memperbarui nama sesi', () async {
      await LocalStorageService.setCurrentUserName('Ibu Rina');
      expect(await LocalStorageService.getCurrentUserName(), 'Ibu Rina');
    });

    test('clearSession menghapus sesi login saja', () async {
      final store = await prefs();
      await store.setBool(AppConstants.prefIsLoggedIn, true);
      await store.setString(AppConstants.prefUserId, 'user-1');
      await store.setString(AppConstants.prefUserName, 'Ibu Sari');
      await store.setBool(AppConstants.prefSeenOnboarding, true);
      // Dinonaktifkan untuk user-1 (Temuan #19 → key per pengguna).
      await LocalStorageService.setNotificationEnabled(false);
      await LocalStorageService.setActiveBabyId('baby-1');

      await LocalStorageService.clearSession();

      expect(await LocalStorageService.isLoggedIn(), isFalse);
      expect(await LocalStorageService.getCurrentUserId(), isNull);
      expect(await LocalStorageService.getCurrentUserName(), isNull);
      // Tidak ikut terhapus → user logout langsung ke Login, bukan Onboarding.
      expect(store.getBool(AppConstants.prefSeenOnboarding), isTrue);
      // Fix Bug #41: pilihan bayi aktif ikut dibersihkan agar tidak bocor ke
      // akun berikutnya di perangkat yang sama.
      expect(await LocalStorageService.getActiveBabyId(), isNull);
      // Tanpa sesi, preferensi kembali ke key dasar (default aktif) — preferensi
      // milik user-1 tetap tersimpan untuk login berikutnya.
      expect(await LocalStorageService.isNotificationEnabled(), isTrue);
      expect(
        store.getBool('${AppConstants.prefNotificationsEnabled}_user-1'),
        isFalse,
      );
    });

    test('preferensi notifikasi tidak terbawa antar-akun (#19)', () async {
      final store = await prefs();

      store.setString(AppConstants.prefUserId, 'user-1');
      await LocalStorageService.setNotificationEnabled(false);
      expect(await LocalStorageService.isNotificationEnabled(), isFalse);

      // Ganti akun di perangkat yang sama → kembali ke default aktif.
      store.setString(AppConstants.prefUserId, 'user-2');
      expect(await LocalStorageService.isNotificationEnabled(), isTrue);

      // Kembali ke akun pertama → preferensinya tetap tersimpan.
      store.setString(AppConstants.prefUserId, 'user-1');
      expect(await LocalStorageService.isNotificationEnabled(), isFalse);
    });
  });

  group('CurrentUserProvider', () {
    test('mengembalikan null bila sesi tidak ada', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(await container.read(currentUserProvider.future), isNull);
    });

    test('membaca user aktif dari Hive berdasarkan sesi', () async {
      final user = await seedUser();
      await (await prefs()).setString(AppConstants.prefUserId, user.localId);

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final hasil = await container.read(currentUserProvider.future);
      expect(hasil, isNotNull);
      expect(hasil!.namaLengkap, 'Ibu Sari');
    });

    test(
      'updateProfile menyimpan perubahan & menyelaraskan nama sesi',
      () async {
        final user = await seedUser();
        await (await prefs()).setString(AppConstants.prefUserId, user.localId);

        final container = ProviderContainer();
        addTearDown(container.dispose);
        await container.read(currentUserProvider.future);

        await container
            .read(currentUserProvider.notifier)
            .updateProfile(
              UserEntity(
                localId: user.localId,
                namaLengkap: 'Ibu Sari Wijaya',
                email: 'sari.baru@email.com',
                nomorTelepon: '089999999999',
                lokasiKota: 'Jakarta',
                createdAt: user.createdAt,
              ),
            );

        final tersimpan = (await container.read(currentUserProvider.future))!;
        expect(tersimpan.namaLengkap, 'Ibu Sari Wijaya');
        expect(tersimpan.email, 'sari.baru@email.com');
        expect(tersimpan.lokasiKota, 'Jakarta');
        expect(
          await LocalStorageService.getCurrentUserName(),
          'Ibu Sari Wijaya',
        );
      },
    );

    test('updateProfile menolak email milik akun lain', () async {
      final user = await seedUser();
      await seedUser(
        localId: 'user-2',
        nama: 'Ayah Budi',
        email: 'budi@email.com',
      );
      await (await prefs()).setString(AppConstants.prefUserId, user.localId);

      final container = ProviderContainer();
      addTearDown(container.dispose);
      await container.read(currentUserProvider.future);

      expect(
        () => container
            .read(currentUserProvider.notifier)
            .updateProfile(
              UserEntity(
                localId: user.localId,
                namaLengkap: user.namaLengkap,
                email: 'budi@email.com',
                nomorTelepon: user.nomorTelepon,
                createdAt: user.createdAt,
              ),
            ),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('logout menghapus sesi dan mengosongkan user aktif', () async {
      final user = await seedUser();
      final store = await prefs();
      await store.setBool(AppConstants.prefIsLoggedIn, true);
      await store.setString(AppConstants.prefUserId, user.localId);

      final container = ProviderContainer();
      addTearDown(container.dispose);
      await container.read(currentUserProvider.future);

      await container.read(currentUserProvider.notifier).logout();

      expect(await LocalStorageService.isLoggedIn(), isFalse);
      expect(await container.read(currentUserProvider.future), isNull);
      // Data domain tetap ada — hanya sesi yang dihapus.
      final box = await Hive.openBox<UserModel>(AppConstants.usersBox);
      expect(box.length, 1);
    });
  });

  group('ConfirmDialog', () {
    testWidgets('mengembalikan true saat dikonfirmasi', (tester) async {
      bool? hasil;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: ElevatedButton(
                  onPressed: () async {
                    hasil = await ConfirmDialog.show(
                      context: context,
                      title: 'Keluar dari akun?',
                      message: 'Sesi akan dihapus.',
                      confirmLabel: 'Keluar',
                      isDestructive: true,
                    );
                  },
                  child: const Text('Buka'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Buka'));
      await tester.pumpAndSettle();

      expect(find.text('Keluar dari akun?'), findsOneWidget);

      await tester.tap(find.text('Keluar'));
      await tester.pumpAndSettle();

      expect(hasil, isTrue);
    });

    testWidgets('mengembalikan false saat dibatalkan', (tester) async {
      bool? hasil = true;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: ElevatedButton(
                  onPressed: () async {
                    hasil = await ConfirmDialog.show(
                      context: context,
                      title: 'Keluar dari akun?',
                      message: 'Sesi akan dihapus.',
                    );
                  },
                  child: const Text('Buka'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Buka'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();

      expect(hasil, isFalse);
    });
  });
}
