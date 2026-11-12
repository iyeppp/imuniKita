import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

/// Versi skema dokumen `users/{uid}` (lihat Tahap 3 / B3-7).
const int _profileSchemaVersion = 1;

/// Terjemahkan kode error Firebase Auth menjadi [Failure] berbahasa Indonesia.
///
/// Dipisah dari [mapFirebaseAuthException] agar mudah diuji tanpa harus
/// membuat instance `FirebaseAuthException` (konstruktornya `@protected`).
Failure authFailureFromCode(String? code) {
  switch (code) {
    case 'email-already-in-use':
      return const EmailAlreadyInUseFailure();
    case 'weak-password':
      return const WeakPasswordFailure();
    case 'user-not-found':
      return const UserNotFoundFailure();
    case 'wrong-password':
    case 'invalid-credential':
      return const InvalidCredentialsFailure();
    case 'invalid-email':
      return const AuthFailure('Format email tidak valid.');
    case 'user-disabled':
      return const AuthFailure('Akun ini dinonaktifkan.');
    case 'too-many-requests':
      return const AuthFailure(
        'Terlalu banyak percobaan. Tunggu sebentar lalu coba lagi.',
      );
    case 'network-request-failed':
      return const NetworkFailure();
    case 'operation-not-allowed':
      return const AuthFailure(
        'Metode masuk email/password belum diaktifkan di Firebase.',
      );
    default:
      return const AuthFailure();
  }
}

/// Versi yang menerima exception Firebase langsung (dipakai repository).
Failure mapFirebaseAuthException(FirebaseAuthException error) {
  debugPrint('FirebaseAuthException(${error.code}): ${error.message}');
  return authFailureFromCode(error.code);
}

/// Implementasi `IAuthRepository` Firebase-first.
///
/// Alur utama:
/// - **Firebase tersedia** (`remote != null`): login/daftar lewat Firebase
///   Auth, profil disimpan di `users/{uid}` + cache Hive `userBox`.
/// - **Firebase tidak tersedia** (`remote == null`, mis. desktop atau bootstrap
///   gagal): fallback lokal seperti fase UTS agar aplikasi tetap bisa dipakai.
///
/// Password **tidak pernah** disimpan di Hive/SharedPreferences. Key
/// `is_logged_in`/`user_id`/`user_name` hanya ditulis sebagai cermin agar fitur
/// lain (mis. `BabyNotifier`) tetap berjalan; keputusan auth selalu memakai
/// sesi Firebase.
class AuthRepositoryImpl implements IAuthRepository {
  const AuthRepositoryImpl(this._localDatasource, {this.remote});

  final AuthLocalDatasource _localDatasource;
  final AuthRemoteDatasource? remote;

  // ── Sesi & profil ───────────────────────────────────────────────────────

  @override
  Future<UserEntity?> getCurrentUser() async {
    final remote = this.remote;
    if (remote == null) return _readLocalSession();

    try {
      final authUser = await remote.currentUser();
      if (authUser == null) {
        // Token Firebase tidak ada/kedaluwarsa → bersihkan cermin sesi lokal.
        await _localDatasource.clearSession();
        return null;
      }
      return await _syncRemoteUser(authUser);
    } on Failure {
      rethrow;
    } catch (_) {
      throw const AuthFailure('Gagal memuat sesi pengguna.');
    }
  }

  @override
  Stream<UserEntity?> authStateChanges() {
    final remote = this.remote;
    if (remote == null) return const Stream<UserEntity?>.empty();

    return remote.authStateChanges().asyncMap((authUser) async {
      if (authUser == null) {
        // Sesi dicabut/kedaluwarsa di luar alur logout eksplisit: bersihkan
        // cermin lokal agar fitur non-auth tidak memakai uid lama.
        try {
          await _localDatasource.clearSession();
        } catch (error) {
          debugPrint('AuthRepository: gagal membersihkan sesi lokal — $error');
        }
        return null;
      }
      try {
        return await _syncRemoteUser(authUser);
      } catch (error) {
        debugPrint('AuthRepository: gagal menyinkronkan sesi — $error');
        return null;
      }
    });
  }

  // ── Login / register / reset password ────────────────────────────────────

  @override
  Future<UserEntity> login(String email, String password) async {
    final normalizedEmail = email.trim().toLowerCase();
    final remote = this.remote;

    if (remote == null) {
      return _loginLocal(normalizedEmail);
    }

    try {
      final authUser = await remote.login(
        email: normalizedEmail,
        password: password,
      );
      return await _syncRemoteUser(authUser);
    } on FirebaseAuthException catch (error) {
      throw mapFirebaseAuthException(error);
    } on Failure {
      rethrow;
    } catch (_) {
      throw const AuthFailure('Gagal masuk. Coba lagi.');
    }
  }

