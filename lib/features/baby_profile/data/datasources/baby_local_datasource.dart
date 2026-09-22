import 'package:hive_ce/hive_ce.dart';

import '../../../../core/constants/app_constants.dart';
import '../models/baby_model.dart';

/// Sumber data lokal profil bayi via Hive CE.
///
/// `[UAS]`: akan didampingi `baby_remote_datasource.dart` (Firestore) —
/// lihat dev plan §1.1 & §6.1. `BabyRepositoryImpl` yang memutuskan sumber
/// mana yang dipakai lewat `AppConstants.isUASPhase`.
class BabyLocalDatasource {
  const BabyLocalDatasource();

  Future<Box<BabyModel>> _openBox() =>
      Hive.openBox<BabyModel>(AppConstants.babiesBox);

  Future<List<BabyModel>> getByUser(String userId) async {
    final box = await _openBox();
    return box.values.where((baby) => baby.userId == userId).toList();
  }

  Future<BabyModel?> getById(String babyId) async {
    final box = await _openBox();
    try {
      return box.values.firstWhere((baby) => baby.babyId == babyId);
    } on StateError {
      return null;
    }
  }

  Future<BabyModel> add(BabyModel model) async {
    final box = await _openBox();
    await box.put(model.babyId, model);
    return model;
  }

  Future<BabyModel> update(BabyModel model) async {
    final box = await _openBox();
    await box.put(model.babyId, model);
    return model;
  }
}
