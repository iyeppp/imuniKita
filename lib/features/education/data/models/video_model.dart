/// Model konten video edukasi (FR-05).
///
/// Fase UTS: konten mock dari `EducationMockDatasource`; di fase UAS bisa
/// diarahkan ke CMS/video resmi.
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

  /// Thumbnail grid. `null` → UI memakai placeholder gradien + ikon.
  final String? thumbnailUrl;

  /// Badge durasi pada grid video, mis. `4:35`.
  String get durasiLabel {
    final menit = durasiDetik ~/ 60;
    final detik = durasiDetik % 60;
    return '$menit:${detik.toString().padLeft(2, '0')}';
  }

  /// URL yang dibuka saat video di-tap.
  ///
  /// Fase UTS belum punya video yang di-host sendiri, jadi yang dibuka adalah
  /// **pencarian YouTube** berdasarkan judul — selalu valid dan tidak pernah
  /// menghasilkan tautan mati. UAS: ganti ke URL video asli dari CMS.
  String get tontonUrl =>
      'https://www.youtube.com/results?search_query=${Uri.encodeComponent(judul)}';
}
