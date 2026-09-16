import '../entities/baby_entity.dart';
import '../repositories/i_baby_repository.dart';

/// Perbarui profil bayi yang sudah ada (mis. edit dari `BabyDetailScreen`).
class UpdateBabyUseCase {
  const UpdateBabyUseCase(this._repository);

  final IBabyRepository _repository;

  Future<BabyEntity> execute(BabyEntity baby) => _repository.updateBaby(baby);
}
