import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/firebase/firebase_bootstrap.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/services/photo_storage_service.dart';
import '../../../../core/sync/sync_queue.dart';
import '../../domain/entities/baby_entity.dart';
import '../../domain/repositories/i_baby_repository.dart';
import '../datasources/baby_local_datasource.dart';
import '../mappers/baby_mapper.dart';
import '../models/baby_model.dart';

/// Implementasi offline-first `IBabyRepository`.
class BabyRepositoryImpl implements IBabyRepository {
  const BabyRepositoryImpl(
    this._localDatasource, {
    this.syncQueue,
    this.networkInfo,
    this.auth,
    this.photoStorageService,
  });

  final BabyLocalDatasource _localDatasource;
  final SyncQueue? syncQueue;
  final INetworkInfo? networkInfo;
  final FirebaseAuth? auth;
  final PhotoStorageService? photoStorageService;

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
  Future<List<BabyEntity>> getBabiesByUser(String userId) async {
    try {
      final models = await _localDatasource.getByUser(userId);
      return models.map((model) => model.toEntity()).toList();
    } catch (_) {
      throw const LocalStorageFailure(
        'Gagal memuat daftar bayi dari penyimpanan lokal.',
      );
    }
  }

  @override
  Future<BabyEntity?> getBabyById(String babyId) async {
    try {
      final model = await _localDatasource.getById(babyId);
      return model?.toEntity();
    } catch (_) {
      throw const LocalStorageFailure('Gagal memuat detail bayi.');
    }
  }

  @override
  Future<BabyEntity> addBaby(BabyEntity baby) async {
    try {
      final now = DateTime.now();
      final updatedBaby = baby.copyWith(updatedAt: baby.updatedAt ?? now);
      final model = BabyModel.fromEntity(updatedBaby);

      final saved = await _localDatasource.add(model);

      final uid = _uid ?? baby.userId;
      if (uid.isNotEmpty) {
        await syncQueue?.enqueue(
          op: 'upsert',
          path: 'users/$uid/babies/${baby.babyId}',
          entityId: baby.babyId,
          payload: BabyMapper.toFirestore(saved, updatedAt: saved.updatedAt),
        );
        if (await networkInfo?.isConnected ?? false) {
          unawaited(syncQueue?.drain());
        }
      }

      return saved.toEntity();
    } catch (_) {
      throw const LocalStorageFailure('Gagal menyimpan profil bayi.');
    }
  }

  @override
  Future<BabyEntity> updateBaby(BabyEntity baby) async {
    try {
      final existing = await _localDatasource.getById(baby.babyId);
      final now = DateTime.now();
      final updatedBaby = baby.copyWith(updatedAt: now);
      final model = BabyModel.fromEntity(updatedBaby);

      final updated = await _localDatasource.update(model);

      if (existing?.fotoProfilPath != null &&
          existing!.fotoProfilPath!.isNotEmpty &&
          existing.fotoProfilPath != updated.fotoProfilPath) {
        await photoStorageService?.deletePhoto(existing.fotoProfilPath);
      }

      final uid = _uid ?? baby.userId;
      if (uid.isNotEmpty) {
        await syncQueue?.enqueue(
          op: 'upsert',
          path: 'users/$uid/babies/${baby.babyId}',
          entityId: baby.babyId,
          payload: BabyMapper.toFirestore(updated, updatedAt: updated.updatedAt),
        );
        if (await networkInfo?.isConnected ?? false) {
          unawaited(syncQueue?.drain());
        }
      }

      return updated.toEntity();
    } catch (_) {
      throw const LocalStorageFailure('Gagal memperbarui profil bayi.');
    }
  }

  @override
  Future<void> deleteBaby(String babyId) async {
    try {
      final existing = await _localDatasource.getById(babyId);
      final uid = _uid ?? existing?.userId ?? '';

      // Hapus file foto lokal jika ada
      if (existing?.fotoProfilPath != null && existing!.fotoProfilPath!.isNotEmpty) {
        await photoStorageService?.deletePhoto(existing.fotoProfilPath);
      }

      await _localDatasource.delete(babyId);

      if (uid.isNotEmpty) {
        await syncQueue?.enqueue(
          op: 'delete',
          path: 'users/$uid/babies/$babyId',
          entityId: babyId,
        );
        if (await networkInfo?.isConnected ?? false) {
          unawaited(syncQueue?.drain());
        }
      }
    } catch (_) {
      throw const LocalStorageFailure('Gagal menghapus profil bayi.');
    }
  }
}