  @override
  Future<UserEntity> register(UserEntity user, String password) async {
    final normalizedEmail = user.email.trim().toLowerCase();
    final remote = this.remote;

    if (remote == null) {
      return _registerLocal(user, normalizedEmail);
    }

    try {
      final authUser = await remote.register(
        email: normalizedEmail,
        password: password,
        displayName: user.namaLengkap,
      );

      // Document ID = uid Firebase (bukan UUID lokal) agar data domain di
      // bawah `users/{uid}` konsisten.
      final entity = UserEntity(
        localId: authUser.uid,
        namaLengkap: user.namaLengkap.trim(),
        email: (authUser.email ?? normalizedEmail).toLowerCase(),
        nomorTelepon: user.nomorTelepon.trim(),
        lokasiKota: user.lokasiKota,
        createdAt: user.createdAt,
      );

      await _cacheUser(entity);
      await _localDatasource.saveSession(UserModel.fromEntity(entity));
      await _trySaveProfile(entity);
      return entity;
    } on FirebaseAuthException catch (error) {
      throw mapFirebaseAuthException(error);
    } on Failure {
      rethrow;
    } catch (_) {
      throw const AuthFailure('Registrasi gagal. Coba lagi.');
    }
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    final remote = this.remote;
    if (remote == null) {
      throw const AuthFailure(
        'Atur ulang password memerlukan koneksi ke server ImuniKita.',
      );
    }

    try {
      await remote.sendPasswordReset(email.trim().toLowerCase());
    } on FirebaseAuthException catch (error) {
      throw mapFirebaseAuthException(error);
    } on Failure {
      rethrow;
    } catch (_) {
      throw const AuthFailure('Gagal mengirim email atur ulang password.');
    }
  }

  // ── Profil & logout ──────────────────────────────────────────────────────

  @override
  Future<UserEntity> updateProfile(UserEntity user) async {
    final email = user.email.trim().toLowerCase();
    final entity = UserEntity(
      localId: user.localId,
      namaLengkap: user.namaLengkap.trim(),
      email: email,
      nomorTelepon: user.nomorTelepon.trim(),
      lokasiKota: user.lokasiKota,
      createdAt: user.createdAt,
    );

    // Penolakan email duplikat hanya relevan pada mode lokal: Firebase Auth
    // sudah menjamin email unik, dan akun lokal lama bukan akun Firebase.
    if (remote == null) {
      await _ensureEmailNotUsedLocally(entity);
    }

    try {
      final saved = await _localDatasource.put(UserModel.fromEntity(entity));
      // Agar sapaan/sesi di layar lain ikut memakai nama terbaru.
      await _localDatasource.setCurrentUserName(saved.namaLengkap);
      await _trySaveProfile(saved.toEntity());
      return saved.toEntity();
    } on Failure {
      rethrow;
    } catch (_) {
      throw const LocalStorageFailure('Gagal memperbarui profil akun.');
    }
  }

  @override
  Future<void> logout() async {
    final remote = this.remote;
    if (remote != null) {
      try {
        await remote.logout();
      } catch (error) {
        // signOut Firebase bersifat lokal dan jarang gagal; sesi lokal tetap
        // dibersihkan supaya tombol keluar tidak macet.
        debugPrint('AuthRepository: gagal signOut Firebase — $error');
      }
    }

    try {
      await _localDatasource.clearSession();
    } catch (_) {
      throw const LocalStorageFailure('Gagal mengakhiri sesi.');
    }
  }

  // ── Status sesi / onboarding ─────────────────────────────────────────────

  @override
  Future<bool> isLoggedIn() async {
    final remote = this.remote;
    if (remote == null) return _localDatasource.isLoggedIn();

    try {
      return await remote.currentUser() != null;
    } catch (_) {
      // Jangan blokir pengguna hanya karena SDK gagal membaca sesi.
      return _localDatasource.isLoggedIn();
    }
  }

  @override
  Future<bool> hasSeenOnboarding() => _localDatasource.hasSeenOnboarding();

  @override
  Future<void> markOnboardingSeen() => _localDatasource.setSeenOnboarding(true);

  // ── Helper: mode lokal (fallback UTS) ────────────────────────────────────

  Future<UserEntity?> _readLocalSession() async {
    try {
      final userId = await _localDatasource.currentUserId();
      if (userId == null) return null;

      final model = await _localDatasource.getById(userId);
      return model?.toEntity();
    } catch (_) {
      throw const LocalStorageFailure('Gagal memuat data akun.');
    }
  }

  Future<UserEntity> _loginLocal(String email) async {
    try {
      final semua = await _localDatasource.getAllUsers();
      if (semua.isEmpty) throw const NoAccountFailure();

      final model = await _localDatasource.getByEmail(email);
      if (model == null) throw const UserNotFoundFailure();

      // Catatan: password akun lokal UTS memang tidak pernah disimpan,
      // sehingga tidak bisa diverifikasi. Mode ini hanya dipakai saat
      // Firebase tidak tersedia (desktop / bootstrap gagal).
      await _localDatasource.saveSession(model);
      return model.toEntity();
    } on Failure {
      rethrow;
    } catch (_) {
      throw const LocalStorageFailure('Gagal memuat data akun.');
    }
  }

