import '../models/faskes_model.dart';

/// Konstanta tipe fasilitas kesehatan — dipakai chip filter & marker peta.
abstract class FaskesTipe {
  static const String semua = 'Semua';
  static const String rs = 'RS';
  static const String puskesmas = 'Puskesmas';
  static const String klinik = 'Klinik';
  static const String apotek = 'Apotek';

  /// Urutan tampil di chip filter.
  static const List<String> filter = [semua, rs, puskesmas, klinik, apotek];
}

/// Sumber data mock fasilitas kesehatan (FR-06) — fase UTS.
///
/// Mencakup minimal 12 faskes di 3 kota (Jakarta, Bandung, Surabaya) dengan
/// seluruh 4 tipe terwakili. Di fase UAS, kelas ini diganti implementasi yang
/// mengambil data dari API — screen dan provider tidak perlu diubah.
class FaskesMockDatasource {
  const FaskesMockDatasource();

  /// Seluruh data faskes.
  List<FaskesModel> getAll() => _faskes;

  /// Filter berdasarkan [tipe]; kembalikan semua bila [tipe] == [FaskesTipe.semua].
  List<FaskesModel> getByTipe(String tipe) {
    if (tipe == FaskesTipe.semua) return _faskes;
    return _faskes.where((f) => f.tipe == tipe).toList();
  }

  // ── Data Mock ─────────────────────────────────────────────────────────────

  static const List<FaskesModel> _faskes = [
    // ── Jakarta ──────────────────────────────────────────────────────────
    FaskesModel(
      id: 'rs-01',
      nama: 'RSUPN Dr. Cipto Mangunkusumo',
      tipe: FaskesTipe.rs,
      alamat: 'Jl. Diponegoro No.71',
      kota: 'Jakarta Pusat',
      telepon: '+62213144566',
      lat: -6.1924,
      lng: 106.8452,
      jamOperasional: '24 Jam',
    ),
    FaskesModel(
      id: 'rs-02',
      nama: 'RS Anak & Bunda Harapan Kita',
      tipe: FaskesTipe.rs,
      alamat: 'Jl. Let. Jend. S. Parman Kav. 87',
      kota: 'Jakarta Barat',
      telepon: '+62215600044',
      lat: -6.1802,
      lng: 106.7922,
      jamOperasional: '24 Jam',
    ),
    FaskesModel(
      id: 'pkm-01',
      nama: 'Puskesmas Kemayoran',
      tipe: FaskesTipe.puskesmas,
      alamat: 'Jl. Landas Pacu Timur No.1',
      kota: 'Jakarta Pusat',
      telepon: '+62214247945',
      lat: -6.1571,
      lng: 106.8573,
      jamOperasional: 'Senin–Jumat 08.00–15.00',
    ),
    FaskesModel(
      id: 'pkm-02',
      nama: 'Puskesmas Tebet',
      tipe: FaskesTipe.puskesmas,
      alamat: 'Jl. Tebet Barat Dalam VIII No.1',
      kota: 'Jakarta Selatan',
      telepon: '+62218294520',
      lat: -6.2246,
      lng: 106.8491,
      jamOperasional: 'Senin–Jumat 07.30–16.00',
    ),
    FaskesModel(
      id: 'kln-01',
      nama: 'Klinik Pratama Medistra',
      tipe: FaskesTipe.klinik,
      alamat: 'Jl. Gatot Subroto Kav. 59',
      kota: 'Jakarta Selatan',
      telepon: '+62215200700',
      lat: -6.2285,
      lng: 106.8223,
      jamOperasional: 'Setiap Hari 07.00–21.00',
    ),
    FaskesModel(
      id: 'apt-01',
      nama: 'Apotek Kimia Farma Salemba',
      tipe: FaskesTipe.apotek,
      alamat: 'Jl. Salemba Raya No.26',
      kota: 'Jakarta Pusat',
      telepon: '+62213921773',
      lat: -6.1989,
      lng: 106.8528,
      jamOperasional: 'Setiap Hari 08.00–22.00',
    ),

    // ── Bandung ───────────────────────────────────────────────────────────
    FaskesModel(
      id: 'rs-03',
      nama: 'RSUP Dr. Hasan Sadikin',
      tipe: FaskesTipe.rs,
      alamat: 'Jl. Pasteur No.38',
      kota: 'Bandung',
      telepon: '+622220401067',
      lat: -6.8963,
      lng: 107.5985,
      jamOperasional: '24 Jam',
    ),
    FaskesModel(
      id: 'pkm-03',
      nama: 'Puskesmas Sukajadi',
      tipe: FaskesTipe.puskesmas,
      alamat: 'Jl. Sukajadi No.149',
      kota: 'Bandung',
      telepon: '+6222204510',
      lat: -6.8883,
      lng: 107.5951,
      jamOperasional: 'Senin–Sabtu 08.00–14.00',
    ),
    FaskesModel(
      id: 'kln-02',
      nama: 'Klinik Ibu & Anak Bunda Sehat',
      tipe: FaskesTipe.klinik,
      alamat: 'Jl. Cihampelas No.212',
      kota: 'Bandung',
      telepon: '+6222200870',
      lat: -6.9013,
      lng: 107.6082,
      jamOperasional: 'Senin–Sabtu 09.00–20.00',
    ),
    FaskesModel(
      id: 'apt-02',
      nama: 'Apotek Guardian Dago',
      tipe: FaskesTipe.apotek,
      alamat: 'Jl. Ir. H. Juanda No.65',
      kota: 'Bandung',
      telepon: '+6222250950',
      lat: -6.8978,
      lng: 107.6110,
      jamOperasional: 'Setiap Hari 09.00–21.00',
    ),

    // ── Surabaya ──────────────────────────────────────────────────────────
    FaskesModel(
      id: 'rs-04',
      nama: 'RSUD Dr. Soetomo',
      tipe: FaskesTipe.rs,
      alamat: 'Jl. Mayjend Prof. Dr. Moestopo No.6',
      kota: 'Surabaya',
      telepon: '+62315501078',
      lat: -7.2719,
      lng: 112.7577,
      jamOperasional: '24 Jam',
    ),
    FaskesModel(
      id: 'pkm-04',
      nama: 'Puskesmas Kedungdoro',
      tipe: FaskesTipe.puskesmas,
      alamat: 'Jl. Kedungdoro No.89',
      kota: 'Surabaya',
      telepon: '+62315342451',
      lat: -7.2617,
      lng: 112.7308,
      jamOperasional: 'Senin–Jumat 08.00–15.00',
    ),
    FaskesModel(
      id: 'kln-03',
      nama: 'Klinik Sehat Mandiri',
      tipe: FaskesTipe.klinik,
      alamat: 'Jl. Raya Darmo No.60',
      kota: 'Surabaya',
      telepon: '+62315677890',
      lat: -7.2871,
      lng: 112.7334,
      jamOperasional: 'Setiap Hari 08.00–20.00',
    ),
    FaskesModel(
      id: 'apt-03',
      nama: 'Apotek K-24 Basuki Rahmat',
      tipe: FaskesTipe.apotek,
      alamat: 'Jl. Basuki Rahmat No.93',
      kota: 'Surabaya',
      telepon: '+62315315900',
      lat: -7.2575,
      lng: 112.7411,
      jamOperasional: '24 Jam',
    ),
  ];
}
