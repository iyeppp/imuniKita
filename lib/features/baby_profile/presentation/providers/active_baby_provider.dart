import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/local_storage_service.dart';
import '../../domain/entities/baby_entity.dart';
import 'baby_provider.dart';

/// Bayi yang sedang dipilih ("bayi aktif") —.
class ActiveBabyNotifier extends AsyncNotifier<BabyEntity?> {
  @override
  Future<BabyEntity?> build() async {
    final babies = await ref.watch(babyNotifierProvider.future);
    if (babies.isEmpty) {
      // Tidak ada bayi → bersihkan pilihan lama agar tidak menunjuk ke data yang sudah tidak ada.
      await LocalStorageService.clearActiveBabyId();
      return null;
    }

    final tersimpan = await LocalStorageService.getActiveBabyId();
    final aktif = _cari(babies, tersimpan) ?? babies.first;

    if (aktif.babyId != tersimpan) {
      await LocalStorageService.setActiveBabyId(aktif.babyId);
    }

    return aktif;
  }

  /// Pilih bayi aktif — dipakai daftar anak di layar Profil & Pengaturan.
  Future<void> selectBaby(String babyId) async {
    await LocalStorageService.setActiveBabyId(babyId);
    ref.invalidateSelf();
  }

  static BabyEntity? _cari(List<BabyEntity> babies, String? babyId) {
    if (babyId == null) return null;
    for (final baby in babies) {
      if (baby.babyId == babyId) return baby;
    }
    return null;
  }
}

final activeBabyProvider =
    AsyncNotifierProvider<ActiveBabyNotifier, BabyEntity?>(
      ActiveBabyNotifier.new,
    );
