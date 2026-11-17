import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:imunikita/core/sync/sync_manager.dart';
import 'package:imunikita/core/sync/sync_outbox_model.dart';
import 'package:imunikita/core/sync/sync_queue.dart';
import 'package:imunikita/features/baby_profile/data/models/baby_model.dart';
import 'package:imunikita/hive_registrar.g.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Box<SyncOperationModel> outboxBox;
  late Box<BabyModel> babyBox;

  setUpAll(() async {
    Hive.init('./test/hive_sync_test_dir');
    Hive.registerAdapters();
  });

  setUp(() async {
    if (Hive.isBoxOpen('test_sync_outbox')) {
      await Hive.box<SyncOperationModel>('test_sync_outbox').clear();
    }
    if (Hive.isBoxOpen('test_baby_box')) {
      await Hive.box<BabyModel>('test_baby_box').clear();
    }

    outboxBox = await Hive.openBox<SyncOperationModel>('test_sync_outbox');
    babyBox = await Hive.openBox<BabyModel>('test_baby_box');
    await outboxBox.clear();
    await babyBox.clear();
  });

  tearDown(() async {
    await outboxBox.clear();
    await babyBox.clear();
  });

  group('B5-3 SyncQueue Tests', () {
    test('enqueue menyimpan operasi ke dalam outbox Hive', () async {
      final queue = SyncQueue(box: outboxBox, handler: (op) async {});

      await queue.enqueue(
        op: 'upsert',
        path: 'users/uid123/babies/b1',
        entityId: 'b1',
        payload: {'namaAnak': 'Ahmad'},
      );

      expect(await queue.pendingCount, equals(1));
      final items = outboxBox.values.toList();
      expect(items.first.entityId, equals('b1'));
      expect(items.first.op, equals('upsert'));
    });

    test('drain menghapus operasi dari outbox bila handler sukses', () async {
      final executedPaths = <String>[];
      final queue = SyncQueue(
        box: outboxBox,
        handler: (op) async {
          executedPaths.add(op.path);
        },
      );

      await queue.enqueue(
        op: 'upsert',
        path: 'users/uid123/babies/b1',
        entityId: 'b1',
        payload: {'namaAnak': 'Ahmad'},
      );

      final count = await queue.drain();

      expect(count, equals(1));
      expect(executedPaths, contains('users/uid123/babies/b1'));
      expect(await queue.pendingCount, equals(0));
    });

    test('drain menambah attempts bila handler gagal dan menyimpan dalam outbox', () async {
      final queue = SyncQueue(
        box: outboxBox,
        maxAttempts: 3,
        handler: (op) async {
          throw Exception('Simulasi gagal jaringan');
        },
      );

      await queue.enqueue(
        op: 'upsert',
        path: 'users/uid123/babies/b1',
        entityId: 'b1',
        payload: {'namaAnak': 'Ahmad'},
      );

      final count = await queue.drain();

      expect(count, equals(0));
      expect(await queue.pendingCount, equals(1));

      final item = outboxBox.values.first;
      expect(item.attempts, equals(1));
      expect(item.lastError, contains('Simulasi gagal jaringan'));
    });

    test('hasPendingDeleteFor mengembalikan true untuk entitas yang ditandai delete', () async {
      final queue = SyncQueue(box: outboxBox, handler: (op) async {});

      await queue.enqueue(
        op: 'delete',
        path: 'users/uid123/babies/b1',
        entityId: 'b1',
      );

      final hasDeleteB1 = await queue.hasPendingDeleteFor('b1');
      final hasDeleteB2 = await queue.hasPendingDeleteFor('b2');

      expect(hasDeleteB1, isTrue);
      expect(hasDeleteB2, isFalse);
    });
  });

  group('B5-5 & B5-7 SyncManager Conflict & Pull Tests', () {
    test('pullAll mengabaikan entitas yang memiliki antrean delete di outbox', () async {
      final queue = SyncQueue(box: outboxBox, handler: (op) async {});

      // Tandai b1 sebagai pending delete di outbox lokal
      await queue.enqueue(
        op: 'delete',
        path: 'users/uid123/babies/b1',
        entityId: 'b1',
      );

      final manager = SyncManager(
        syncQueue: queue,
        babyRemote: null, // remote null atau mock
      );

      // Jalankan pullAll
      await manager.pullAll('uid123');

      // b1 tidak boleh ada di lokal karena ada antrean delete
      expect(babyBox.containsKey('b1'), isFalse);
    });
  });
}
