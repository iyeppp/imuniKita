import 'package:hive_ce/hive_ce.dart';

part 'quiz_score_model.g.dart';

/// Skor kuis yang sudah dikerjakan user (FR-05, poin 5.3).
///
/// Dipersist ke Hive CE box `educationQuizScoresBox` dengan key `quizId`,
/// sehingga Education Hub bisa menampilkan badge "Sudah dikerjakan ✓"
/// tanpa perlu fetch ulang.
@HiveType(typeId: 5)
class QuizScoreModel extends HiveObject {
  @HiveField(0)
  late String quizId;

  /// Jumlah jawaban benar.
  @HiveField(1)
  late int skor;

  /// Jumlah soal kuis saat dikerjakan (total soal kuis bisa berubah).
  @HiveField(2)
  late int totalSoal;

  @HiveField(3)
  late DateTime tanggalPengerjaan;

  QuizScoreModel({
    required this.quizId,
    required this.skor,
    required this.totalSoal,
    required this.tanggalPengerjaan,
  });

  /// Persentase 0–100, dipakai untuk badge hasil akhir.
  int get persentase => totalSoal == 0 ? 0 : ((skor / totalSoal) * 100).round();
}
