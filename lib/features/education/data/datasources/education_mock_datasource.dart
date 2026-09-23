import '../models/article_model.dart';
import '../models/quiz_model.dart';
import '../models/video_model.dart';

/// Kategori konten edukasi — dipakai chip filter di Education Hub.
abstract class EducationKategori {
  static const String semua = 'Semua';
  static const String imunisasi = 'Imunisasi';
  static const String nutrisi = 'Nutrisi';
  static const String tumbuhKembang = 'Tumbuh Kembang';
  static const String mpasi = 'MPASI';

  /// Daftar untuk chip filter (termasuk opsi "Semua").
  static const List<String> filter = [
    semua,
    imunisasi,
    nutrisi,
    tumbuhKembang,
    mpasi,
  ];
}

/// Sumber data mock konten edukasi (FR-05) — fase UTS.
///
/// Seluruh konten di-hardcode di sini sesuai dev plan §1.1
/// (`education_mock_datasource.dart # [UTS] hardcoded mock`). Di fase UAS,
/// kelas ini diganti implementasi yang menarik data dari CMS API — screen
/// tidak perlu diubah karena semua akses konten lewat datasource ini.
class EducationMockDatasource {
  const EducationMockDatasource();

  // ── Artikel ────────────────────────────────────────────────────────────

  /// Artikel, opsional difilter per [kategori] (`EducationKategori.semua` = tanpa filter).
  List<ArticleModel> getArtikel({String kategori = EducationKategori.semua}) {
    if (kategori == EducationKategori.semua) return _artikel;
    return _artikel.where((a) => a.kategori == kategori).toList();
  }

  ArticleModel? getArtikelById(String articleId) {
    for (final artikel in _artikel) {
      if (artikel.articleId == articleId) return artikel;
    }
    return null;
  }

  /// Artikel terkait: kategori sama dulu, lalu dilengkapi artikel lain
  /// agar section "Artikel Terkait" tidak pernah kosong.
  List<ArticleModel> getArtikelTerkait(ArticleModel artikel, {int limit = 3}) {
    final hasil = <ArticleModel>[];
    final kandidat = [
      ..._artikel.where((a) => a.kategori == artikel.kategori),
      ..._artikel,
    ];

    for (final item in kandidat) {
      if (item.articleId == artikel.articleId) continue;
      if (hasil.any((a) => a.articleId == item.articleId)) continue;
      hasil.add(item);
      if (hasil.length == limit) break;
    }
    return hasil;
  }

  // ── Video ──────────────────────────────────────────────────────────────

  List<VideoModel> getVideo({String kategori = EducationKategori.semua}) {
    if (kategori == EducationKategori.semua) return _video;
    return _video.where((v) => v.kategori == kategori).toList();
  }

  // ── Kuis ───────────────────────────────────────────────────────────────

  List<QuizModel> getKuis({String kategori = EducationKategori.semua}) {
    if (kategori == EducationKategori.semua) return _kuis;
    return _kuis.where((q) => q.kategori == kategori).toList();
  }

  QuizModel? getKuisById(String quizId) {
    for (final kuis in _kuis) {
      if (kuis.quizId == quizId) return kuis;
    }
    return null;
  }

  // ───────────────────────────────────────────────────────────────────────
  // Konten hardcoded
  // ───────────────────────────────────────────────────────────────────────

