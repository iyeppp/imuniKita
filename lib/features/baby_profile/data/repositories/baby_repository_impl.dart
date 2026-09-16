import '../../../../core/errors/failures.dart';
import '../../domain/entities/baby_entity.dart';
import '../../domain/repositories/i_baby_repository.dart';
import '../datasources/baby_local_datasource.dart';
import '../models/baby_model.dart';

/// Implementasi `IBabyRepository` fase UTS — sepenuhnya di atas Hive CE.
///
/// Menerjemahkan `BabyModel` (data layer) ↔ `BabyEntity` (domain layer) dan
/// membungkus error Hive menjadi `Failure` yang siap tampil ke pengguna.
class BabyRepositoryImpl implements IBabyRepository {
  const BabyRepositoryImpl(this._localDatasource);

  final BabyLocalDatasource _localDatasource;

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
      final saved = await _localDatasource.add(BabyModel.fromEntity(baby));
      return saved.toEntity();
    } catch (_) {
      throw const LocalStorageFailure('Gagal menyimpan profil bayi.');
    }
  }

  @override
  Future<BabyEntity> updateBaby(BabyEntity baby) async {
    try {
      final updated = await _localDatasource.update(BabyModel.fromEntity(baby));
      return updated.toEntity();
    } catch (_) {
      throw const LocalStorageFailure('Gagal memperbarui profil bayi.');
    }
  }
}
