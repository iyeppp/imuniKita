import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:imunikita/core/constants/app_constants.dart';
import 'package:imunikita/core/errors/failures.dart';
import 'package:imunikita/core/services/local_storage_service.dart';
import 'package:imunikita/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:imunikita/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:imunikita/features/auth/data/models/user_model.dart';
import 'package:imunikita/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:imunikita/features/auth/domain/entities/user_entity.dart';
import 'package:imunikita/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:imunikita/features/auth/domain/usecases/login_usecase.dart';
import 'package:imunikita/features/auth/presentation/providers/auth_provider.dart';
import 'package:imunikita/features/auth/presentation/screens/login_screen.dart';
import 'package:imunikita/features/auth/presentation/screens/register_screen.dart';
import 'package:imunikita/hive_registrar.g.dart';
import 'package:imunikita/injection/dependency_injection.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// `FirebaseAuthException` punya konstruktor `@protected`, sehingga hanya bisa
/// dipakai dari subclass. Subclass ini membuat fake remote dapat melempar
/// exception dengan kode Firebase asli — repository tetap diuji lewat jalur
/// pemetaan error yang sesungguhnya.
class _TestFirebaseAuthException extends FirebaseAuthException {
  _TestFirebaseAuthException(String code) : super(code: code);
}

UserEntity _user({
  String localId = 'uid-1',
  String nama = 'Ibu Sari',
  String email = 'sari@email.com',
}) {
  return UserEntity(
    localId: localId,
    namaLengkap: nama,
    email: email,
    nomorTelepon: '081234567890',
    lokasiKota: 'Bandung',
    createdAt: DateTime(2026, 9, 1),
  );
}

/// Fake remote datasource tanpa Firebase — semua state disimpan di memori.
class _FakeRemoteAuthDatasource implements AuthRemoteDatasource {
  final Map<String, String> _passwords = {};
  final Map<String, RemoteAuthUser> _usersByEmail = {};
  final StreamController<RemoteAuthUser?> _authChanges =
      StreamController<RemoteAuthUser?>.broadcast(sync: true);

  final Map<String, RemoteUserProfile> profiles = {};
  RemoteAuthUser? _current;
  bool failProfileFetch = false;
  bool failProfileSave = false;

  void seed({
    required String email,
    required String password,
    String uid = 'uid-1',
    String nama = 'Ibu Sari',
  }) {
    final user = RemoteAuthUser(uid: uid, email: email, displayName: nama);
    _usersByEmail[email] = user;
    _passwords[email] = password;
    profiles[uid] = RemoteUserProfile(
      namaLengkap: nama,
      email: email,
      nomorTelepon: '081234567890',
      lokasiKota: 'Bandung',
      createdAt: DateTime(2026, 9, 1),
      updatedAt: DateTime(2026, 9, 1),
    );
  }

  void emitSession(RemoteAuthUser? user) {
    _current = user;
    _authChanges.add(user);
  }

  Future<void> dispose() => _authChanges.close();

  @override
  Future<RemoteAuthUser?> currentUser() async => _current;

  @override
  Stream<RemoteAuthUser?> authStateChanges() => _authChanges.stream;

  @override
  Future<RemoteAuthUser> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    if (_usersByEmail.containsKey(email)) {
      throw _TestFirebaseAuthException('email-already-in-use');
    }
    if (password.length < 6) {
      throw _TestFirebaseAuthException('weak-password');
    }

    final uid = 'uid-${_usersByEmail.length + 1}';
    final user = RemoteAuthUser(
      uid: uid,
      email: email,
      displayName: displayName,
    );
    _usersByEmail[email] = user;
    _passwords[email] = password;
    _current = user;
    return user;
  }

  @override
  Future<RemoteAuthUser> login({
    required String email,
    required String password,
  }) async {
    final user = _usersByEmail[email];
    if (user == null) throw _TestFirebaseAuthException('user-not-found');
    if (_passwords[email] != password) {
      throw _TestFirebaseAuthException('wrong-password');
    }

    _current = user;
    return user;
  }

  @override
  Future<void> logout() async {
    _current = null;
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    if (!_usersByEmail.containsKey(email)) {
      throw _TestFirebaseAuthException('user-not-found');
    }
  }

  @override
  Future<RemoteUserProfile?> fetchProfile(String uid) async {
    if (failProfileFetch) {
      throw Exception('offline');
    }
    return profiles[uid];
  }

  @override
  Future<void> saveProfile(
    String uid,
    RemoteUserProfile profile, {
    bool merge = true,
  }) async {
    if (failProfileSave) {
      throw Exception('offline');
    }
    profiles[uid] = profile;
  }
}

