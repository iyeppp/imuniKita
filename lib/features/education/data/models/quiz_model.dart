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

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      quizId: (json['quizId'] as String?) ?? '',
      judul: (json['judul'] as String?) ?? '',
      deskripsi: (json['deskripsi'] as String?) ?? '',
      kategori: (json['kategori'] as String?) ?? '',
      soal: (json['soal'] as List<dynamic>?)
              ?.map((s) => QuizQuestion.fromJson(s as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
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

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      pertanyaan: (json['pertanyaan'] as String?) ?? '',
      pilihan: (json['pilihan'] as List<dynamic>?)
              ?.map((p) => p.toString())
              .toList() ??
          const [],
      indexJawabanBenar: (json['indexJawabanBenar'] as num?)?.toInt() ?? 0,
      penjelasan: (json['penjelasan'] as String?) ?? '',
    );
  }
}
