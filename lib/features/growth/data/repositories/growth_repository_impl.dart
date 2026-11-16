import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/firebase/firebase_bootstrap.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/sync/sync_queue.dart';
import '../../domain/entities/growth_record_entity.dart';
import '../../domain/repositories/i_growth_repository.dart';
import '../datasources/growth_local_datasource.dart';
import '../mappers/growth_record_mapper.dart';
import '../models/growth_record_model.dart';

/// Implementasi offline-first `IGrowthRepository`.
class GrowthRepositoryImpl implements IGrowthRepository {
  const GrowthRepositoryImpl(
    this._localDatasource, {
    this.syncQueue,
    this.networkInfo,
    this.auth,
  });

  final GrowthLocalDatasource _localDatasource;
  final SyncQueue? syncQueue;
  final INetworkInfo? networkInfo;
  final FirebaseAuth? auth;

  String? get _uid {
    if (auth != null) return auth?.currentUser?.uid;
    if (!FirebaseBootstrap.isInitialized) return null;
    try {
      return FirebaseAuth.instance.currentUser?.uid;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<GrowthRecordEntity>> getRecordsByBaby(String babyId) async {
    try {
      final models = await _localDatasource.getByBaby(babyId);
      return models.map((m) => m.toEntity()).toList();
    } catch (_) {
      throw const LocalStorageFailure(
        'Gagal memuat rekam pertumbuhan dari penyimpanan lokal.',
      );
    }
  }

  @override
  Future<GrowthRecordEntity> addRecord(GrowthRecordEntity record) async {
    try {
      final now = DateTime.now();
      final updatedRecord = record.copyWith(updatedAt: record.updatedAt ?? now);
      final model = GrowthRecordModel.fromEntity(updatedRecord);

      final saved = await _localDatasource.put(model);

      final uid = _uid;
      if (uid != null && uid.isNotEmpty) {
        await syncQueue?.enqueue(
          op: 'upsert',
          path: 'users/$uid/babies/${record.babyId}/growthRecords/${record.recordId}',
          entityId: record.recordId,
          payload: GrowthRecordMapper.toFirestore(saved, updatedAt: saved.updatedAt),
        );
        if (await networkInfo?.isConnected ?? false) {
          unawaited(syncQueue?.drain());
        }
      }

      return saved.toEntity();
    } catch (_) {
      throw const LocalStorageFailure('Gagal menyimpan rekam pertumbuhan.');
    }
  }

  @override
  Future<void> deleteRecordsByBaby(String babyId) async {
    try {
      final records = await _localDatasource.getByBaby(babyId);
      await _localDatasource.deleteByBaby(babyId);

      final uid = _uid;
      if (uid != null && uid.isNotEmpty) {
        for (final r in records) {
          await syncQueue?.enqueue(
            op: 'delete',
            path: 'users/$uid/babies/$babyId/growthRecords/${r.recordId}',
            entityId: r.recordId,
          );
        }
        if (await networkInfo?.isConnected ?? false) {
          unawaited(syncQueue?.drain());
        }
      }
    } catch (_) {
      throw const LocalStorageFailure('Gagal menghapus rekam pertumbuhan.');
    }
  }
}
