import 'dart:async';

import '../repositories/i_baby_repository.dart';

/// Hapus profil bayi berdasarkan [babyId].
///
/// Hanya menghapus **profilnya**; pembersihan data turunan (jadwal imunisasi,
/// rekam pertumbuhan, jurnal kesehatan) diorkestrasi lapisan presentation
/// karena setiap fitur memiliki box/provider sendiri — lihat `BabyDetailScreen`.
/// Bila nanti dipindahkan ke domain, buat `BabyDataService` yang menyatukan
/// keempat repository.
///
/// [remoteCascade] membersihkan salinan bayi di Firestore (subkoleksi ikut
/// terhapus). Dijalankan **tanpa menunggu** agar penghapusan lokal tidak
/// tertahan saat offline; kegagalan/antrean ditangani di tahap sinkronisasi.
class DeleteBabyUseCase {
  const DeleteBabyUseCase(this._repository, {this.remoteCascade});

  final IBabyRepository _repository;
  final Future<void> Function(String babyId)? remoteCascade;

  Future<void> execute(String babyId) async {
    await _repository.deleteBaby(babyId);
    final cascade = remoteCascade;
    if (cascade != null) {
      unawaited(cascade(babyId).catchError((Object error, StackTrace stack) {}));
    }
  }
}
