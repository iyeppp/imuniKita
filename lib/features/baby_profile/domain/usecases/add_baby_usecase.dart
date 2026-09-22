import '../entities/baby_entity.dart';
import '../repositories/i_baby_repository.dart';

/// Simpan profil bayi baru.
///
/// Dipanggil dari `AddBabyScreen` setelah form tervalidasi. Setelah berhasil,
/// layar pemanggil bertanggung jawab memicu `GenerateScheduleUseCase` lalu
/// `ScheduleReminderUseCase` (lihat dev plan §4 "Alur Kerja").
class AddBabyUseCase {
  const AddBabyUseCase(this._repository);

  final IBabyRepository _repository;

  Future<BabyEntity> execute(BabyEntity baby) => _repository.addBaby(baby);
}