  static final List<ArticleModel> _artikel = [
    ArticleModel(
      articleId: 'art-01',
      judul: 'Mengenal Imunisasi Dasar Lengkap untuk Bayi',
      kategori: EducationKategori.imunisasi,
      penulis: 'Tim ImuniKita',
      ringkasan: 'Imunisasi dasar melindungi bayi dari penyakit yang berbahaya. Kenali jenis, manfaat, dan kapan jadwalnya dimulai.',
      tanggalPublish: DateTime(2026, 9, 12),
      estimasiBacaMenit: 5,
      imageUrl: 'https://images.unsplash.com/photo-1584515933487-779824d29309',
      kontenHtml: '''
<h3>Apa itu imunisasi dasar lengkap?</h3>
<p>Imunisasi dasar lengkap adalah rangkaian vaksinasi wajib yang diberikan sejak bayi baru lahir hingga usia 18 bulan. Tujuannya membentuk kekebalan tubuh sebelum bayi terpapar penyakit berbahaya seperti tuberkulosis, hepatitis B, difteri, pertusis, tetanus, polio, dan campak.</p>
<h3>Vaksin apa saja yang termasuk?</h3>
<ul>
  <li><strong>HB0</strong> — hepatitis B, diberikan segera setelah lahir.</li>
  <li><strong>BCG</strong> — perlindungan terhadap tuberkulosis (TBC).</li>
  <li><strong>Polio 0–4</strong> — polio tetes maupun suntik (IPV).</li>
  <li><strong>DPT-HB-Hib 1–3</strong> — difteri, pertusis, tetanus, hepatitis B, dan Hib.</li>
  <li><strong>MR</strong> — measles (campak) dan rubella pada usia 9 bulan.</li>
</ul>
<h3>Mengapa tidak boleh ditunda?</h3>
<p>Kekebalan bayi belum terbentuk sempurna. Semakin cepat imunisasi diberikan sesuai usia target, semakin kecil risiko bayi terinfeksi penyakit yang sebenarnya bisa dicegah. Jika jadwal terlewat, vaksinasi umumnya masih dapat dikejar (<em>catch-up</em>) — konsultasikan dengan dokter atau puskesmas.</p>
<p>Catat setiap jadwal di aplikasi ImuniKita agar pengingat H-7 dan H-1 otomatis muncul sebelum hari imunisasi.</p>
''',
    ),
    ArticleModel(
      articleId: 'art-02',
      judul: 'Jadwal Imunisasi IDAI: Panduan Lengkap Orang Tua',
      kategori: EducationKategori.imunisasi,
      penulis: 'Tim ImuniKita',
      ringkasan: 'Dari usia 0 bulan sampai 5 tahun, ini urutan jadwal imunisasi yang dianjurkan Ikatan Dokter Anak Indonesia.',
      tanggalPublish: DateTime(2026, 9, 14),
      estimasiBacaMenit: 6,
      imageUrl: 'https://images.unsplash.com/photo-1632053002928-1919d6ea0b46',
      kontenHtml: '''
<h3>Urutan jadwal per usia</h3>
<ul>
  <li><strong>0 bulan</strong> — HB0, Polio 0.</li>
  <li><strong>1 bulan</strong> — BCG, Polio 1.</li>
  <li><strong>2 bulan</strong> — DPT-HB-Hib 1, Polio 2.</li>
  <li><strong>3 bulan</strong> — DPT-HB-Hib 2, Polio 3.</li>
  <li><strong>4 bulan</strong> — DPT-HB-Hib 3, Polio 4, IPV.</li>
  <li><strong>9 bulan</strong> — MR 1.</li>
  <li><strong>18 bulan</strong> — DPT-HB-Hib 4, MR 2.</li>
</ul>
<h3>Tips agar jadwal tidak terlewat</h3>
<ul>
  <li>Simpan buku KIA dan catat tanggal di aplikasi.</li>
  <li>Aktifkan pengingat notifikasi H-7 dan H-1.</li>
  <li>Jika bayi sedang demam tinggi, tanyakan ke tenaga kesehatan apakah jadwal perlu digeser.</li>
</ul>
<p>Jadwal dapat sedikit berbeda bila bayi lahir prematur atau memiliki kondisi khusus. Selalu ikuti anjuran dokter yang menangani anak Anda.</p>
''',
    ),
    ArticleModel(
      articleId: 'art-03',
      judul: 'Mengatasi Demam Setelah Imunisasi (KIPI)',
      kategori: EducationKategori.imunisasi,
      penulis: 'Tim ImuniKita',
      ringkasan: 'Demam ringan setelah imunisasi umumnya normal. Kenali batas aman dan tanda yang perlu segera diperiksakan.',
      tanggalPublish: DateTime(2026, 9, 16),
      estimasiBacaMenit: 4,
      imageUrl: 'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d',
      kontenHtml: '''
<h3>Apa itu KIPI?</h3>
<p>KIPI adalah Kejadian Ikutan Pasca Imunisasi — reaksi yang muncul setelah vaksinasi. Reaksi ringan seperti demam, nyeri di bekas suntikan, atau bayi lebih rewel adalah tanda tubuh sedang membentuk kekebalan.</p>
<h3>Yang bisa dilakukan di rumah</h3>
<ul>
  <li>Beri ASI atau cairan lebih sering.</li>
  <li>Kompres hangat (bukan air dingin) di bekas suntikan.</li>
  <li>Pastikan bayi cukup istirahat dan tidak kepanasan.</li>
  <li>Catat suhu tubuh dan gejala di jurnal kesehatan aplikasi.</li>
</ul>
<h3>Segera cari bantuan bila</h3>
<ul>
  <li>Suhu tubuh 39°C atau lebih dan tidak turun.</li>
  <li>Bayi sangat lemas, sulit dibangunkan, atau menolak menyusu.</li>
  <li>Muncul kejang, ruam menyeluruh, atau sesak napas.</li>
</ul>
<p>Jangan ragu menghubungi puskesmas atau dokter bila Anda khawatir — petugas kesehatan dapat memastikan kondisi si kecil.</p>
''',
    ),
    ArticleModel(
      articleId: 'art-04',
      judul: 'ASI Eksklusif 6 Bulan: Manfaat dan Tips Sukses',
      kategori: EducationKategori.nutrisi,
      penulis: 'Tim ImuniKita',
      ringkasan: 'ASI eksklusif memberi nutrisi paling lengkap sekaligus memperkuat daya tahan tubuh bayi di masa paling rentan.',
      tanggalPublish: DateTime(2026, 9, 10),
      estimasiBacaMenit: 5,
      imageUrl: 'https://images.unsplash.com/photo-1544126592-807ade215a0b',
      kontenHtml: '''
<h3>Kenapa disebut eksklusif?</h3>
<p>Eksklusif berarti bayi hanya menerima ASI — tanpa air, madu, atau makanan lain — selama 6 bulan pertama, kecuali obat yang diresepkan dokter.</p>
<h3>Manfaat utama</h3>
<ul>
  <li>Mengandung antibodi yang membantu melawan infeksi.</li>
  <li>Menurunkan risiko diare dan pneumonia.</li>
  <li>Mendukung perkembangan otak serta berat badan yang sehat.</li>
  <li>Praktis, steril, dan selalu siap diberikan.</li>
</ul>
<h3>Tips agar produksi ASI lancar</h3>
<ul>
  <li>Menyusui sesering mungkin, minimal 8–12 kali sehari.</li>
  <li>Pastikan pelekatan dan posisi menyusui sudah benar.</li>
  <li>Konsumsi gizi seimbang dan minum cukup air.</li>
  <li>Istirahat cukup serta kelola stres dengan baik.</li>
</ul>
<p>Setelah 6 bulan, ASI tetap diberikan sampai usia 2 tahun sambil diperkenalkan MPASI.</p>
''',
    ),
    ArticleModel(
      articleId: 'art-05',
      judul: 'Tahapan Perkembangan Motorik Bayi 0–12 Bulan',
      kategori: EducationKategori.tumbuhKembang,
      penulis: 'Tim ImuniKita',
      ringkasan: 'Setiap bayi berkembang dengan tempo masing-masing. Ini panduan umum tahapan motorik untuk memantau si kecil.',
      tanggalPublish: DateTime(2026, 9, 18),
      estimasiBacaMenit: 6,
      imageUrl: 'https://images.unsplash.com/photo-1519689680058-324335c77eba',
      kontenHtml: '''
<h3>Motorik kasar vs halus</h3>
<p>Motorik kasar melibatkan otot besar seperti tengkurap dan duduk, sedangkan motorik halus melibatkan jari dan koordinasi mata-tangan.</p>
<h3>Panduan umum per usia</h3>
<ul>
  <li><strong>0–2 bulan</strong> — mengangkat kepala sejenak saat tengkurap, menggenggam jari.</li>
  <li><strong>3–5 bulan</strong> — berguling, meraih dan memasukkan benda ke mulut.</li>
  <li><strong>6–8 bulan</strong> — duduk dengan ditopang atau mandiri, mulai merangkak.</li>
  <li><strong>9–12 bulan</strong> — berdiri berpegangan, menjepit benda dengan telunjuk dan ibu jari.</li>
</ul>
<h3>Yang perlu diperhatikan</h3>
<ul>
  <li>Fokus pada kemajuan anak, bukan perbandingan semata.</li>
  <li>Rutin periksa ke posyandu untuk menimbang dan memantau.</li>
  <li>Konsultasikan bila ada kemampuan yang hilang kembali atau belum tercapai.</li>
</ul>
''',
    ),
    ArticleModel(
      articleId: 'art-06',
      judul: 'MPASI Pertama: Tekstur, Porsi, dan Jadwal',
      kategori: EducationKategori.mpasi,
      penulis: 'Tim ImuniKita',
      ringkasan: 'Memulai MPASI tidak perlu rumit. Pahami tekstur, jumlah, dan waktu pemberian yang tepat untuk bayi 6 bulan.',
      tanggalPublish: DateTime(2026, 9, 19),
      estimasiBacaMenit: 5,
      imageUrl: 'https://images.unsplash.com/photo-1587595431973-160d0d94add1',
      kontenHtml: '''
<h3>Kapan MPASI dimulai?</h3>
<p>Sekitar usia 6 bulan, saat bayi sudah bisa menegakkan kepala, duduk dengan ditopang, dan menunjukkan minat pada makanan.</p>
<h3>Tekstur yang tepat</h3>
<ul>
  <li><strong>6 bulan</strong> — lumat atau disaring halus (puree).</li>
  <li><strong>7–8 bulan</strong> — cincang halus, mulai bisa dipegang bayi.</li>
  <li><strong>9–12 bulan</strong> — cincang kasar dan makanan keluarga yang lunak.</li>
</ul>
<h3>Porsi dan frekuensi</h3>
<ul>
  <li>Mulai dari 2–3 sendok makan, naikkan bertahap sesuai kemampuan bayi.</li>
  <li>Usia 6–8 bulan: 2–3 kali makan utama per hari.</li>
  <li>Usia 9–11 bulan: 3–4 kali makan utama plus 1–2 kali selingan.</li>
</ul>
<p>Berikan makanan dengan gizi lengkap, tambahkan lemak sehat, dan hindari gula serta garam berlebih. ASI tetap dilanjutkan.</p>
''',
    ),
    ArticleModel(
      articleId: 'art-07',
      judul: 'Resep MPASI 4 Bintang untuk Pemula',
      kategori: EducationKategori.mpasi,
      penulis: 'Tim ImuniKita',
      ringkasan: 'Konsep 4 bintang memastikan MPASI memuat karbohidrat, protein hewani, protein nabati, serta sayur dan buah.',
      tanggalPublish: DateTime(2026, 9, 21),
      estimasiBacaMenit: 4,
      imageUrl: 'https://images.unsplash.com/photo-1490474418585-ba9bad8fd0ea',
      kontenHtml: '''
<h3>Empat komponen wajib</h3>
<ul>
  <li><strong>Karbohidrat</strong> — beras, kentang, ubi, atau jagung.</li>
  <li><strong>Protein hewani</strong> — telur, ayam, ikan, daging sapi, atau hati ayam.</li>
  <li><strong>Protein nabati</strong> — tahu, tempe, atau kacang hijau.</li>
  <li><strong>Sayur &amp; buah</strong> — wortel, bayam, brokoli, pisang, atau alpukat.</li>
</ul>
<h3>Contoh menu sederhana</h3>
<p>Bubur beras yang dilumatkan dengan telur ayam matang, tahu, wortel kukus, dan satu sendok minyak kelapa. Sajikan hangat dan dalam porsi kecil.</p>
<h3>Tips memasak aman</h3>
<ul>
  <li>Masak hingga benar-benar matang, terutama protein hewani.</li>
  <li>Hindari gula, garam, dan penyedap tambahan.</li>
  <li>Peralatan makan dicuci bersih dan disimpan tertutup.</li>
</ul>
''',
    ),
    ArticleModel(
      articleId: 'art-08',
      judul: 'Cara Membaca Grafik Pertumbuhan Sesuai Standar WHO',
      kategori: EducationKategori.tumbuhKembang,
      penulis: 'Tim ImuniKita',
      ringkasan: 'Grafik pertumbuhan membantu mendeteksi masalah gizi lebih awal. Ini arti garis median dan batas normalnya.',
      tanggalPublish: DateTime(2026, 9, 22),
      estimasiBacaMenit: 5,
      imageUrl: 'https://images.unsplash.com/photo-1555252333-9f8e92e65df9',
      kontenHtml: '''
<h3>Apa yang diukur?</h3>
<p>Standar WHO memantau berat badan menurut usia, tinggi badan menurut usia, dan lingkar kepala menurut usia, dipisahkan antara anak laki-laki dan perempuan.</p>
<h3>Mengenal garis referensi</h3>
<ul>
  <li><strong>Median (garis 0 SD)</strong> — nilai rata-rata populasi rujukan.</li>
  <li><strong>+2 SD dan -2 SD</strong> — batas atas dan bawah rentang normal.</li>
  <li>Nilai di luar -3 SD atau +3 SD perlu evaluasi tenaga kesehatan.</li>
</ul>
<h3>Cara menyimpulkan dengan benar</h3>
<p>Yang paling penting bukan posisi satu titik, melainkan <em>tren</em> dari waktu ke waktu. Berat badan yang turun atau tidak naik dua bulan berturut-turut perlu ditindaklanjuti.</p>
<p>Catat pengukuran rutin di menu Tumbuh Kembang aplikasi ImuniKita agar tren si kecil mudah dilihat.</p>
''',
    ),
  ];

