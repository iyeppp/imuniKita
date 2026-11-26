/// Model konten artikel edukasi (FR-05).
///
/// Fase UTS: konten dibaca dari `EducationMockDatasource` (hardcoded), sehingga
/// model ini tidak dipersist ke Hive. Di fase UAS sumbernya diganti CMS API
/// (dev plan §6.4) tanpa mengubah screen-nya.
class ArticleModel {
  const ArticleModel({
    required this.articleId,
    required this.judul,
    required this.kategori,
    required this.penulis,
    required this.ringkasan,
    required this.kontenHtml,
    required this.tanggalPublish,
    required this.estimasiBacaMenit,
    this.imageUrl,
  });

  final String articleId;
  final String judul;

  /// Salah satu nilai di `EducationKategori` (mis. 'Imunisasi').
  final String kategori;
  final String penulis;

  /// Ringkasan singkat untuk kartu di Education Hub.
  final String ringkasan;

  /// Body artikel dalam HTML — dirender `flutter_html` di Article Detail.
  final String kontenHtml;
  final DateTime tanggalPublish;
  final int estimasiBacaMenit;

  /// Thumbnail & hero image. `null` → UI memakai placeholder gradien + ikon
  /// agar tetap tampil rapi saat perangkat offline.
  final String? imageUrl;

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      articleId: (json['articleId'] as String?) ?? '',
      judul: (json['judul'] as String?) ?? '',
      kategori: (json['kategori'] as String?) ?? '',
      penulis: (json['penulis'] as String?) ?? '',
      ringkasan: (json['ringkasan'] as String?) ?? '',
      kontenHtml: (json['kontenHtml'] as String?) ?? '',
      tanggalPublish: json['tanggalPublish'] != null
          ? DateTime.parse(json['tanggalPublish'] as String)
          : DateTime.now(),
      estimasiBacaMenit: (json['estimasiBacaMenit'] as num?)?.toInt() ?? 3,
      imageUrl: json['imageUrl'] as String?,
    );
  }
}
