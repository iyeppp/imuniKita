import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/data/datasources/auth_local_datasource.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/i_auth_repository.dart';
import '../features/auth/domain/usecases/auth_state_usecase.dart';
import '../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../features/auth/domain/usecases/login_usecase.dart';
import '../features/auth/domain/usecases/logout_usecase.dart';
import '../features/auth/domain/usecases/register_usecase.dart';
import '../features/auth/domain/usecases/update_profile_usecase.dart';
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
import '../features/immunization/domain/usecases/reschedule_all_reminders_usecase.dart';
import '../features/immunization/domain/usecases/schedule_reminder_usecase.dart';
import '../features/immunization/domain/usecases/sync_baby_schedule_usecase.dart';
import '../features/growth/data/datasources/growth_local_datasource.dart';
import '../features/growth/data/repositories/growth_repository_impl.dart';
import '../features/growth/domain/repositories/i_growth_repository.dart';
import '../features/growth/domain/usecases/add_growth_record_usecase.dart';
import '../features/growth/domain/usecases/delete_growth_records_by_baby_usecase.dart';
import '../features/growth/domain/usecases/get_growth_records_usecase.dart';
import '../features/health_journal/data/datasources/health_journal_local_datasource.dart';
import '../features/health_journal/data/repositories/health_journal_repository_impl.dart';
import '../features/health_journal/domain/repositories/i_health_journal_repository.dart';
import '../features/health_journal/domain/usecases/add_health_journal_usecase.dart';
import '../features/health_journal/domain/usecases/delete_health_journal_usecase.dart';
import '../features/health_journal/domain/usecases/delete_health_journals_by_baby_usecase.dart';
import '../features/health_journal/domain/usecases/get_health_journals_usecase.dart';

// Registry pusat Riverpod: datasource -> repository -> use case.
//
// Semua provider ditulis manual (tanpa `riverpod_generator`) -- lihat dev
// plan bagian 2 catatan konflik `build_runner` dengan `hive_ce_generator`.
// Screen/notifier cukup memanggil `ref.read(xUseCaseProvider)`, tidak
// pernah menyentuh datasource/repository secara langsung.

// -- Auth (Temuan #22) ---------------------------------------------------------
final authLocalDatasourceProvider = Provider<AuthLocalDatasource>((ref) {
  return const AuthLocalDatasource();
});

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authLocalDatasourceProvider));
});

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  return GetCurrentUserUseCase(ref.watch(authRepositoryProvider));
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  return RegisterUseCase(ref.watch(authRepositoryProvider));
});

final updateProfileUseCaseProvider = Provider<UpdateProfileUseCase>((ref) {
  return UpdateProfileUseCase(ref.watch(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.watch(authRepositoryProvider));
});

final checkAuthStateUseCaseProvider = Provider<CheckAuthStateUseCase>((ref) {
  return CheckAuthStateUseCase(ref.watch(authRepositoryProvider));
});

final markOnboardingSeenUseCaseProvider = Provider<MarkOnboardingSeenUseCase>((
  ref,
) {
  return MarkOnboardingSeenUseCase(ref.watch(authRepositoryProvider));
});

// -- Baby Profile -------------------------------------------------------------
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

// -- Immunization -------------------------------------------------------------
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
  // Bug #11: repository diinjek agar flag reminderH7Sent/reminderH1Sent
  // bisa di-set setelah notifikasi berhasil dijadwalkan.
  return ScheduleReminderUseCase(
    repository: ref.watch(immunizationRepositoryProvider),
  );
});

/// Bug #34: alur "generate jadwal + daftarkan pengingat" dipakai bersama oleh
/// Tambah Bayi, Kelola Profil Anak, dan `ImmunizationNotifier.build`.
final syncBabyScheduleUseCaseProvider = Provider<SyncBabyScheduleUseCase>((
  ref,
) {
  return SyncBabyScheduleUseCase(
    generateSchedule: ref.watch(generateScheduleUseCaseProvider),
    scheduleReminder: ref.watch(scheduleReminderUseCaseProvider),
  );
});

/// Bug #34: dipakai toggle notifikasi di Profil & Pengaturan.
final rescheduleAllRemindersUseCaseProvider =
    Provider<RescheduleAllRemindersUseCase>((ref) {
      return RescheduleAllRemindersUseCase(
        repository: ref.watch(immunizationRepositoryProvider),
        reminder: ref.watch(scheduleReminderUseCaseProvider),
      );
    });

// -- Growth (Temuan #32) --------------------------------------------------------
final growthLocalDatasourceProvider = Provider<GrowthLocalDatasource>((ref) {
  return const GrowthLocalDatasource();
});

final growthRepositoryProvider = Provider<IGrowthRepository>((ref) {
  return GrowthRepositoryImpl(ref.watch(growthLocalDatasourceProvider));
});

final addGrowthRecordUseCaseProvider = Provider<AddGrowthRecordUseCase>((ref) {
  return AddGrowthRecordUseCase(ref.watch(growthRepositoryProvider));
});

final getGrowthRecordsUseCaseProvider = Provider<GetGrowthRecordsUseCase>((
  ref,
) {
  return GetGrowthRecordsUseCase(ref.watch(growthRepositoryProvider));
});

final deleteGrowthRecordsByBabyUseCaseProvider =
    Provider<DeleteGrowthRecordsByBabyUseCase>((ref) {
      return DeleteGrowthRecordsByBabyUseCase(
        ref.watch(growthRepositoryProvider),
      );
    });

// -- Health Journal (Temuan #32) ------------------------------------------------
final healthJournalLocalDatasourceProvider =
    Provider<HealthJournalLocalDatasource>((ref) {
      return const HealthJournalLocalDatasource();
    });

final healthJournalRepositoryProvider = Provider<IHealthJournalRepository>((
  ref,
) {
  return HealthJournalRepositoryImpl(
    ref.watch(healthJournalLocalDatasourceProvider),
  );
});

final addHealthJournalUseCaseProvider = Provider<AddHealthJournalUseCase>((
  ref,
) {
  return AddHealthJournalUseCase(ref.watch(healthJournalRepositoryProvider));
});

final getHealthJournalsUseCaseProvider = Provider<GetHealthJournalsUseCase>((
  ref,
) {
  return GetHealthJournalsUseCase(ref.watch(healthJournalRepositoryProvider));
});

final deleteHealthJournalUseCaseProvider = Provider<DeleteHealthJournalUseCase>(
  (ref) {
    return DeleteHealthJournalUseCase(
      ref.watch(healthJournalRepositoryProvider),
    );
  },
);

final deleteHealthJournalsByBabyUseCaseProvider =
    Provider<DeleteHealthJournalsByBabyUseCase>((ref) {
      return DeleteHealthJournalsByBabyUseCase(
        ref.watch(healthJournalRepositoryProvider),
      );
    });
