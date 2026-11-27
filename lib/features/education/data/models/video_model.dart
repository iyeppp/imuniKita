/// Model konten video edukasi (FR-05).
class VideoModel {
  const VideoModel({
    required this.videoId,
    required this.judul,
    required this.kategori,
    required this.deskripsi,
    required this.durasiDetik,
    this.thumbnailUrl,
  });

  final String videoId;
  final String judul;

  /// Salah satu nilai di `EducationKategori` (mis. 'Nutrisi').
  final String kategori;
  final String deskripsi;
  final int durasiDetik;

  /// Thumbnail grid.
  final String? thumbnailUrl;

  /// Badge durasi pada grid video, mis. `4:35`.
  String get durasiLabel {
    final menit = durasiDetik ~/ 60;
    final detik = durasiDetik % 60;
    return '$menit:${detik.toString().padLeft(2, '0')}';
  }

  /// URL yang dibuka saat video di-tap.
  String get tontonUrl =>
      'https://www.youtube.com/results?search_query=${Uri.encodeComponent(judul)}';

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      videoId: (json['videoId'] as String?) ?? '',
      judul: (json['judul'] as String?) ?? '',
      kategori: (json['kategori'] as String?) ?? '',
      deskripsi: (json['deskripsi'] as String?) ?? '',
      durasiDetik: (json['durasiDetik'] as num?)?.toInt() ?? 180,
      thumbnailUrl: json['thumbnailUrl'] as String?,
    );
  }
}
