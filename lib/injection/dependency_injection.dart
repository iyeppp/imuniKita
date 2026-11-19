import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/firebase/firebase_bootstrap.dart';
import '../core/firestore/recursive_delete.dart';
import '../core/network/network_info.dart';
import '../core/sync/data_migration.dart';
import '../core/sync/sync_manager.dart';
import '../core/sync/sync_queue.dart';
import '../features/auth/data/datasources/auth_local_datasource.dart';
import '../features/auth/data/datasources/auth_remote_datasource.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/i_auth_repository.dart';
import '../features/auth/domain/usecases/auth_state_usecase.dart';
import '../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../features/auth/domain/usecases/login_usecase.dart';
import '../features/auth/domain/usecases/logout_usecase.dart';
import '../features/auth/domain/usecases/register_usecase.dart';
import '../features/auth/domain/usecases/send_password_reset_usecase.dart';
import '../features/auth/domain/usecases/update_profile_usecase.dart';
import '../features/baby_profile/data/datasources/baby_local_datasource.dart';
import '../features/baby_profile/data/datasources/baby_remote_datasource.dart';
import '../features/baby_profile/data/repositories/baby_repository_impl.dart';
import '../features/baby_profile/domain/repositories/i_baby_repository.dart';
import '../features/baby_profile/domain/usecases/add_baby_usecase.dart';
import '../features/baby_profile/domain/usecases/get_babies_usecase.dart';
import '../features/baby_profile/domain/usecases/update_baby_usecase.dart';
import '../features/baby_profile/domain/usecases/delete_baby_usecase.dart';
import '../features/immunization/data/datasources/vaccine_local_datasource.dart';
import '../features/immunization/data/datasources/vaccine_remote_datasource.dart';
import '../features/immunization/data/repositories/immunization_repository_impl.dart';
import '../features/immunization/domain/repositories/i_immunization_repository.dart';
import '../features/immunization/domain/usecases/generate_schedule_usecase.dart';
import '../features/immunization/domain/usecases/reschedule_all_reminders_usecase.dart';
import '../features/immunization/domain/usecases/schedule_reminder_usecase.dart';
import '../features/immunization/domain/usecases/sync_baby_schedule_usecase.dart';
import '../features/growth/data/datasources/growth_local_datasource.dart';
import '../features/growth/data/datasources/growth_remote_datasource.dart';
import '../features/growth/data/repositories/growth_repository_impl.dart';
import '../features/growth/domain/repositories/i_growth_repository.dart';
import '../features/growth/domain/usecases/add_growth_record_usecase.dart';
import '../features/growth/domain/usecases/delete_growth_records_by_baby_usecase.dart';
import '../features/growth/domain/usecases/get_growth_records_usecase.dart';
import '../features/health_journal/data/datasources/health_journal_local_datasource.dart';
import '../features/health_journal/data/datasources/health_journal_remote_datasource.dart';
import '../features/health_journal/data/repositories/health_journal_repository_impl.dart';
import '../features/health_journal/domain/repositories/i_health_journal_repository.dart';
import '../features/health_journal/domain/usecases/add_health_journal_usecase.dart';
import '../features/health_journal/domain/usecases/delete_health_journal_usecase.dart';
import '../features/health_journal/domain/usecases/delete_health_journals_by_baby_usecase.dart';
import '../features/health_journal/domain/usecases/get_health_journals_usecase.dart';
import '../features/education/data/datasources/quiz_score_remote_datasource.dart';

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

/// Remote datasource Firebase hanya dibuat bila bootstrap berhasil.
///
/// `null` berarti aplikasi berjalan local-only (desktop, atau init Firebase
/// gagal) dan repository otomatis memakai fallback lokal ala UTS.
final authRemoteDatasourceProvider = Provider<AuthRemoteDatasource?>((ref) {
  if (!FirebaseBootstrap.isInitialized) return null;
  return const FirebaseAuthRemoteDatasource();
});

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.watch(authLocalDatasourceProvider),
    remote: ref.watch(authRemoteDatasourceProvider),
  );
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

