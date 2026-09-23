import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/local_storage_service.dart';
import '../../../../injection/dependency_injection.dart';
import '../../domain/entities/baby_entity.dart';

/// State list bayi milik user yang sedang login.
///
/// Pola `AsyncNotifier` tanpa codegen — lihat dev plan §2. `build()` otomatis
/// dipanggil ulang lewat `ref.invalidateSelf()` setiap kali ada perubahan
/// data (tambah/update bayi), sehingga screen manapun yang me-`watch`
/// provider ini selalu mendapat data terbaru.
class BabyNotifier extends AsyncNotifier<List<BabyEntity>> {
  @override
  Future<List<BabyEntity>> build() async {
    final userId = await LocalStorageService.getCurrentUserId();
    if (userId == null) return [];
    return ref.read(getBabiesUseCaseProvider).execute(userId);
  }

  /// Simpan bayi baru dan refresh list. Mengembalikan entity yang tersimpan
  /// agar pemanggil (mis. `AddBabyScreen`) bisa langsung memicu
  /// `GenerateScheduleUseCase` dengan `babyId` yang baru dibuat.
  Future<BabyEntity> addBaby(BabyEntity baby) async {
    final created = await ref.read(addBabyUseCaseProvider).execute(baby);
    ref.invalidateSelf();
    return created;
  }

  Future<void> updateBaby(BabyEntity baby) async {
    await ref.read(updateBabyUseCaseProvider).execute(baby);
    ref.invalidateSelf();
  }

  /// Hapus profil bayi. Data turunan (jadwal, pertumbuhan, jurnal) dibersihkan
  /// pemanggil lewat provider masing-masing fitur — lihat `BabyDetailScreen`.
  Future<void> deleteBaby(String babyId) async {
    await ref.read(deleteBabyUseCaseProvider).execute(babyId);
    ref.invalidateSelf();
  }
}

final babyNotifierProvider =
    AsyncNotifierProvider<BabyNotifier, List<BabyEntity>>(BabyNotifier.new);

/// Detail satu bayi berdasarkan id — dipakai `BabyDetailScreen` (Temuan #21).
final babyByIdProvider = FutureProvider.family<BabyEntity?, String>((
  ref,
  babyId,
) {
  return ref.read(babyRepositoryProvider).getBabyById(babyId);
});