  static final List<VideoModel> _video = [
    VideoModel(
      videoId: 'vid-01',
      judul: 'Cara Menenangkan Bayi Setelah Suntik Imunisasi',
      kategori: EducationKategori.imunisasi,
      deskripsi: 'Teknik menggendong dan menyusui untuk meredakan tangis bayi.',
      durasiDetik: 275,
      thumbnailUrl: 'https://images.unsplash.com/photo-1544126592-807ade215a0b',
    ),
    VideoModel(
      videoId: 'vid-02',
      judul: 'Mengenal Jenis Vaksin dan Manfaatnya',
      kategori: EducationKategori.imunisasi,
      deskripsi: 'Perbedaan vaksin hidup, mati, dan rekombinan dalam bahasa sederhana.',
      durasiDetik: 372,
      thumbnailUrl:
          'https://images.unsplash.com/photo-1632053002928-1919d6ea0b46',
    ),
    VideoModel(
      videoId: 'vid-03',
      judul: 'Menyusui yang Benar: Posisi dan Pelekatan',
      kategori: EducationKategori.nutrisi,
      deskripsi: 'Langkah memastikan pelekatan benar agar ASI keluar optimal.',
      durasiDetik: 348,
      thumbnailUrl: 'https://images.unsplash.com/photo-1555252333-9f8e92e65df9',
    ),
    VideoModel(
      videoId: 'vid-04',
      judul: 'Stimulasi Tumbuh Kembang Bayi di Rumah',
      kategori: EducationKategori.tumbuhKembang,
      deskripsi: 'Permainan sederhana untuk melatih motorik kasar dan halus.',
      durasiDetik: 425,
      thumbnailUrl:
          'https://images.unsplash.com/photo-1519689680058-324335c77eba',
    ),
    VideoModel(
      videoId: 'vid-05',
      judul: 'Langkah Pertama Membuat MPASI',
      kategori: EducationKategori.mpasi,
      deskripsi: 'Persiapan alat, bahan, dan cara memasak MPASI pertama.',
      durasiDetik: 400,
      thumbnailUrl:
          'https://images.unsplash.com/photo-1587595431973-160d0d94add1',
    ),
    VideoModel(
      videoId: 'vid-06',
      judul: 'Cara Menimbang dan Mengukur Bayi di Rumah',
      kategori: EducationKategori.tumbuhKembang,
      deskripsi: 'Agar hasil pengukuran mandiri tetap akurat dan konsisten.',
      durasiDetik: 232,
      thumbnailUrl:
          'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d',
    ),
  ];