/// Fake repository untuk widget test login/register (tanpa Firebase).
class _FakeAuthRepository implements IAuthRepository {
  _FakeAuthRepository({this.loginFailure, this.registerFailure});

  final Failure? loginFailure;
  final Failure? registerFailure;
  final StreamController<UserEntity?> _authChanges =
      StreamController<UserEntity?>.broadcast(sync: true);

  UserEntity? _current;

  void emitSession(UserEntity? user) {
    _current = user;
    _authChanges.add(user);
  }

  @override
  Future<UserEntity?> getCurrentUser() async => _current;

  @override
  Stream<UserEntity?> authStateChanges() => _authChanges.stream;

  @override
  Future<UserEntity> login(String email, String password) async {
    if (loginFailure != null) throw loginFailure!;
    final user = _user(email: email);
    _current = user;
    _authChanges.add(user);
    return user;
  }

  @override
  Future<UserEntity> register(UserEntity user, String password) async {
    if (registerFailure != null) throw registerFailure!;
    _current = user;
    _authChanges.add(user);
    return user;
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    if (loginFailure != null) throw loginFailure!;
  }

  @override
  Future<UserEntity> updateProfile(UserEntity user) async {
    _current = user;
    return user;
  }

  @override
  Future<void> logout() async {
    _current = null;
    _authChanges.add(null);
  }

  @override
  Future<bool> isLoggedIn() async => _current != null;

  @override
  Future<bool> hasSeenOnboarding() async => true;