  Future<UserEntity> _registerLocal(
    UserEntity user,
    String normalizedEmail,
  ) async {
    try {
      final saved = await _localDatasource.put(
        UserModel.fromEntity(user.copyWith(email: normalizedEmail)),
      );
      await _localDatasource.saveSession(saved);
      return saved.toEntity();
    } on Failure {
      rethrow;
    } catch (_) {
      throw const LocalStorageFailure('Gagal menyimpan akun baru.');
    }
  }

  Future<void> _ensureEmailNotUsedLocally(UserEntity user) async {
    try {
      final semua = await _localDatasource.getAllUsers();
      final bentrok = semua.any(
        (u) =>
            u.localId != user.localId &&
            u.email.trim().toLowerCase() == user.email,
      );
      if (bentrok) {
        throw const ValidationFailure(
          'Email tersebut sudah dipakai akun lain di perangkat ini.',
        );
      }
    } on Failure {
      rethrow;
    } catch (_) {
      throw const LocalStorageFailure('Gagal memperbarui profil akun.');
    }
  }

  // ── Helper: sinkronisasi profil Firebase ↔ Hive ─────────────────────────

  /// Ambil profil cloud (bila bisa), simpan ke cache Hive, dan selaraskan
  /// cermin sesi. Kegagalan Firestore tidak menggagalkan login: profil lokal
  /// tetap dipakai agar aplikasi bisa dibuka offline.
  Future<UserEntity> _syncRemoteUser(RemoteAuthUser authUser) async {
    final cached = await _localDatasource.getById(authUser.uid);

    RemoteUserProfile? profile;
    try {
      profile = await remote?.fetchProfile(authUser.uid);
    } catch (error) {
      debugPrint(
        'AuthRepository: gagal membaca profil cloud (${authUser.uid}) — $error',
      );
    }

    final UserEntity entity;
    if (profile != null) {
      entity = UserEntity(
        localId: authUser.uid,
        namaLengkap: profile.namaLengkap.isEmpty
            ? _fallbackName(authUser, cached)
            : profile.namaLengkap,
        email: profile.email.isEmpty
            ? (authUser.email ?? cached?.email ?? '')
            : profile.email,
        nomorTelepon: profile.nomorTelepon,
        lokasiKota: profile.lokasiKota,
        createdAt: profile.createdAt,
      );
      await _cacheUser(entity);
    } else if (cached != null) {
      entity = cached.toEntity();
    } else {
      entity = UserEntity(
        localId: authUser.uid,
        namaLengkap: _fallbackName(authUser, null),
        email: authUser.email ?? '',
        nomorTelepon: '',
        createdAt: DateTime.now(),
      );
      await _cacheUser(entity);
      // Dokumen profil belum ada (mis. registrasi saat offline) → coba buat.
      await _trySaveProfile(entity);
    }

    await _localDatasource.saveSession(UserModel.fromEntity(entity));
    return entity;
  }

  Future<void> _cacheUser(UserEntity entity) async {
    await _localDatasource.put(UserModel.fromEntity(entity));
  }

  /// Simpan profil ke `users/{uid}` secara best-effort.
  ///
  /// Firestore bisa menolak (rules belum dideploy pada Tahap 3) atau gagal
  /// karena offline. Profil lokal sudah tersimpan, jadi kegagalan ini hanya
  /// dicatat — antrean sinkronisasi penuh menyusul di Tahap 5.
  Future<void> _trySaveProfile(UserEntity entity) async {
    final remote = this.remote;
    if (remote == null) return;

    final now = DateTime.now();
    try {
      await remote.saveProfile(
        entity.localId,
        RemoteUserProfile(
          namaLengkap: entity.namaLengkap,
          email: entity.email,
          nomorTelepon: entity.nomorTelepon,
          lokasiKota: entity.lokasiKota,
          createdAt: entity.createdAt,
          updatedAt: now,
          schemaVersion: _profileSchemaVersion,
        ),
      );
    } catch (error) {
      debugPrint(
        'AuthRepository: profil tersimpan lokal, gagal sinkron ke cloud — $error',
      );
    }
  }

  String _fallbackName(RemoteAuthUser authUser, UserModel? cached) {
    final displayName = authUser.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) return displayName;

    final cachedName = cached?.namaLengkap.trim();
    if (cachedName != null && cachedName.isNotEmpty) return cachedName;

    final email = authUser.email;
    if (email != null && email.contains('@')) {
      return email.split('@').first;
    }
    return 'Pengguna ImuniKita';
  }
}