  static const List<QuizModel> _kuis = [
    QuizModel(
      quizId: 'quiz-01',
      judul: 'Dasar Imunisasi Bayi',
      deskripsi: 'Uji pemahaman Anda tentang vaksin wajib dan jadwalnya.',
      kategori: EducationKategori.imunisasi,
      soal: [
        QuizQuestion(
          pertanyaan: 'Vaksin HB0 sebaiknya diberikan kapan?',
          pilihan: [
            'Segera setelah lahir, idealnya dalam 24 jam',
            'Saat bayi berusia 1 bulan',
            'Bersamaan dengan vaksin MR',
            'Setelah bayi berusia 9 bulan',
          ],
          indexJawabanBenar: 0,
          penjelasan: 'HB0 melindungi bayi dari hepatitis B dan paling efektif bila diberikan sesegera mungkin setelah lahir, idealnya dalam 24 jam pertama.',
        ),
        QuizQuestion(
          pertanyaan: 'Vaksin BCG berfungsi melindungi bayi dari penyakit apa?',
          pilihan: ['Tuberkulosis (TBC)', 'Campak', 'Hepatitis B', 'Polio'],
          indexJawabanBenar: 0,
          penjelasan: 'BCG adalah vaksin untuk mencegah tuberkulosis, terutama bentuk berat seperti meningitis TB pada anak.',
        ),
        QuizQuestion(
          pertanyaan: 'Bayi demam ringan setelah imunisasi. Apa yang sebaiknya dilakukan?',
          pilihan: [
            'Berikan ASI lebih sering dan kompres hangat',
            'Hentikan seluruh jadwal imunisasi berikutnya',
            'Beri antibiotik tanpa resep dokter',
            'Mandikan bayi dengan air dingin',
          ],
          indexJawabanBenar: 0,
          penjelasan: 'Demam ringan adalah reaksi normal. Cukup ASI yang cukup, kompres hangat, dan pantau suhu. Hubungi tenaga kesehatan bila demam tinggi atau bayi sangat lemas.',
        ),
        QuizQuestion(
          pertanyaan: 'Vaksin MR (Measles-Rubella) diberikan pada usia berapa?',
          pilihan: ['9 bulan', '2 bulan', '4 bulan', '24 bulan'],
          indexJawabanBenar: 0,
          penjelasan: 'Dosis pertama MR diberikan pada usia 9 bulan, lalu dosis kedua saat usia 18 bulan sesuai jadwal nasional.',
        ),
        QuizQuestion(
          pertanyaan: 'Berapa lama umumnya demam akibat imunisasi berlangsung?',
          pilihan: [
            '1–2 hari',
            'Sekitar 2 minggu',
            'Sekitar 1 bulan',
            'Tidak pernah berhenti',
          ],
          indexJawabanBenar: 0,
          penjelasan: 'KIPI ringan seperti demam biasanya mereda dalam 1–2 hari. Bila lebih lama atau makin berat, segera periksakan ke fasilitas kesehatan.',
        ),
      ],
    ),
    QuizModel(
      quizId: 'quiz-02',
      judul: 'Nutrisi & MPASI',
      deskripsi: 'Pahami pemberian ASI dan makanan pendamping pertama.',
      kategori: EducationKategori.nutrisi,
      soal: [
        QuizQuestion(
          pertanyaan:
              'ASI eksklusif dianjurkan diberikan sampai bayi berusia...',
          pilihan: ['6 bulan', '2 bulan', '1 tahun', '2 tahun tanpa MPASI'],
          indexJawabanBenar: 0,
          penjelasan: 'ASI eksklusif diberikan hingga usia 6 bulan, lalu dilanjutkan bersama MPASI sampai usia 2 tahun atau lebih.',
        ),
        QuizQuestion(
          pertanyaan: 'MPASI pertama sebaiknya bertekstur seperti apa?',
          pilihan: [
            'Lumat atau disaring halus',
            'Kasar dan berkuah',
            'Padat seperti makanan orang dewasa',
            'Cair encer seperti air',
          ],
          indexJawabanBenar: 0,
          penjelasan: 'Bayi 6 bulan belum mampu mengunyah, jadi MPASI awal harus lumat halus lalu ditingkatkan bertahap sesuai usia.',
        ),
        QuizQuestion(
          pertanyaan: 'Berapa frekuensi makan MPASI yang dianjurkan untuk bayi 6–8 bulan?',
          pilihan: [
            '2–3 kali makan utama per hari',
            '1 kali per hari',
            '5 kali makan berat per hari',
            '3 kali makan + 3 selingan manis',
          ],
          indexJawabanBenar: 0,
          penjelasan: 'Bayi 6–8 bulan dianjurkan makan 2–3 kali makanan utama per hari dan dapat ditambah 1–2 selingan bergizi.',
        ),
        QuizQuestion(
          pertanyaan: 'Apa saja komponen MPASI "4 bintang"?',
          pilihan: [
            'Karbohidrat, protein hewani, protein nabati, sayur dan buah',
            'Susu, biskuit, madu, dan air gula',
            'Nasi, bubur instan, gula, dan garam',
            'Buah, jus, agar-agar, dan krimer',
          ],
          indexJawabanBenar: 0,
          penjelasan: 'Konsep 4 bintang memastikan MPASI kaya energi dan gizi lengkap: karbohidrat, protein hewani, protein nabati, serta sayur dan buah.',
        ),
        QuizQuestion(
          pertanyaan: 'Makanan/minuman apa yang harus dihindari saat MPASI?',
          pilihan: [
            'Gula, garam, dan madu berlebih',
            'Telur ayam matang',
            'Wortel kukus',
            'Tempe yang dilumatkan',
          ],
          indexJawabanBenar: 0,
          penjelasan: 'Hindari tambahan gula, garam, dan penyedap pada MPASI serta madu sebelum usia 1 tahun karena berisiko bagi bayi.',
        ),
      ],
    ),
    QuizModel(
      quizId: 'quiz-03',
      judul: 'Tumbuh Kembang Bayi',
      deskripsi: 'Kenali tahapan perkembangan dan cara memantau pertumbuhan.',
      kategori: EducationKategori.tumbuhKembang,
      soal: [
        QuizQuestion(
          pertanyaan: 'Kemampuan mengangkat kepala saat tengkurap umumnya muncul pada usia...',
          pilihan: ['2–3 bulan', '6–8 bulan', '9 bulan', '12 bulan'],
          indexJawabanBenar: 0,
          penjelasan: 'Pada usia 2–3 bulan bayi mulai mampu mengangkat kepala sejenak saat tengkurap, lalu semakin kuat seiring waktu.',
        ),
        QuizQuestion(
          pertanyaan: 'Bayi umumnya mulai bisa duduk mandiri pada usia...',
          pilihan: ['6–8 bulan', '1–2 bulan', '3–4 bulan', '18 bulan'],
          indexJawabanBenar: 0,
          penjelasan: 'Duduk mandiri biasanya tercapai pada usia 6–8 bulan setelah otot punggung dan leher cukup kuat.',
        ),
        QuizQuestion(
          pertanyaan: 'Standar WHO memantau pertumbuhan anak berdasarkan...',
          pilihan: [
            'Berat, tinggi, dan lingkar kepala menurut usia dan jenis kelamin',
            'Warna kulit dan rambut',
            'Jumlah gigi yang tumbuh',
            'Panjang jari tangan',
          ],
          indexJawabanBenar: 0,
          penjelasan: 'Grafik WHO membandingkan ukuran anak dengan populasi rujukan, dipisahkan menurut usia dan jenis kelamin.',
        ),
        QuizQuestion(
          pertanyaan:
              'Kondisi pertumbuhan apa yang perlu segera ditindaklanjuti?',
          pilihan: [
            'Berat badan turun atau tidak naik 2 bulan berturut-turut',
            'Berat badan naik setiap bulan',
            'Lingkar kepala bertambah perlahan',
            'Anak aktif bergerak',
          ],
          indexJawabanBenar: 0,
          penjelasan: 'Tren berat badan yang stagnan atau menurun dua bulan berturut-turut dapat menandakan masalah gizi dan perlu evaluasi tenaga kesehatan.',
        ),
        QuizQuestion(
          pertanyaan:
              'Stimulasi yang tepat untuk bayi usia 0–3 bulan adalah...',
          pilihan: [
            'Sering mengajak bicara dan melakukan kontak mata',
            'Melatih berdiri dengan berpegangan',
            'Memberi mainan kecil yang bisa ditelan',
            'Menonton video tanpa pendampingan',
          ],
          indexJawabanBenar: 0,
          penjelasan: 'Pada usia 0–3 bulan, interaksi sosial seperti berbicara, tersenyum, dan kontak mata adalah stimulasi paling bermanfaat.',
        ),
      ],
    ),
  ];
}