  @override
  Future<void> markOnboardingSeen() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    tempDir = await Directory.systemTemp.createTemp('imunikita_auth_test');
    Hive.init(tempDir.path);
    Hive.registerAdapters();
  });

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  setUp(() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await Hive.deleteBoxFromDisk(AppConstants.usersBox);
  });

  Future<Box<UserModel>> usersBox() =>
      Hive.openBox<UserModel>(AppConstants.usersBox);

  group('authFailureFromCode — pemetaan error Firebase (B2-7)', () {
    test('email sudah dipakai', () {
      expect(
        authFailureFromCode('email-already-in-use'),
        isA<EmailAlreadyInUseFailure>(),
      );
    });

    test('password salah dan kredensial tidak valid', () {
      expect(
        authFailureFromCode('wrong-password'),
        isA<InvalidCredentialsFailure>(),
      );
      expect(
        authFailureFromCode('invalid-credential'),
        isA<InvalidCredentialsFailure>(),
      );
    });

    test('email tidak ditemukan', () {
      expect(authFailureFromCode('user-not-found'), isA<UserNotFoundFailure>());
    });

    test('password lemah', () {
      expect(authFailureFromCode('weak-password'), isA<WeakPasswordFailure>());
    });

    test('masalah jaringan', () {
      expect(
        authFailureFromCode('network-request-failed'),
        isA<NetworkFailure>(),
      );
    });

    test('kode tak dikenal tetap menjadi AuthFailure berbahasa Indonesia', () {
      final failure = authFailureFromCode('something-new');
      expect(failure, isA<AuthFailure>());
      expect(failure.message, contains('Coba lagi'));
    });
  });

  group('AuthRepositoryImpl — mode Firebase (fake remote) (B2-1/B2-2)', () {
    late _FakeRemoteAuthDatasource remote;
    late AuthRepositoryImpl repository;

    setUp(() {
      remote = _FakeRemoteAuthDatasource();
      repository = AuthRepositoryImpl(
        const AuthLocalDatasource(),
        remote: remote,
      );
    });

    tearDown(() => remote.dispose());

    test(
      'register memakai uid Firebase sebagai document ID & cache Hive',
      () async {
        final saved = await repository.register(
          _user(email: 'baru@email.com', nama: 'Ibu Baru'),
          'rahasia123',
        );

        expect(saved.localId, 'uid-1');
        expect(saved.namaLengkap, 'Ibu Baru');
        expect(remote.profiles['uid-1']?.namaLengkap, 'Ibu Baru');

        final box = await usersBox();
        expect(box.get('uid-1'), isNotNull);

        // Cermin sesi ditulis untuk fitur lain, bukan sumber kebenaran auth.
        expect(await LocalStorageService.getCurrentUserId(), 'uid-1');
        expect(await LocalStorageService.isLoggedIn(), isTrue);
      },
    );

    test('login salah password → InvalidCredentialsFailure', () async {
      remote.seed(email: 'sari@email.com', password: 'benar123');

      expect(
        () => repository.login('sari@email.com', 'salah'),
        throwsA(isA<InvalidCredentialsFailure>()),
      );
    });

    test('login email tidak terdaftar → UserNotFoundFailure', () async {
      expect(
        () => repository.login('tidak@ada.com', 'rahasia123'),
        throwsA(isA<UserNotFoundFailure>()),
      );
    });

    test('register email sudah dipakai → EmailAlreadyInUseFailure', () async {
      remote.seed(email: 'sari@email.com', password: 'benar123');

      expect(
        () => repository.register(_user(), 'rahasia123'),
        throwsA(isA<EmailAlreadyInUseFailure>()),
      );
    });

    test('register password lemah → WeakPasswordFailure', () async {
      expect(
        () => repository.register(_user(email: 'baru@email.com'), '123'),
        throwsA(isA<WeakPasswordFailure>()),
      );
    });

    test('login tetap berhasil saat profil cloud tidak bisa dibaca', () async {
      remote.seed(email: 'sari@email.com', password: 'benar123');
      remote.failProfileFetch = true;

      final user = await repository.login('sari@email.com', 'benar123');

      // Profil diambil dari cache lokal (belum ada) → fallback displayName.
      expect(user.localId, 'uid-1');
      expect(user.namaLengkap, 'Ibu Sari');
      expect(await LocalStorageService.isLoggedIn(), isTrue);
    });

    test('profil tersimpan lokal walau Firestore menolak', () async {
      remote.failProfileSave = true;
      final user = await repository.register(
        _user(email: 'baru@email.com', nama: 'Ibu Baru'),
        'rahasia123',
      );

      final box = await usersBox();
      expect(box.get(user.localId)?.namaLengkap, 'Ibu Baru');
    });

    test('getCurrentUser mengembalikan profil cloud + cache', () async {
      remote.seed(email: 'sari@email.com', password: 'benar123');
      await repository.login('sari@email.com', 'benar123');

      final user = await repository.getCurrentUser();

      expect(user, isNotNull);
      expect(user!.localId, 'uid-1');
      expect(user.email, 'sari@email.com');
      expect(user.lokasiKota, 'Bandung');
    });

    test('getCurrentUser membaca cache saat offline', () async {
      remote.seed(email: 'sari@email.com', password: 'benar123');
      await repository.login('sari@email.com', 'benar123');
      remote.failProfileFetch = true;

      final user = await repository.getCurrentUser();

      expect(user?.namaLengkap, 'Ibu Sari');
    });

    test('logout menghapus sesi tetapi cache akun tetap ada', () async {
      remote.seed(email: 'sari@email.com', password: 'benar123');
      await repository.login('sari@email.com', 'benar123');

      await repository.logout();

      expect(await LocalStorageService.isLoggedIn(), isFalse);
      expect(await LocalStorageService.getCurrentUserId(), isNull);
      final box = await usersBox();
      expect(box.length, 1);
    });

    test('updateProfile menyimpan ke cache & Firestore', () async {
      remote.seed(email: 'sari@email.com', password: 'benar123');
      final user = await repository.login('sari@email.com', 'benar123');

      await repository.updateProfile(
        UserEntity(
          localId: user.localId,
          namaLengkap: 'Ibu Sari Wijaya',
          email: 'sari.baru@email.com',
          nomorTelepon: '089999999999',
          lokasiKota: 'Jakarta',
          createdAt: user.createdAt,
        ),
      );

      expect(remote.profiles['uid-1']?.namaLengkap, 'Ibu Sari Wijaya');
      expect(await LocalStorageService.getCurrentUserName(), 'Ibu Sari Wijaya');
    });

    test('authStateChanges memancarkan profil saat sesi berubah', () async {
      remote.seed(email: 'sari@email.com', password: 'benar123');

      final firstEvent = repository.authStateChanges().first;
      remote.emitSession(
        const RemoteAuthUser(
          uid: 'uid-1',
          email: 'sari@email.com',
          displayName: 'Ibu Sari',
        ),
      );

      final user = await firstEvent;

      expect(user?.localId, 'uid-1');
      expect(user?.namaLengkap, 'Ibu Sari');
    });

    test('lupa password mengirim email untuk akun terdaftar', () async {
      remote.seed(email: 'sari@email.com', password: 'benar123');

      await repository.sendPasswordReset('sari@email.com');
    });
  });

  group('AuthRepositoryImpl — fallback lokal tanpa Firebase (B2-2)', () {
    test('register lalu login memakai akun Hive', () async {
      final repository = AuthRepositoryImpl(const AuthLocalDatasource());

      final saved = await repository.register(
        _user(email: 'lokal@email.com'),
        'rahasia123',
      );
      await repository.logout();

      final login = await repository.login('lokal@email.com', 'apa saja');

      expect(login.localId, saved.localId);
      expect(await LocalStorageService.isLoggedIn(), isTrue);
    });

    test('login saat belum ada akun → NoAccountFailure', () async {
      final repository = AuthRepositoryImpl(const AuthLocalDatasource());

      expect(
        () => repository.login('tidak@ada.com', 'rahasia123'),
        throwsA(isA<NoAccountFailure>()),
      );
    });
  });

  group('LoginUseCase — status login', () {
    test('memetakan keberhasilan menjadi sukses', () async {
      final useCase = LoginUseCase(_FakeAuthRepository());

      final result = await useCase.execute('sari@email.com', 'rahasia123');

      expect(result.status, LoginStatus.sukses);
      expect(result.user, isNotNull);
    });

    test('memetakan password salah menjadi sandiSalah', () async {
      final useCase = LoginUseCase(
        _FakeAuthRepository(loginFailure: const InvalidCredentialsFailure()),
      );

      final result = await useCase.execute('sari@email.com', 'salah');

      expect(result.status, LoginStatus.sandiSalah);
    });

    test('memetakan email tidak terdaftar', () async {
      final useCase = LoginUseCase(
        _FakeAuthRepository(loginFailure: const UserNotFoundFailure()),
      );

      final result = await useCase.execute('tidak@ada.com', 'rahasia123');

      expect(result.status, LoginStatus.emailTidakDitemukan);
    });

    test('memetakan belum ada akun', () async {
      final useCase = LoginUseCase(
        _FakeAuthRepository(loginFailure: const NoAccountFailure()),
      );

      final result = await useCase.execute('tidak@ada.com', 'rahasia123');

      expect(result.status, LoginStatus.belumAdaAkun);
    });
  });

  group('CurrentUserProvider reaktif (B2-6)', () {
    test('state mengikuti authStateChanges tanpa invalidate manual', () async {
      final fake = _FakeAuthRepository();
      final container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(fake)],
      );
      addTearDown(container.dispose);

      expect(await container.read(currentUserProvider.future), isNull);

      final user = _user();
      fake.emitSession(user);
      await Future<void>.delayed(Duration.zero);

      expect(container.read(currentUserProvider).value?.localId, user.localId);
    });
  });

  group('Widget — login & register (B2-8)', () {
    testWidgets('login salah password menampilkan pesan spesifik', (
      tester,
    ) async {
      final fake = _FakeAuthRepository(
        loginFailure: const InvalidCredentialsFailure(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [authRepositoryProvider.overrideWithValue(fake)],
          child: const MaterialApp(home: LoginScreen()),
        ),
      );

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'sari@email.com',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'salah123');

      await tester.tap(find.text('Masuk'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pump();

      expect(
        find.text('Password salah. Periksa kembali lalu coba lagi.'),
        findsOneWidget,
      );
    });

    testWidgets('register menampilkan email sudah dipakai', (tester) async {
      final fake = _FakeAuthRepository(
        registerFailure: const EmailAlreadyInUseFailure(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [authRepositoryProvider.overrideWithValue(fake)],
          child: const MaterialApp(home: RegisterScreen()),
        ),
      );

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Ibu Baru');
      await tester.enterText(fields.at(1), 'sari@email.com');
      await tester.enterText(fields.at(2), '081234567890');
      await tester.enterText(fields.at(3), 'Bandung');
      await tester.enterText(fields.at(4), 'rahasia123');
      await tester.enterText(fields.at(5), 'rahasia123');

      // Form registrasi lebih tinggi dari viewport test (800x600).
      await tester.ensureVisible(find.text('Daftar'));
      await tester.pump();

      await tester.tap(find.text('Daftar'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pump();

      expect(
        find.text('Email ini sudah terdaftar. Silakan masuk.'),
        findsOneWidget,
      );
    });
  });
}