final sendPasswordResetUseCaseProvider = Provider<SendPasswordResetUseCase>((
  ref,
) {
  return SendPasswordResetUseCase(ref.watch(authRepositoryProvider));
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

final babyRemoteDatasourceProvider = Provider<BabyRemoteDatasource?>((ref) {
  if (!FirebaseBootstrap.isInitialized) return null;
  return FirebaseBabyRemoteDatasource();
});

final syncQueueProvider = Provider<SyncQueue>((ref) {
  return SyncQueue();
});

final syncManagerProvider = Provider<SyncManager>((ref) {
  return SyncManager(
    babyLocal: ref.watch(babyLocalDatasourceProvider),
    babyRemote: ref.watch(babyRemoteDatasourceProvider),
    vaccineLocal: ref.watch(vaccineLocalDatasourceProvider),
    vaccineRemote: ref.watch(vaccineRemoteDatasourceProvider),
    growthLocal: ref.watch(growthLocalDatasourceProvider),
    growthRemote: ref.watch(growthRemoteDatasourceProvider),
    journalLocal: ref.watch(healthJournalLocalDatasourceProvider),
    journalRemote: ref.watch(healthJournalRemoteDatasourceProvider),
    quizRemote: ref.watch(quizScoreRemoteDatasourceProvider),
    syncQueue: ref.watch(syncQueueProvider),
  );
});

final dataMigrationProvider = Provider<DataMigration>((ref) {
  return DataMigration(
    babyRemote: ref.watch(babyRemoteDatasourceProvider),
    vaccineLocal: ref.watch(vaccineLocalDatasourceProvider),
    vaccineRemote: ref.watch(vaccineRemoteDatasourceProvider),
    growthLocal: ref.watch(growthLocalDatasourceProvider),
    growthRemote: ref.watch(growthRemoteDatasourceProvider),
    journalLocal: ref.watch(healthJournalLocalDatasourceProvider),
    journalRemote: ref.watch(healthJournalRemoteDatasourceProvider),
    quizRemote: ref.watch(quizScoreRemoteDatasourceProvider),
  );
});

final babyRepositoryProvider = Provider<IBabyRepository>((ref) {
  return BabyRepositoryImpl(
    ref.watch(babyLocalDatasourceProvider),
    syncQueue: ref.watch(syncQueueProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
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
  return DeleteBabyUseCase(
    ref.watch(babyRepositoryProvider),
    remoteCascade: (babyId) async {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (!FirebaseBootstrap.isInitialized || uid == null) return;
      try {
        await deleteBabyCascade(
          FirebaseFirestore.instance,
          uid: uid,
          babyId: babyId,
        );
      } catch (error) {
        debugPrint('Hapus bayi di Firestore belum berhasil: $error');
      }
    },
  );
});

// -- Immunization -------------------------------------------------------------
final vaccineLocalDatasourceProvider = Provider<VaccineLocalDatasource>((ref) {
  return const VaccineLocalDatasource();
});

final vaccineRemoteDatasourceProvider =
    Provider<VaccineRemoteDatasource?>((ref) {
  if (!FirebaseBootstrap.isInitialized) return null;
  return FirebaseVaccineRemoteDatasource();
});

final immunizationRepositoryProvider = Provider<IImmunizationRepository>((ref) {
  return ImmunizationRepositoryImpl(
    ref.watch(vaccineLocalDatasourceProvider),
    syncQueue: ref.watch(syncQueueProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
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

final growthRemoteDatasourceProvider =
    Provider<GrowthRemoteDatasource?>((ref) {
  if (!FirebaseBootstrap.isInitialized) return null;
  return FirebaseGrowthRemoteDatasource();
});

final growthRepositoryProvider = Provider<IGrowthRepository>((ref) {
  return GrowthRepositoryImpl(
    ref.watch(growthLocalDatasourceProvider),
    syncQueue: ref.watch(syncQueueProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
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

final healthJournalRemoteDatasourceProvider =
    Provider<HealthJournalRemoteDatasource?>((ref) {
  if (!FirebaseBootstrap.isInitialized) return null;
  return FirebaseHealthJournalRemoteDatasource();
});

final healthJournalRepositoryProvider = Provider<IHealthJournalRepository>((
  ref,
) {
  return HealthJournalRepositoryImpl(
    ref.watch(healthJournalLocalDatasourceProvider),
    syncQueue: ref.watch(syncQueueProvider),
    networkInfo: ref.watch(networkInfoProvider),
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

// -- Education (Quiz Score) ----------------------------------------------------
final quizScoreRemoteDatasourceProvider =
    Provider<QuizScoreRemoteDatasource?>((ref) {
  if (!FirebaseBootstrap.isInitialized) return null;
  return FirebaseQuizScoreRemoteDatasource();
});
