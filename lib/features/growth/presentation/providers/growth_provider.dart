import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive_ce.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/models/growth_record_model.dart';

class GrowthNotifier extends FamilyAsyncNotifier<List<GrowthRecordModel>, String> {
  @override
  Future<List<GrowthRecordModel>> build(String arg) async {
    final box = await Hive.openBox<GrowthRecordModel>(AppConstants.growthRecordsBox);
    final records = box.values.where((r) => r.babyId == arg).toList();
    records.sort((a, b) => a.tanggalPengukuran.compareTo(b.tanggalPengukuran));
    return records;
  }

  Future<void> addRecord(GrowthRecordModel record) async {
    final box = await Hive.openBox<GrowthRecordModel>(AppConstants.growthRecordsBox);
    await box.put(record.recordId, record);
    ref.invalidateSelf();
  }


  /// Hapus seluruh rekam pertumbuhan bayi ini (dipakai saat bayi dihapus).
  Future<void> deleteAllForBaby() async {
    final box = await Hive.openBox<GrowthRecordModel>(AppConstants.growthRecordsBox);
    final ids = box.values.where((r) => r.babyId == arg).map((r) => r.recordId).toList();
    await box.deleteAll(ids);
    ref.invalidateSelf();
  }
}

final growthProvider = AsyncNotifierProviderFamily<GrowthNotifier, List<GrowthRecordModel>, String>(
  GrowthNotifier.new,
);
