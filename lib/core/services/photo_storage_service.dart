import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Service terpusat untuk menyimpan & menghapus foto profil anak secara persisten (B7-2, B7-4).
///
/// Kebijakan (ADR 0001):
/// - Foto hanya disimpan lokal di folder `<docsDir>/baby_photos/<babyId>.jpg`.
/// - Foto TIDAK diunggah ke cloud (tanpa Firebase Storage).
class PhotoStorageService {
  PhotoStorageService({Future<Directory> Function()? getDocsDir})
      : _getDocsDir = getDocsDir ?? getApplicationDocumentsDirectory;

  final Future<Directory> Function() _getDocsDir;

  /// Mengambil folder tempat foto profil anak disimpan (`<docsDir>/baby_photos`).
  Future<Directory> get photosDirectory async {
    final docsDir = await _getDocsDir();
    final photosDir = Directory('${docsDir.path}/baby_photos');
    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
    }
    return photosDir;
  }

  /// Menyimpan/menyalin foto dari [sourceFile] ke lokasi persisten `<docsDir>/baby_photos/<babyId>.jpg`.
  ///
  /// Mengembalikan path file persisten yang baru.
  Future<String> savePhoto(File sourceFile, String babyId) async {
    try {
      if (!await sourceFile.exists()) {
        return sourceFile.path;
      }

      final dir = await photosDirectory;
      final targetPath = '${dir.path}/$babyId.jpg';
      final targetFile = File(targetPath);

      // Jika file target lama sudah ada, hapus dulu
      if (await targetFile.exists()) {
        await targetFile.delete();
      }

      final savedFile = await sourceFile.copy(targetPath);
      return savedFile.path;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('PhotoStorageService: Gagal menyimpan foto untuk $babyId: $e');
      }
      return sourceFile.path;
    }
  }

  /// Menghapus file foto lokal jika ada.
  Future<void> deletePhoto(String? photoPath) async {
    if (photoPath == null || photoPath.trim().isEmpty) return;

    try {
      final file = File(photoPath);
      if (await file.exists()) {
        await file.delete();
        if (kDebugMode) {
          debugPrint('PhotoStorageService: Foto $photoPath berhasil dihapus.');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('PhotoStorageService: Gagal menghapus foto $photoPath: $e');
      }
    }
  }
}
