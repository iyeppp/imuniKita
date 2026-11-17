import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/firebase/firebase_bootstrap.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/sync/sync_queue.dart';
import '../../domain/entities/health_journal_entity.dart';
import '../../domain/repositories/i_health_journal_repository.dart';
import '../datasources/health_journal_local_datasource.dart';
import '../mappers/health_journal_mapper.dart';
import '../models/health_journal_model.dart';

/// Implementasi offline-first `IHealthJournalRepository`.
class HealthJournalRepositoryImpl implements IHealthJournalRepository {
  const HealthJournalRepositoryImpl(
    this._localDatasource, {
    this.syncQueue,
    this.networkInfo,
    this.auth,
  });

  final HealthJournalLocalDatasource _localDatasource;
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
  Future<List<HealthJournalEntity>> getJournalsByBaby(String babyId) async {
    try {
      final models = await _localDatasource.getByBaby(babyId);
      return models.map((m) => m.toEntity()).toList();
    } catch (_) {
      throw const LocalStorageFailure(
        'Gagal memuat jurnal kesehatan dari penyimpanan lokal.',
      );
    }
  }

  @override
  Future<HealthJournalEntity> addJournal(HealthJournalEntity journal) async {
    try {
      final now = DateTime.now();
      final updatedJournal = journal.copyWith(updatedAt: journal.updatedAt ?? now);
      final model = HealthJournalModel.fromEntity(updatedJournal);

      final saved = await _localDatasource.put(model);

      final uid = _uid;
      if (uid != null && uid.isNotEmpty) {
        await syncQueue?.enqueue(
          op: 'upsert',
          path: 'users/$uid/babies/${journal.babyId}/healthJournals/${journal.journalId}',
          entityId: journal.journalId,
          payload: HealthJournalMapper.toFirestore(saved, updatedAt: saved.updatedAt),
        );
        if (await networkInfo?.isConnected ?? false) {
          unawaited(syncQueue?.drain());
        }
      }

      return saved.toEntity();
    } catch (_) {
      throw const LocalStorageFailure('Gagal menyimpan catatan jurnal.');
    }
  }

  @override
  Future<void> deleteJournal(String journalId) async {
    try {
      final existing = await _localDatasource.getById(journalId);
      await _localDatasource.delete(journalId);

      final uid = _uid;
      if (existing != null && uid != null && uid.isNotEmpty) {
        await syncQueue?.enqueue(
          op: 'delete',
          path: 'users/$uid/babies/${existing.babyId}/healthJournals/$journalId',
          entityId: journalId,
        );
        if (await networkInfo?.isConnected ?? false) {
          unawaited(syncQueue?.drain());
        }
      }
    } catch (_) {
      throw const LocalStorageFailure('Gagal menghapus catatan jurnal.');
    }
  }

  @override
  Future<void> deleteJournalsByBaby(String babyId) async {
    try {
      final journals = await _localDatasource.getByBaby(babyId);
      await _localDatasource.deleteByBaby(babyId);

      final uid = _uid;
      if (uid != null && uid.isNotEmpty) {
        for (final j in journals) {
          await syncQueue?.enqueue(
            op: 'delete',
            path: 'users/$uid/babies/$babyId/healthJournals/${j.journalId}',
            entityId: j.journalId,
          );
        }
        if (await networkInfo?.isConnected ?? false) {
          unawaited(syncQueue?.drain());
        }
      }
    } catch (_) {
      throw const LocalStorageFailure('Gagal menghapus jurnal kesehatan.');
    }
  }
}
