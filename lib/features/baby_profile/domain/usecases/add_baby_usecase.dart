import '../entities/baby_entity.dart';
import '../repositories/i_baby_repository.dart';

/// Simpan profil bayi baru.
class AddBabyUseCase {
  const AddBabyUseCase(this._repository);

  final IBabyRepository _repository;

  Future<BabyEntity> execute(BabyEntity baby) => _repository.addBaby(baby);
}
