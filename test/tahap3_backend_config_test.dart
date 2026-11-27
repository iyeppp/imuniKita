import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Test unit — verifikasi keberadaan & isi file konfigurasi backend.
void main() {
  // Cari root project (naik dari folder `test/`)
  late Directory projectRoot;

  setUpAll(() {
    // Test dijalankan dari root project
    projectRoot = Directory.current;
    // Jika dijalankan dari subfolder, coba naik
    if (!File('${projectRoot.path}/pubspec.yaml').existsSync()) {
      projectRoot = projectRoot.parent;
    }
  });

  group('backend/ — file konfigurasi Firebase', () {
    test('firebase.json ada dan berisi konfigurasi firestore', () {
      final file = File('${projectRoot.path}/backend/firebase.json');
      expect(file.existsSync(), isTrue, reason: 'backend/firebase.json harus ada');

      final content = file.readAsStringSync();
      expect(content, contains('"firestore"'));
      expect(content, contains('"rules"'));
      expect(content, contains('"indexes"'));
      expect(content, contains('"emulators"'));
    });

    test('.firebaserc ada dan berisi project dev & prod', () {
      final file = File('${projectRoot.path}/backend/.firebaserc');
      expect(file.existsSync(), isTrue, reason: 'backend/.firebaserc harus ada');

      final content = file.readAsStringSync();
      expect(content, contains('imunikita-dev-f'));
      expect(content, contains('imunikita-prod-f'));
    });

    test('firestore.indexes.json ada', () {
      final file = File('${projectRoot.path}/backend/firestore.indexes.json');
      expect(file.existsSync(), isTrue);

      final content = file.readAsStringSync();
      expect(content, contains('"indexes"'));
    });

    test('package.json ada dan berisi script rules test & deploy', () {
      final file = File('${projectRoot.path}/backend/package.json');
      expect(file.existsSync(), isTrue);

      final content = file.readAsStringSync();
      expect(content, contains('test:rules'));
      expect(content, contains('deploy:dev'));
      expect(content, contains('deploy:prod'));
      expect(content, contains('vitest'));
    });
  });

  group('backend/firestore.rules — konten security rules', () {
    late String rulesContent;

    setUpAll(() {
      final file = File('${projectRoot.path}/backend/firestore.rules');
      expect(file.existsSync(), isTrue, reason: 'firestore.rules harus ada');
      rulesContent = file.readAsStringSync();
    });

    test('rules_version adalah 2', () {
      expect(rulesContent, contains("rules_version = '2'"));
    });

    test('ada fungsi signedIn() dan isOwner()', () {
      expect(rulesContent, contains('function signedIn()'));
      expect(rulesContent, contains('function isOwner(uid)'));
    });

    test('ada validasi user (validUser)', () {
      expect(rulesContent, contains('function validUser(d)'));
      expect(rulesContent, contains('namaLengkap'));
      expect(rulesContent, contains('email'));
      expect(rulesContent, contains('nomorTelepon'));
    });

    test('ada validasi baby (validBaby)', () {
      expect(rulesContent, contains('function validBaby(d)'));
      expect(rulesContent, contains('namaAnak'));
      expect(rulesContent, contains('tanggalLahir'));
      expect(rulesContent, contains('jenisKelamin'));
    });

    test('schemaVersion == 1 diwajibkan', () {
      expect(rulesContent, contains('schemaVersion == 1'));
    });

    test('delete user dilarang dari klien', () {
      // Harus ada `allow delete: if false` untuk users/{uid}
      expect(rulesContent, contains('allow delete: if false'));
    });

    test('ada rule untuk users/{uid}/babies/{babyId}', () {
      expect(rulesContent, contains('match /babies/{babyId}'));
    });

    test('ada wildcard rule untuk subkoleksi bayi', () {
      // {sub=**} untuk cascade read/write subkoleksi
      expect(rulesContent, contains('{sub=**}'));
    });

    test('ada rule untuk quizScores, devices, syncMeta', () {
      expect(rulesContent, contains('match /quizScores/{quizId}'));
      expect(rulesContent, contains('match /devices/{token}'));
      expect(rulesContent, contains('match /syncMeta/{docId}'));
    });

    test('field yang diizinkan di user sesuai skema', () {
      for (final field in [
        'namaLengkap',
        'email',
        'nomorTelepon',
        'lokasiKota',
        'activeBabyId',
        'createdAt',
        'updatedAt',
        'schemaVersion',
      ]) {
        expect(rulesContent, contains("'$field'"),
            reason: 'Field $field harus ada di daftar keys hasOnly');
      }
    });

    test('jenisKelamin hanya Laki-laki atau Perempuan', () {
      expect(rulesContent, contains("'Laki-laki'"));
      expect(rulesContent, contains("'Perempuan'"));
    });
  });

  group('backend/tests/ — rules test file', () {
    test('firestore.rules.test.ts ada dan berisi skenario test', () {
      final file = File(
          '${projectRoot.path}/backend/tests/rules/firestore.rules.test.ts');
      expect(file.existsSync(), isTrue);

      final content = file.readAsStringSync();
      // Harus menggunakan @firebase/rules-unit-testing
      expect(content, contains('@firebase/rules-unit-testing'));
      // Harus punya describe blocks
      expect(content, contains('describe('));
      // Harus punya assertFails dan assertSucceeds
      expect(content, contains('assertFails'));
      expect(content, contains('assertSucceeds'));
    });
  });

  group('lib/core/firestore/ — recursive_delete.dart', () {
    test('file recursive_delete.dart ada', () {
      final file = File(
          '${projectRoot.path}/lib/core/firestore/recursive_delete.dart');
      expect(file.existsSync(), isTrue);

      final content = file.readAsStringSync();
      expect(content, contains('deleteBabyCascade'));
      expect(content, contains('deleteCollectionInBatches'));
      expect(content, contains('babyChildCollections'));
      expect(content, contains('firestoreBatchLimit'));
    });
  });
}

