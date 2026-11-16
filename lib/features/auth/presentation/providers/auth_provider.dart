import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/local_storage_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../injection/dependency_injection.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_usecase.dart';

// Provider ditulis manual (tanpa codegen) mengikuti pola seluruh aplikasi —
// lihat dev plan §2.

// ── Profil user yang sedang login ────────────────────────────────────────

/// Akun yang sedang login (Temuan #22: dibaca lewat repository auth, bukan
/// `Hive.openBox` langsung dari presentation layer).
///
/// B2-6: setelah pembacaan awal, notifier mendengarkan `authStateChanges`
/// sehingga login/logout (termasuk dari perangkat lain atau sesi kedaluwarsa)
/// langsung memperbarui state tanpa perlu `ref.invalidate` manual.
///
/// Mengembalikan `null` bila sesi tidak ada (mis. setelah logout) sehingga
/// layar yang mem-`watch` provider ini tetap aman dibuka.
class CurrentUserNotifier extends AsyncNotifier<UserEntity?> {
  @override
  Future<UserEntity?> build() async {
    final repository = ref.read(authRepositoryProvider);
    final currentUser = await ref.read(getCurrentUserUseCaseProvider).execute();

    // Langganan dipasang setelah pembacaan awal agar state tidak di-set
    // sebelum build selesai. Stream Firebase langsung memancarkan sesi aktif.
    var disposed = false;
    final subscription = repository.authStateChanges().listen((user) {
      if (disposed) return;
      state = AsyncData(user);
    });
    ref.onDispose(() {
      disposed = true;
      subscription.cancel();
    });

    return currentUser;
  }

  /// Masuk memakai email + password. Hasilnya membedakan "belum ada akun",
  /// "email tidak terdaftar", dan "password salah" agar layar bisa memberi
  /// arahan yang tepat.
  Future<LoginResult> login(String email, String password) async {
    final hasil = await ref.read(loginUseCaseProvider).execute(email, password);
    if (hasil.berhasil) ref.invalidateSelf();
    return hasil;
  }

  /// Daftarkan akun baru (sekaligus membuat sesi).
  Future<UserEntity> register(UserEntity user, String password) async {
    final saved = await ref
        .read(registerUseCaseProvider)
        .execute(user, password);
    ref.invalidateSelf();
    return saved;
  }

  /// Kirim tautan atur ulang password ke email terdaftar.
  Future<void> sendPasswordReset(String email) =>
      ref.read(sendPasswordResetUseCaseProvider).execute(email);

  /// Simpan perubahan profil dari layar Profil & Pengaturan.
  ///
  /// Penolakan email duplikat di mode lokal ada di `AuthRepositoryImpl`.
  Future<void> updateProfile(UserEntity updated) async {
    await ref.read(updateProfileUseCaseProvider).execute(updated);
    ref.invalidateSelf();
  }

  /// Keluar dari akun — hanya menghapus sesi; data bayi, jadwal imunisasi,
  /// pertumbuhan, dan jurnal **tetap tersimpan** di perangkat.
  ///
  /// Pengingat yang sudah terjadwal ikut dibatalkan supaya notifikasi bayi
  /// milik akun ini tidak muncul lagi setelah keluar (Temuan #19).
  Future<void> logout() async {
    await ref.read(logoutUseCaseProvider).execute();

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
    AsyncNotifierProvider<CurrentUserNotifier, UserEntity?>(
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
