import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:uuid/uuid.dart';

import '../constants/app_constants.dart';
import 'sync_outbox_model.dart';

typedef SyncOperationHandler = Future<void> Function(SyncOperationModel op);

/// Default handler yang mengeksekusi mutasi Firestore secara idempoten.
Future<void> defaultFirestoreSyncHandler(SyncOperationModel op) async {
  final docRef = FirebaseFirestore.instance.doc(op.path);
  if (op.op == 'delete') {
    await docRef.delete();
  } else {
    final Map<String, dynamic> payload =
        op.payloadJson.isEmpty
            ? <String, dynamic>{}
            : (jsonDecode(op.payloadJson) as Map<String, dynamic>);
    await docRef.set(payload, SetOptions(merge: true));
  }
}

/// Antrean outbox offline-first untuk menampung mutasi lokal dan memprosesnya ke Firestore.
class SyncQueue {
  SyncQueue({
    Box<SyncOperationModel>? box,
    SyncOperationHandler? handler,
    this.maxAttempts = 5,
  })  : _boxOverride = box,
        _handler = handler ?? defaultFirestoreSyncHandler;

  final Box<SyncOperationModel>? _boxOverride;
  final SyncOperationHandler _handler;
  final int maxAttempts;

  Future<Box<SyncOperationModel>> get _box async {
    if (_boxOverride != null && _boxOverride.isOpen) {
      return _boxOverride;
    }
    if (Hive.isBoxOpen(AppConstants.syncOutboxBox)) {
      return Hive.box<SyncOperationModel>(AppConstants.syncOutboxBox);
    }
    return Hive.openBox<SyncOperationModel>(AppConstants.syncOutboxBox);
  }

  /// Memasukkan operasi mutasi baru ke dalam outbox Hive.
  Future<void> enqueue({
    required String op,
    required String path,
    required String entityId,
    Map<String, dynamic>? payload,
  }) async {
    final box = await _box;

    // Hapus operasi lama dengan path yang persis sama untuk efisiensi outbox
    final duplicateKeys = <dynamic>[];
    for (final key in box.keys) {
      final item = box.get(key);
      if (item != null && item.path == path) {
        duplicateKeys.add(key);
      }
    }
    if (duplicateKeys.isNotEmpty) {
      await box.deleteAll(duplicateKeys);
    }

    final model = SyncOperationModel(
      id: const Uuid().v4(),
      op: op,
      path: path,
      entityId: entityId,
      payloadJson: payload != null ? jsonEncode(payload) : '',
      attempts: 0,
      createdAt: DateTime.now(),
    );

    await box.put(model.id, model);
  }

  /// Menyingkirkan (drain) seluruh antrean outbox secara berurutan.
  Future<int> drain() async {
    final box = await _box;
    if (box.isEmpty) return 0;

    final items = box.values.toList();
    items.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    int successCount = 0;

    for (final op in items) {
      if (op.attempts >= maxAttempts) {
        // Lewati atau buang jika melebihi batas percobaan maksimum
        continue;
      }

      try {
        await _handler(op);
        await box.delete(op.id);
        successCount++;
      } catch (e) {
        op.attempts += 1;
        op.lastAttemptAt = DateTime.now();
        op.lastError = e.toString();
        await op.save();

        if (kDebugMode) {
          debugPrint(
            'SyncQueue: Gagal mengirim ${op.path} (Percobaan ${op.attempts}/$maxAttempts): $e',
          );
        }
      }
    }

    return successCount;
  }

  /// Mengecek apakah ada antrean `delete` yang belum terproses untuk [entityId].
  ///
  /// Dipakai saat Pull untuk mencegah data yang baru dihapus di lokal "hidup kembali".
  Future<bool> hasPendingDeleteFor(String entityId) async {
    final box = await _box;
    return box.values.any(
      (op) => op.entityId == entityId && op.op == 'delete',
    );
  }

  /// Mengetahui jumlah antrean yang belum terkirim.
  Future<int> get pendingCount async {
    final box = await _box;
    return box.length;
  }
}
