import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Data akun minimal yang dibutuhkan lapisan domain dari Firebase Auth.
class RemoteAuthUser {
  const RemoteAuthUser({
    required this.uid,
    this.email,
    this.displayName,
    this.emailVerified = false,
  });

  final String uid;
  final String? email;
  final String? displayName;
  final bool emailVerified;
}

/// Profil pengguna sesuai dokumen `users/{uid}` di Firestore.
class RemoteUserProfile {
  const RemoteUserProfile({
    required this.namaLengkap,
    required this.email,
    required this.nomorTelepon,
    this.lokasiKota,
    required this.createdAt,
    required this.updatedAt,
    this.schemaVersion = 1,
  });

  final String namaLengkap;
  final String email;
  final String nomorTelepon;
  final String? lokasiKota;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int schemaVersion;
}

/// Kontrak remote datasource autentikasi.
abstract class AuthRemoteDatasource {
  /// Pengguna yang sedang login menurut SDK (null bila belum masuk).
  Future<RemoteAuthUser?> currentUser();

  /// Stream perubahan sesi (login/logout dari perangkat atau token kedaluwarsa).
  Stream<RemoteAuthUser?> authStateChanges();

  /// Daftarkan akun baru di Firebase Auth.
  Future<RemoteAuthUser> register({
    required String email,
    required String password,
    String? displayName,
  });

  /// Masuk dengan email + password.
  Future<RemoteAuthUser> login({
    required String email,
    required String password,
  });

  Future<void> logout();

  /// Kirim email atur ulang password.
  Future<void> sendPasswordReset(String email);

  /// Baca dokumen `users/{uid}` — `null` bila belum ada.
  Future<RemoteUserProfile?> fetchProfile(String uid);

  /// Tulis/merge dokumen `users/{uid}`.
  Future<void> saveProfile(
    String uid,
    RemoteUserProfile profile, {
    bool merge = true,
  });
}

/// Implementasi [AuthRemoteDatasource] di atas Firebase Auth + Cloud Firestore.
class FirebaseAuthRemoteDatasource implements AuthRemoteDatasource {
  const FirebaseAuthRemoteDatasource();

  static const String usersCollection = 'users';

  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  @override
  Future<RemoteAuthUser?> currentUser() async =>
      _toRemoteUser(_auth.currentUser);

  @override
  Stream<RemoteAuthUser?> authStateChanges() =>
      _auth.authStateChanges().map(_toRemoteUser);

  @override
  Future<RemoteAuthUser> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;
    if (user == null) {
      throw StateError('Pendaftaran tidak mengembalikan data pengguna.');
    }

    final nama = displayName?.trim();
    if (nama != null && nama.isNotEmpty) {
      await user.updateDisplayName(nama);
    }

    return RemoteAuthUser(
      uid: user.uid,
      email: user.email,
      displayName: nama?.isNotEmpty == true ? nama : user.displayName,
      emailVerified: user.emailVerified,
    );
  }

  @override
  Future<RemoteAuthUser> login({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;
    if (user == null) {
      throw StateError('Login tidak mengembalikan data pengguna.');
    }
    return _toRemoteUser(user)!;
  }

  @override
  Future<void> logout() => _auth.signOut();

  @override
  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  @override
  Future<RemoteUserProfile?> fetchProfile(String uid) async {
    final snapshot = await _firestore
        .collection(usersCollection)
        .doc(uid)
        .get();
    final data = snapshot.data();
    if (data == null) return null;

    return RemoteUserProfile(
      namaLengkap: (data['namaLengkap'] as String?)?.trim() ?? '',
      email: (data['email'] as String?)?.trim() ?? '',
      nomorTelepon: (data['nomorTelepon'] as String?)?.trim() ?? '',
      lokasiKota: (data['lokasiKota'] as String?)?.trim(),
      createdAt: _toDateTime(data['createdAt']),
      updatedAt: _toDateTime(data['updatedAt']),
      schemaVersion: (data['schemaVersion'] as num?)?.toInt() ?? 1,
    );
  }

  @override
  Future<void> saveProfile(
    String uid,
    RemoteUserProfile profile, {
    bool merge = true,
  }) async {
    final data = <String, dynamic>{
      'namaLengkap': profile.namaLengkap,
      'email': profile.email,
      'nomorTelepon': profile.nomorTelepon,
      'lokasiKota': profile.lokasiKota,
      'createdAt': Timestamp.fromDate(profile.createdAt),
      'updatedAt': Timestamp.fromDate(profile.updatedAt),
      'schemaVersion': profile.schemaVersion,
    };

    await _firestore
        .collection(usersCollection)
        .doc(uid)
        .set(data, SetOptions(merge: merge));
  }

  RemoteAuthUser? _toRemoteUser(User? user) {
    if (user == null) return null;
    return RemoteAuthUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      emailVerified: user.emailVerified,
    );
  }

  DateTime _toDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }
}
