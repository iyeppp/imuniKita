import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:imunikita/features/baby_profile/domain/entities/baby_entity.dart';
import 'package:imunikita/features/baby_profile/domain/repositories/i_baby_repository.dart';
import 'package:imunikita/features/baby_profile/domain/usecases/delete_baby_usecase.dart';

/// Test unit Tahap 3 — `DeleteBabyUseCase` dengan `remoteCascade`.
///
/// Menguji:
/// 1. Hapus lokal selalu dipanggil.
/// 2. `remoteCascade` dipanggil bila disediakan.
/// 3. `remoteCascade` **tidak memblok** penghapusan lokal (unawaited).
/// 4. Kegagalan `remoteCascade` tidak menyebabkan `execute` gagal.
/// 5. Tanpa `remoteCascade` (null), use case tetap berjalan normal.
void main() {
  group('DeleteBabyUseCase', () {
    late _FakeBabyRepository fakeRepo;

    setUp(() {
      fakeRepo = _FakeBabyRepository();
    });

    test('memanggil repository.deleteBaby dengan babyId yang benar', () async {
      final useCase = DeleteBabyUseCase(fakeRepo);

      await useCase.execute('baby-123');

      expect(fakeRepo.deletedIds, ['baby-123']);
    });

    test('remoteCascade dipanggil dengan babyId yang sama', () async {
      String? cascadedId;
      final completer = Completer<void>();

      final useCase = DeleteBabyUseCase(
        fakeRepo,
        remoteCascade: (babyId) async {
          cascadedId = babyId;
          completer.complete();
        },
      );

      await useCase.execute('baby-456');

      // Tunggu remoteCascade selesai (karena unawaited, perlu yield)
      await completer.future;

      expect(cascadedId, 'baby-456');
      expect(fakeRepo.deletedIds, ['baby-456']);
    });

    test('tanpa remoteCascade (null), execute tetap sukses', () async {
      final useCase = DeleteBabyUseCase(fakeRepo, remoteCascade: null);

      // Tidak boleh throw
      await expectLater(useCase.execute('baby-789'), completes);
      expect(fakeRepo.deletedIds, ['baby-789']);
    });

    test('repository.deleteBaby gagal → execute gagal (remoteCascade tidak dipanggil)', () async {
      fakeRepo.shouldFail = true;
      bool cascadeCalled = false;

      final useCase = DeleteBabyUseCase(
        fakeRepo,
        remoteCascade: (_) async {
          cascadeCalled = true;
        },
      );

      await expectLater(
        () => useCase.execute('baby-fail'),
        throwsA(isA<Exception>()),
      );

      // remoteCascade tidak boleh dipanggil karena deleteBaby gagal duluan
      expect(cascadeCalled, isFalse);
      expect(fakeRepo.deletedIds, isEmpty);
    });

    test('remoteCascade gagal → execute tetap sukses (fire-and-forget)', () async {
      final cascadeCompleter = Completer<void>();

      final useCase = DeleteBabyUseCase(
        fakeRepo,
        remoteCascade: (babyId) async {
          cascadeCompleter.complete();
          throw Exception('Firestore unreachable');
        },
      );

      // execute tidak boleh throw meskipun remoteCascade gagal
      await useCase.execute('baby-offline');

      // Tunggu cascade selesai agar Zone error tercatat
      await cascadeCompleter.future;

      // Penghapusan lokal tetap sukses
      expect(fakeRepo.deletedIds, ['baby-offline']);
    });

    test('remoteCascade lambat → execute kembali lebih dulu (non-blocking)', () async {
      final order = <String>[];
      final cascadeCompleter = Completer<void>();

      final useCase = DeleteBabyUseCase(
        fakeRepo,
        remoteCascade: (babyId) async {
          // Simulasi operasi lambat (network call)
          await Future.delayed(const Duration(milliseconds: 50));
          order.add('cascade-done');
          cascadeCompleter.complete();
        },
      );

      await useCase.execute('baby-slow');
      order.add('execute-returned');

      // execute harus kembali sebelum cascade selesai
      expect(order, ['execute-returned']);

      // Setelah cascade selesai
      await cascadeCompleter.future;
      expect(order, ['execute-returned', 'cascade-done']);
    });

    test('multiple execute calls — setiap panggilan cascade independen', () async {
      final cascadedIds = <String>[];
      final completers = <Completer<void>>[];

      final useCase = DeleteBabyUseCase(
        fakeRepo,
        remoteCascade: (babyId) async {
          cascadedIds.add(babyId);
          final c = Completer<void>();
          completers.add(c);
          c.complete();
        },
      );

      await useCase.execute('baby-a');
      await useCase.execute('baby-b');

      // Yield agar unawaited futures selesai
      await Future<void>.delayed(Duration.zero);

      expect(fakeRepo.deletedIds, ['baby-a', 'baby-b']);
      expect(cascadedIds, ['baby-a', 'baby-b']);
    });
  });
}

// =============================================================================
// Fake repository — implementasi minimal tanpa Hive/Firestore.
// =============================================================================

class _FakeBabyRepository implements IBabyRepository {
  final List<String> deletedIds = [];
  bool shouldFail = false;

  @override
  Future<void> deleteBaby(String babyId) async {
    if (shouldFail) throw Exception('Delete failed');
    deletedIds.add(babyId);
  }

  @override
  Future<BabyEntity> addBaby(BabyEntity baby) async => baby;

  @override
  Future<List<BabyEntity>> getBabiesByUser(String userId) async => [];

  @override
  Future<BabyEntity?> getBabyById(String babyId) async => null;

  @override
  Future<BabyEntity> updateBaby(BabyEntity baby) async => baby;
}

