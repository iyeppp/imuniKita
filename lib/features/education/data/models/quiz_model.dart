/// Model kuis edukasi (FR-05).
///
/// Kuis memakai pola *single select*: user memilih satu dari [QuizQuestion.pilihan],
/// lalu langsung mendapat feedback `Benar`/`Salah` beserta penjelasan.
class QuizModel {
  const QuizModel({
    required this.quizId,
    required this.judul,
    required this.deskripsi,
    required this.kategori,
    required this.soal,
  });

  final String quizId;
  final String judul;
  final String deskripsi;

  /// Salah satu nilai di `EducationKategori` (mis. 'Tumbuh Kembang').
  final String kategori;
  final List<QuizQuestion> soal;

  int get totalSoal => soal.length;
}

/// Satu butir soal pilihan ganda.
class QuizQuestion {
  const QuizQuestion({
    required this.pertanyaan,
    required this.pilihan,
    required this.indexJawabanBenar,
    required this.penjelasan,
  });

  final String pertanyaan;

  /// Empat pilihan jawaban (index 0–3).
  final List<String> pilihan;

  /// Index jawaban benar di dalam [pilihan].
  final int indexJawabanBenar;

  /// Ditampilkan sebagai feedback langsung setelah user menjawab.
  final String penjelasan;

  String get jawabanBenar => pilihan[indexJawabanBenar];
}
