import '../entities/baby_entity.dart';

/// Kontrak repository profil bayi.
abstract class IBabyRepository {
  /// Seluruh bayi yang terdaftar milik [userId].
  Future<List<BabyEntity>> getBabiesByUser(String userId);

  /// Detail satu bayi, atau `null` bila tidak ditemukan.
  Future<BabyEntity?> getBabyById(String babyId);

  /// Simpan bayi baru, mengembalikan entity yang tersimpan.
  Future<BabyEntity> addBaby(BabyEntity baby);

  /// Perbarui data bayi yang sudah ada.
  Future<BabyEntity> updateBaby(BabyEntity baby);

  /// Hapus profil bayi beserta data turunannya (setelah konfirmasi user).
  Future<void> deleteBaby(String babyId);
}
