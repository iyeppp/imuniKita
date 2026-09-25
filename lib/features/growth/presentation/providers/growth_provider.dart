import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../injection/dependency_injection.dart';
import '../../domain/entities/growth_record_entity.dart';

/// Seluruh rekam pertumbuhan satu bayi (terurut lama → baru).
///
/// Sejak Temuan #32 dibaca lewat `IGrowthRepository` (bukan `Hive.openBox`
/// langsung), sehingga error dibungkus `Failure` dan data source bisa di-swap
/// ke Firestore pada fase UAS tanpa menyentuh layar mana pun.
class GrowthNotifier
    extends FamilyAsyncNotifier<List<GrowthRecordEntity>, String> {
  @override
  Future<List<GrowthRecordEntity>> build(String arg) {
    return ref.read(getGrowthRecordsUseCaseProvider).execute(arg);
  }

  /// Simpan satu rekam pengukuran (layar Tambah Pengukuran 4.2).
  Future<void> addRecord(GrowthRecordEntity record) async {
    await ref.read(addGrowthRecordUseCaseProvider).execute(record);
    ref.invalidateSelf();
  }

  /// Hapus seluruh rekam pertumbuhan bayi ini (dipakai saat bayi dihapus).
  Future<void> deleteAllForBaby() async {
    await ref.read(deleteGrowthRecordsByBabyUseCaseProvider).execute(arg);
    ref.invalidateSelf();
  }
}

final growthProvider =
    AsyncNotifierProviderFamily<
      GrowthNotifier,
      List<GrowthRecordEntity>,
      String
    >(GrowthNotifier.new);
