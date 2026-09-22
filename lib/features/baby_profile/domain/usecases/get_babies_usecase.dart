import '../entities/baby_entity.dart';
import '../repositories/i_baby_repository.dart';

/// Ambil seluruh bayi milik user aktif (mendukung multi-anak).
class GetBabiesUseCase {
  const GetBabiesUseCase(this._repository);

  final IBabyRepository _repository;

  Future<List<BabyEntity>> execute(String userId) =>
      _repository.getBabiesByUser(userId);
}
