import 'package:flutter/foundation.dart';

import '../../features/baby_profile/data/datasources/baby_local_datasource.dart';
import '../../features/baby_profile/data/datasources/baby_remote_datasource.dart';
import '../../features/education/data/datasources/quiz_score_remote_datasource.dart';
import '../../features/growth/data/datasources/growth_local_datasource.dart';
import '../../features/growth/data/datasources/growth_remote_datasource.dart';
import '../../features/growth/data/models/growth_record_model.dart';
import '../../features/health_journal/data/datasources/health_journal_local_datasource.dart';
import '../../features/health_journal/data/datasources/health_journal_remote_datasource.dart';
import '../../features/immunization/data/datasources/vaccine_local_datasource.dart';
import '../../features/immunization/data/datasources/vaccine_remote_datasource.dart';
import '../firebase/firebase_bootstrap.dart';
import 'sync_queue.dart';

/// Manager terpusat untuk sinkronisasi dua arah (pull & push) antara Hive CE dan Firestore.
class SyncManager {
  SyncManager({
    BabyLocalDatasource? babyLocal,
    BabyRemoteDatasource? babyRemote,
    VaccineLocalDatasource? vaccineLocal,
    VaccineRemoteDatasource? vaccineRemote,
    GrowthLocalDatasource? growthLocal,
    GrowthRemoteDatasource? growthRemote,
    HealthJournalLocalDatasource? journalLocal,
    HealthJournalRemoteDatasource? journalRemote,
    QuizScoreRemoteDatasource? quizRemote,
    SyncQueue? syncQueue,
  })  : _babyLocal = babyLocal ?? const BabyLocalDatasource(),
        _babyRemote = babyRemote ??
            (FirebaseBootstrap.isInitialized
                ? FirebaseBabyRemoteDatasource()
                : null),
        _vaccineLocal = vaccineLocal ?? const VaccineLocalDatasource(),
        _vaccineRemote = vaccineRemote ??
            (FirebaseBootstrap.isInitialized
                ? FirebaseVaccineRemoteDatasource()
                : null),
        _growthLocal = growthLocal ?? const GrowthLocalDatasource(),
        _growthRemote = growthRemote ??
            (FirebaseBootstrap.isInitialized
                ? FirebaseGrowthRemoteDatasource()
                : null),
        _journalLocal = journalLocal ?? const HealthJournalLocalDatasource(),
        _journalRemote = journalRemote ??
            (FirebaseBootstrap.isInitialized
                ? FirebaseHealthJournalRemoteDatasource()
                : null),
        _quizRemote = quizRemote ??
            (FirebaseBootstrap.isInitialized
                ? FirebaseQuizScoreRemoteDatasource()
                : null),
        _syncQueue = syncQueue ?? SyncQueue();

  final BabyLocalDatasource _babyLocal;
  final BabyRemoteDatasource? _babyRemote;
  final VaccineLocalDatasource _vaccineLocal;
  final VaccineRemoteDatasource? _vaccineRemote;
  final GrowthLocalDatasource _growthLocal;
  final GrowthRemoteDatasource? _growthRemote;
  final HealthJournalLocalDatasource _journalLocal;
  final HealthJournalRemoteDatasource? _journalRemote;
  final QuizScoreRemoteDatasource? _quizRemote;
  final SyncQueue _syncQueue;

  /// Menguras (drain) outbox queue lokal ke cloud.
  Future<int> pushPendingMutations() async {
    return _syncQueue.drain();
  }

  /// Menarik (pull) seluruh data domain pengguna dari Firestore ke Hive.
  Future<void> pullAll(String uid) async {
    if (uid.isEmpty) return;

    try {
      // 1.
      await pushPendingMutations();

      // 2.
      final babyRemoteDs = _babyRemote;
      if (babyRemoteDs != null) {
        final remoteBabies = await babyRemoteDs.getAll(uid);
        for (final remoteBaby in remoteBabies) {
          final isPendingDelete =
              await _syncQueue.hasPendingDeleteFor(remoteBaby.babyId);
          if (isPendingDelete) continue;

          final localBaby = await _babyLocal.getById(remoteBaby.babyId);
          if (localBaby == null ||
              _isRemoteNewer(remoteBaby.updatedAt, localBaby.updatedAt)) {
            await _babyLocal.add(remoteBaby);
          }
        }
      }

      // Ambil seluruh bayi lokal untuk menarik subkoleksinya
      final localBabies = await _babyLocal.getByUser(uid);
      for (final baby in localBabies) {
        // 3.
        final vRemoteDs = _vaccineRemote;
        if (vRemoteDs != null) {
          final remoteSchedules = await vRemoteDs.getSchedules(uid, baby.babyId);
          for (final remoteSchedule in remoteSchedules) {
            final isPendingDelete = await _syncQueue
                .hasPendingDeleteFor(remoteSchedule.scheduleId);
            if (isPendingDelete) continue;

            final localSchedule =
                await _vaccineLocal.getById(remoteSchedule.scheduleId);
            if (localSchedule == null ||
                _isRemoteNewer(
                    remoteSchedule.updatedAt, localSchedule.updatedAt)) {
              await _vaccineLocal.saveAll([remoteSchedule]);
            }
          }
        }

        // 4.
        final gRemoteDs = _growthRemote;
        if (gRemoteDs != null) {
          final remoteRecords =
              await gRemoteDs.getRecords(uid, baby.babyId);
          for (final remoteRecord in remoteRecords) {
            final isPendingDelete = await _syncQueue
                .hasPendingDeleteFor(remoteRecord.recordId);
            if (isPendingDelete) continue;

            final localRecords = await _growthLocal.getByBaby(baby.babyId);
            GrowthRecordModel? localRecord;
            for (final r in localRecords) {
              if (r.recordId == remoteRecord.recordId) {
                localRecord = r;
                break;
              }
            }
            if (localRecord == null ||
                _isRemoteNewer(
                    remoteRecord.updatedAt, localRecord.updatedAt)) {
              await _growthLocal.put(remoteRecord);
            }
          }
        }

        // 5.
        final jRemoteDs = _journalRemote;
        if (jRemoteDs != null) {
          final remoteJournals =
              await jRemoteDs.getJournals(uid, baby.babyId);
          for (final remoteJournal in remoteJournals) {
            final isPendingDelete = await _syncQueue
                .hasPendingDeleteFor(remoteJournal.journalId);
            if (isPendingDelete) continue;

            final localJournal =
                await _journalLocal.getById(remoteJournal.journalId);
            if (localJournal == null ||
                _isRemoteNewer(
                    remoteJournal.updatedAt, localJournal.updatedAt)) {
              await _journalLocal.put(remoteJournal);
            }
          }
        }
      }

      // 6.
      final qRemoteDs = _quizRemote;
      if (qRemoteDs != null) {
        final remoteScores = await qRemoteDs.getScores(uid);
        for (final remoteScore in remoteScores) {
          final isPendingDelete =
              await _syncQueue.hasPendingDeleteFor(remoteScore.quizId);
          if (isPendingDelete) continue;

          // Simpan ke remote / local jika perlu
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('SyncManager: Error saat pullAll($uid): $e');
      }
    }
  }

  bool _isRemoteNewer(DateTime? remoteTime, DateTime? localTime) {
    if (remoteTime == null) return false;
    if (localTime == null) return true;
    return remoteTime.isAfter(localTime);
  }
}
