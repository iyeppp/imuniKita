/// Model fasilitas kesehatan untuk Direktori Faskes (FR-06).
///
/// Plain Dart class — tidak dipersist ke Hive karena data bersumber dari
/// mock datasource. Fase UAS: ganti datasource, model ini tidak perlu diubah.
class FaskesModel {
  const FaskesModel({
    required this.id,
    required this.nama,
    required this.tipe,
    required this.alamat,
    required this.kota,
    required this.telepon,
    required this.lat,
    required this.lng,
    required this.jamOperasional,
  });

  final String id;
  final String nama;

  /// Salah satu nilai di [FaskesTipe]: 'RS', 'Puskesmas', 'Klinik', 'Apotek'.
  final String tipe;
  final String alamat;
  final String kota;
  final String telepon;
  final double lat;
  final double lng;
  final String jamOperasional;
}
