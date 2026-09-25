import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../injection/dependency_injection.dart';
import '../../domain/entities/health_journal_entity.dart';

/// Seluruh catatan jurnal kesehatan satu bayi (terurut baru → lama).
///
/// Sejak Temuan #32 dibaca lewat `IHealthJournalRepository` (bukan
/// `Hive.openBox` langsung) sehingga error dibungkus `Failure` dan data source
/// siap di-swap ke Firestore pada fase UAS (dev plan §6.1).
class JournalNotifier
    extends FamilyAsyncNotifier<List<HealthJournalEntity>, String> {
  @override
  Future<List<HealthJournalEntity>> build(String arg) {
    return ref.read(getHealthJournalsUseCaseProvider).execute(arg);
  }

  /// Simpan satu catatan jurnal (layar Tambah Jurnal 4.4 & form KIPI 3.3).
  Future<void> addJournal(HealthJournalEntity journal) async {
    await ref.read(addHealthJournalUseCaseProvider).execute(journal);
    ref.invalidateSelf();
  }

  /// Hapus satu catatan (swipe-to-delete di daftar jurnal 4.3).
  Future<void> deleteJournal(String journalId) async {
    await ref.read(deleteHealthJournalUseCaseProvider).execute(journalId);
    ref.invalidateSelf();
  }

  /// Hapus seluruh jurnal bayi ini (dipakai saat bayi dihapus).
  Future<void> deleteAllForBaby() async {
    await ref.read(deleteHealthJournalsByBabyUseCaseProvider).execute(arg);
    ref.invalidateSelf();
  }
}

final journalProvider =
    AsyncNotifierProviderFamily<
      JournalNotifier,
      List<HealthJournalEntity>,
      String
    >(JournalNotifier.new);
