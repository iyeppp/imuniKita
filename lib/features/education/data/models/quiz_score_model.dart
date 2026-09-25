import 'dart:math' as math;

import 'package:hive_ce/hive_ce.dart';

part 'quiz_score_model.g.dart';

/// Skor kuis yang sudah dikerjakan user (FR-05, poin 5.3).
///
/// Dipersist ke Hive CE box `educationQuizScoresBox` dengan key `quizId`,
/// sehingga Education Hub bisa menampilkan badge "Sudah dikerjakan ✓"
/// tanpa perlu fetch ulang.
///
/// Temuan #15: field [attemptCount] dan [riwayatSkor] menyimpan **riwayat**
/// percobaan (sebelumnya skor lama selalu ditimpa). Keduanya nullable agar
/// data lama yang belum punya field ini tetap terbaca.
@HiveType(typeId: 5)
class QuizScoreModel extends HiveObject {
  @HiveField(0)
  late String quizId;

  /// Jumlah jawaban benar pada percobaan **terakhir**.
  @HiveField(1)
  late int skor;

  /// Jumlah soal kuis saat dikerjakan (total soal kuis bisa berubah).
  @HiveField(2)
  late int totalSoal;

  @HiveField(3)
  late DateTime tanggalPengerjaan;

  /// Berapa kali kuis ini dikerjakan (minimal 1).
  @HiveField(4)
  int? attemptCount;

  /// Skor tiap percobaan, urut lama → baru.
  @HiveField(5)
  List<int>? riwayatSkor;

  QuizScoreModel({
    required this.quizId,
    required this.skor,
    required this.totalSoal,
    required this.tanggalPengerjaan,
    this.attemptCount,
    this.riwayatSkor,
  });

  /// Persentase 0–100, dipakai untuk badge hasil akhir.
  int get persentase => totalSoal == 0 ? 0 : ((skor / totalSoal) * 100).round();

  /// Jumlah percobaan (data lama dianggap 1×).
  int get totalPercobaan => attemptCount ?? 1;

  /// Skor benar tertinggi dari seluruh percobaan (`null` bila riwayat kosong).
  int? get skorTerbaik {
    final riwayat = riwayatSkor;
    if (riwayat == null || riwayat.isEmpty) return null;
    return riwayat.reduce(math.max);
  }
}
