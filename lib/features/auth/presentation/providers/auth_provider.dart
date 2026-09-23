import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive_ce.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/local_storage_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../data/models/user_model.dart';

// Provider ditulis manual (tanpa codegen) mengikuti pola seluruh aplikasi —
// lihat dev plan §2.

// ── Profil user yang sedang login ────────────────────────────────────────

/// Akun yang sedang login, dibaca dari Hive CE `userBox` memakai
/// `user_id` di SharedPreferences.
///
/// Mengembalikan `null` bila sesi tidak ada (mis. setelah logout) sehingga
/// layar yang mem-`watch` provider ini tetap aman dibuka.
class CurrentUserNotifier extends AsyncNotifier<UserModel?> {
  @override
  Future<UserModel?> build() async {
    final userId = await LocalStorageService.getCurrentUserId();
    if (userId == null) return null;

    final box = await Hive.openBox<UserModel>(AppConstants.usersBox);
    return box.get(userId);
  }

  /// Simpan perubahan profil dari layar Profil & Pengaturan.
  ///
  /// Menolak email yang sudah dipakai akun lain: `LoginScreen` mencocokkan
  /// akun berdasarkan email, jadi duplikat akan membuat login ambigu.
  Future<void> updateProfile(UserModel updated) async {
    final box = await Hive.openBox<UserModel>(AppConstants.usersBox);
    if (box.isEmpty) {
      throw const NotFoundFailure('Akun tidak ditemukan di perangkat ini.');
    }

    final email = updated.email.trim().toLowerCase();
    final bentrok = box.values.any(
      (user) =>
          user.localId != updated.localId &&
          user.email.trim().toLowerCase() == email,
    );
    if (bentrok) {
      throw const ValidationFailure(
        'Email tersebut sudah dipakai akun lain di perangkat ini.',
      );
    }

    updated.email = email;
    await box.put(updated.localId, updated);

    // Agar sapaan/sesi di layar lain ikut memakai nama terbaru.
    await LocalStorageService.setCurrentUserName(updated.namaLengkap);
    ref.invalidateSelf();
  }

  /// Keluar dari akun — hanya menghapus sesi; data bayi, jadwal imunisasi,
  /// pertumbuhan, dan jurnal **tetap tersimpan** di perangkat.
  ///
  /// Pengingat yang sudah terjadwal ikut dibatalkan supaya notifikasi bayi
  /// milik akun ini tidak muncul lagi setelah keluar (Temuan #19).
  Future<void> logout() async {
    await LocalStorageService.clearSession();

    try {
      await NotificationService.cancelAllNotifications();
    } catch (_) {
      // Non-fatal: plugin notifikasi bisa gagal (mis. izin/kanal belum siap),
      // tetapi logout tetap harus berhasil.
    }

    ref.invalidateSelf();
  }
}

final currentUserProvider =
    AsyncNotifierProvider<CurrentUserNotifier, UserModel?>(
      CurrentUserNotifier.new,
    );

// ── Preferensi notifikasi pengingat ──────────────────────────────────────

/// Status notifikasi pengingat H-7 & H-1 (default aktif).
///
/// Dipakai bersama oleh layar Profil & Pengaturan (toggle) dan
/// `ScheduleReminderUseCase` (berhenti menjadwalkan bila dimatikan).
class NotificationPrefNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() => LocalStorageService.isNotificationEnabled();

  Future<void> setEnabled(bool enabled) async {
    await LocalStorageService.setNotificationEnabled(enabled);

    // Saat dimatikan, batalkan semua pengingat yang sudah terjadwal agar
    // tidak ada notifikasi "nyasar" setelah user memilih nonaktif.
    // Gagal membatalkan (mis. plugin belum siap) tidak boleh membatalkan
    // preferensi yang sudah dipilih user — lihat filosofi non-fatal di 1.5.
    if (!enabled) {
      try {
        await NotificationService.cancelAllNotifications();
      } catch (_) {
        // Diabaikan dengan sengaja.
      }
    }

    ref.invalidateSelf();
  }
}

final notificationEnabledProvider =
    AsyncNotifierProvider<NotificationPrefNotifier, bool>(
      NotificationPrefNotifier.new,
    );
