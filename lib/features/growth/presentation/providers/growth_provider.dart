import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive_ce.dart';
import '../../data/models/growth_record_model.dart';

class GrowthNotifier extends FamilyAsyncNotifier<List<GrowthRecordModel>, String> {
  @override
  Future<List<GrowthRecordModel>> build(String arg) async {
    final box = await Hive.openBox<GrowthRecordModel>('growthRecordsBox');
    final records = box.values.where((r) => r.babyId == arg).toList();
    records.sort((a, b) => a.tanggalPengukuran.compareTo(b.tanggalPengukuran));
    return records;
  }

  Future<void> addRecord(GrowthRecordModel record) async {
    final box = await Hive.openBox<GrowthRecordModel>('growthRecordsBox');
    await box.put(record.recordId, record);
    ref.invalidateSelf();
  }
}

final growthProvider = AsyncNotifierProviderFamily<GrowthNotifier, List<GrowthRecordModel>, String>(
  GrowthNotifier.new,
);
