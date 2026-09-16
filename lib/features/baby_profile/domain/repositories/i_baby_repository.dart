import '../entities/baby_entity.dart';

/// Kontrak repository profil bayi.
///
/// Fase UTS diimplementasikan oleh `BabyRepositoryImpl` di atas Hive CE.
/// Fase UAS tinggal mengganti implementasi ini agar memakai Firestore,
/// tanpa mengubah use case atau UI (lihat dev plan §6.1).
abstract class IBabyRepository {
  /// Seluruh bayi yang terdaftar milik [userId].
  Future<List<BabyEntity>> getBabiesByUser(String userId);

  /// Detail satu bayi, atau `null` bila tidak ditemukan.
  Future<BabyEntity?> getBabyById(String babyId);

  /// Simpan bayi baru, mengembalikan entity yang tersimpan.
  Future<BabyEntity> addBaby(BabyEntity baby);

  /// Perbarui data bayi yang sudah ada.
  Future<BabyEntity> updateBaby(BabyEntity baby);
}
