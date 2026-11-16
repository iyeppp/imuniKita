import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/firebase/firebase_bootstrap.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/sync/sync_queue.dart';
import '../../domain/entities/vaccine_schedule_entity.dart';
import '../../domain/repositories/i_immunization_repository.dart';
import '../datasources/vaccine_local_datasource.dart';
import '../mappers/vaccine_schedule_mapper.dart';
import '../models/vaccine_schedule_model.dart';

/// Implementasi offline-first `IImmunizationRepository`.
class ImmunizationRepositoryImpl implements IImmunizationRepository {
  const ImmunizationRepositoryImpl(
    this._localDatasource, {
    this.syncQueue,
    this.networkInfo,
    this.auth,
  });

  final VaccineLocalDatasource _localDatasource;
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
  Future<List<VaccineScheduleEntity>> getSchedulesByBaby(String babyId) async {
    try {
      final models = await _localDatasource.getByBaby(babyId);
      return models.map(_toEntity).toList();
    } catch (_) {
      throw const LocalStorageFailure('Gagal memuat jadwal imunisasi.');
    }
  }

  @override
  Future<VaccineScheduleEntity?> getScheduleById(String scheduleId) async {
    try {
      final model = await _localDatasource.getById(scheduleId);
      return model == null ? null : _toEntity(model);
    } catch (_) {
      throw const LocalStorageFailure('Gagal memuat detail jadwal imunisasi.');
    }
  }

  @override
  Future<void> saveSchedules(List<VaccineScheduleEntity> schedules) async {
    try {
      final now = DateTime.now();
      final updatedSchedules = schedules
          .map((s) => s.copyWith(updatedAt: s.updatedAt ?? now))
          .toList();

      final models =
          updatedSchedules.map(VaccineScheduleModel.fromEntity).toList();

      await _localDatasource.saveAll(models);

      final uid = _uid;
      if (uid != null && uid.isNotEmpty) {
        for (final model in models) {
          await syncQueue?.enqueue(
            op: 'upsert',
            path: 'users/$uid/babies/${model.babyId}/vaccineSchedules/${model.scheduleId}',
            entityId: model.scheduleId,
            payload: VaccineScheduleMapper.toFirestore(
              model,
              updatedAt: model.updatedAt,
            ),
          );
        }
        if (await networkInfo?.isConnected ?? false) {
          unawaited(syncQueue?.drain());
        }
      }
    } catch (_) {
      throw const LocalStorageFailure('Gagal menyimpan jadwal imunisasi.');
    }
  }

  @override
  Future<VaccineScheduleEntity> updateSchedule(
    VaccineScheduleEntity schedule,
  ) async {
    try {
      final now = DateTime.now();
      final updatedSchedule = schedule.copyWith(updatedAt: now);
      final model = VaccineScheduleModel.fromEntity(updatedSchedule);

      final updated = await _localDatasource.update(model);

      final uid = _uid;
      if (uid != null && uid.isNotEmpty) {
        await syncQueue?.enqueue(
          op: 'upsert',
          path: 'users/$uid/babies/${model.babyId}/vaccineSchedules/${model.scheduleId}',
          entityId: model.scheduleId,
          payload: VaccineScheduleMapper.toFirestore(
            updated,
            updatedAt: updated.updatedAt,
          ),
        );
        if (await networkInfo?.isConnected ?? false) {
          unawaited(syncQueue?.drain());
        }
      }

      return _toEntity(updated);
    } catch (_) {
      throw const LocalStorageFailure('Gagal memperbarui jadwal imunisasi.');
    }
  }

  @override
  Future<void> deleteSchedulesByBaby(String babyId) async {
    try {
      final schedules = await _localDatasource.getByBaby(babyId);
      await _localDatasource.deleteByBaby(babyId);

      final uid = _uid;
      if (uid != null && uid.isNotEmpty) {
        for (final s in schedules) {
          await syncQueue?.enqueue(
            op: 'delete',
            path: 'users/$uid/babies/$babyId/vaccineSchedules/${s.scheduleId}',
            entityId: s.scheduleId,
          );
        }
        if (await networkInfo?.isConnected ?? false) {
          unawaited(syncQueue?.drain());
        }
      }
    } catch (_) {
      throw const LocalStorageFailure('Gagal menghapus jadwal imunisasi.');
    }
  }

  /// Model → entity sekaligus menormalkan status.
  VaccineScheduleEntity _toEntity(VaccineScheduleModel model) {
    final entity = model.toEntity();
    final efektif = VaccineStatus.effective(
      status: entity.status,
      tanggalTarget: entity.tanggalTarget,
    );

    return efektif == entity.status ? entity : entity.copyWith(status: efektif);
  }
}
