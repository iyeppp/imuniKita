import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imunikita/core/services/photo_storage_service.dart';
import 'package:imunikita/widgets/baby_avatar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('B7-5 & B7-7 BabyAvatar Widget Tests', () {
    testWidgets('BabyAvatar menampilkan inisial saat photoPath null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BabyAvatar(name: 'Ahmad'),
          ),
        ),
      );

      expect(find.text('A'), findsOneWidget);
    });

    testWidgets('BabyAvatar menampilkan inisial saat photoPath mengarah ke file tidak ada', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BabyAvatar(
              name: 'Aisyah',
              photoPath: '/non_existent_path/photo.jpg',
            ),
          ),
        ),
      );

      expect(find.text('A'), findsOneWidget);
    });

    testWidgets('BabyAvatar menangani nama kosong dengan inisial fallback "?"', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BabyAvatar(name: ' '),
          ),
        ),
      );

      expect(find.text('?'), findsOneWidget);
    });
  });

  group('B7-2, B7-4 & B7-7 PhotoStorageService Unit Tests', () {
    late Directory tempDocsDir;

    setUp(() async {
      tempDocsDir = await Directory.systemTemp.createTemp('test_baby_photos_');
    });

    tearDown(() async {
      if (await tempDocsDir.exists()) {
        await tempDocsDir.delete(recursive: true);
      }
    });

    test('savePhoto menyalin file ke folder <docsDir>/baby_photos/<babyId>.jpg', () async {
      final service = PhotoStorageService(
        getDocsDir: () async => tempDocsDir,
      );

      final sourceFile = File('${tempDocsDir.path}/temp_source.jpg');
      await sourceFile.writeAsString('fake image data');

      final savedPath = await service.savePhoto(sourceFile, 'baby-123');

      expect(savedPath, equals('${tempDocsDir.path}/baby_photos/baby-123.jpg'));
      final savedFile = File(savedPath);
      expect(await savedFile.exists(), isTrue);
      expect(await savedFile.readAsString(), equals('fake image data'));
    });

    test('deletePhoto menghapus file lokal jika ada dan aman jika path null/kosong', () async {
      final service = PhotoStorageService(
        getDocsDir: () async => tempDocsDir,
      );

      final photoFile = File('${tempDocsDir.path}/baby_photos/baby-456.jpg');
      await photoFile.create(recursive: true);
      await photoFile.writeAsString('test photo');

      expect(await photoFile.exists(), isTrue);

      await service.deletePhoto(photoFile.path);

      expect(await photoFile.exists(), isFalse);

      // Panggilan tambahan untuk null / non-existent file tidak melempar exception
      await service.deletePhoto(null);
      await service.deletePhoto('');
      await service.deletePhoto('/path/not/exist.jpg');
    });
  });
}
