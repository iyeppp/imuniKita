import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/baby_profile/data/datasources/baby_local_datasource.dart';
import '../features/baby_profile/data/repositories/baby_repository_impl.dart';
import '../features/baby_profile/domain/repositories/i_baby_repository.dart';
import '../features/baby_profile/domain/usecases/add_baby_usecase.dart';
import '../features/baby_profile/domain/usecases/get_babies_usecase.dart';
import '../features/baby_profile/domain/usecases/update_baby_usecase.dart';
import '../features/baby_profile/domain/usecases/delete_baby_usecase.dart';
import '../features/immunization/data/datasources/vaccine_local_datasource.dart';
import '../features/immunization/data/repositories/immunization_repository_impl.dart';
import '../features/immunization/domain/repositories/i_immunization_repository.dart';
import '../features/immunization/domain/usecases/generate_schedule_usecase.dart';
import '../features/immunization/domain/usecases/schedule_reminder_usecase.dart';

// Registry pusat Riverpod: datasource → repository → use case.
//
// Semua provider ditulis manual (tanpa `riverpod_generator`) — lihat dev
// plan §2 catatan konflik `build_runner` dengan `hive_ce_generator`.
// Screen/notifier cukup memanggil `ref.read(xUseCaseProvider)`, tidak
// pernah menyentuh datasource/repository secara langsung.

// ── Baby Profile ────────────────────────────────────────────────────────
final babyLocalDatasourceProvider = Provider<BabyLocalDatasource>((ref) {
  return const BabyLocalDatasource();
});

final babyRepositoryProvider = Provider<IBabyRepository>((ref) {
  return BabyRepositoryImpl(ref.watch(babyLocalDatasourceProvider));
});

final addBabyUseCaseProvider = Provider<AddBabyUseCase>((ref) {
  return AddBabyUseCase(ref.watch(babyRepositoryProvider));
});

final getBabiesUseCaseProvider = Provider<GetBabiesUseCase>((ref) {
  return GetBabiesUseCase(ref.watch(babyRepositoryProvider));
});

final updateBabyUseCaseProvider = Provider<UpdateBabyUseCase>((ref) {
  return UpdateBabyUseCase(ref.watch(babyRepositoryProvider));
});

final deleteBabyUseCaseProvider = Provider<DeleteBabyUseCase>((ref) {
  return DeleteBabyUseCase(ref.watch(babyRepositoryProvider));
});

// ── Immunization ────────────────────────────────────────────────────────
final vaccineLocalDatasourceProvider = Provider<VaccineLocalDatasource>((ref) {
  return const VaccineLocalDatasource();
});

final immunizationRepositoryProvider = Provider<IImmunizationRepository>((ref) {
  return ImmunizationRepositoryImpl(ref.watch(vaccineLocalDatasourceProvider));
});

final generateScheduleUseCaseProvider = Provider<GenerateScheduleUseCase>((
  ref,
) {
  return GenerateScheduleUseCase(ref.watch(immunizationRepositoryProvider));
});

final scheduleReminderUseCaseProvider = Provider<ScheduleReminderUseCase>((
  ref,
) {
  return const ScheduleReminderUseCase();
});
