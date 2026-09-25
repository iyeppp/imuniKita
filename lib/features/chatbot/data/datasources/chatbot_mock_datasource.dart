import 'dart:math';

/// Datasource berbasis rule/keyword — tidak ada koneksi AI/backend.
/// Mendukung 30+ keyword mencakup vaksin nasional dan topik parenting umum.
class ChatbotMockDatasource {
  static const String _defaultResponse =
      'Maaf, saya belum bisa menjawab itu secara detail. '
      'Silakan konsultasikan dengan dokter anak atau bidan terdekat. '
      'Anda bisa mencari faskes terdekat di menu Direktori Faskes. 🏥';

  /// Peta keyword → respons. Matching case-insensitive, urutan atas diprioritaskan.
  static const List<(List<String>, String)> _rules = [
    // ── Vaksin BCG ────────────────────────────────────────────────────────
    (
      ['bcg', 'tuberkulosis', 'tbc', 'tb'],
      'Vaksin BCG melindungi bayi dari tuberkulosis (TBC) yang berat, '
          'seperti meningitis TB dan TB milier. '
          'Diberikan satu kali segera setelah lahir atau sebelum bayi berusia 1 bulan. '
          'Bekas suntik berupa benjolan kecil di lengan kanan atas adalah hal yang normal. 💉',
    ),

    // ── Hepatitis B ───────────────────────────────────────────────────────
    (
      ['hepatitis b', 'hep b', 'hbv', 'hepatitis-b'],
      'Vaksin Hepatitis B diberikan 3 kali: segera setelah lahir (< 24 jam), '
          'usia 2 bulan, dan 3 bulan (dalam kombinasi DPT-HB-Hib). '
          'Vaksin ini melindungi hati anak dari infeksi virus hepatitis B seumur hidup. 🛡️',
    ),

    // ── Hepatitis A ───────────────────────────────────────────────────────
    (
      ['hepatitis a', 'hep a', 'hav', 'hepatitis-a'],
      'Vaksin Hepatitis A diberikan mulai usia 2 tahun sebanyak 2 dosis '
          'dengan jarak 6–12 bulan. '
          'Melindungi dari penyakit kuning yang disebabkan virus hepatitis A. 🟡',
    ),

    // ── Polio ─────────────────────────────────────────────────────────────
    (
      ['polio', 'opv', 'ipv', 'lumpuh layu'],
      'Vaksin Polio terdiri dari tetes mulut (OPV) dan suntik (IPV). '
          'Diberikan pada usia 1, 2, 3, 4 bulan, dan 18 bulan. '
          'Polio dapat menyebabkan kelumpuhan permanen, sehingga vaksinasi sangat penting. 🦵',
    ),

    // ── DPT ───────────────────────────────────────────────────────────────
    (
      ['dpt', 'dtp', 'difteri', 'pertusis', 'batuk rejan', 'tetanus'],
      'Vaksin DPT melindungi dari difteri, pertusis (batuk rejan), dan tetanus. '
          'Diberikan pada usia 2, 3, 4 bulan, lalu booster pada 18 bulan dan 5 tahun. '
          'Setelah suntik DPT, demam ringan adalah respons imun yang normal. 🌡️',
    ),

    // ── Hib ───────────────────────────────────────────────────────────────
    (
      ['hib', 'haemophilus', 'meningitis bakteri'],
      'Vaksin Hib melindungi dari bakteri Haemophilus influenzae tipe b '
          'yang dapat menyebabkan meningitis, pneumonia, dan epiglotitis. '
          'Biasanya diberikan bersamaan dengan DPT pada usia 2, 3, dan 4 bulan. 🧬',
    ),

    // ── PCV ───────────────────────────────────────────────────────────────
    (
      ['pcv', 'pneumokokus', 'pneumococcal', 'streptococcus pneumoniae'],
      'Vaksin PCV melindungi dari bakteri Streptococcus pneumoniae penyebab '
          'pneumonia, meningitis, dan infeksi telinga berat. '
          'Diberikan pada usia 2, 3, 4 bulan dan booster 12 bulan. 🫁',
    ),

    // ── Rotavirus ─────────────────────────────────────────────────────────
    (
      ['rotavirus', 'diare berat', 'rotarix', 'rotateq'],
      'Vaksin Rotavirus mencegah diare berat akibat rotavirus yang bisa '
          'menyebabkan dehidrasi serius pada bayi. '
          'Diberikan lewat tetes mulut pada usia 2 dan 4 bulan (2 dosis). 💧',
    ),

    // ── MR / MMR / Campak / Rubela ────────────────────────────────────────
    (
      [
        'mr',
        'mmr',
        'campak',
        'measles',
        'rubela',
        'rubella',
        'gondongan',
        'mumps',
      ],
      'Vaksin MR (Measles-Rubella) melindungi dari campak dan rubela. '
          'Diberikan pada usia 9 bulan dan 18 bulan. '
          'Vaksin MMR (tambah perlindungan gondongan) dapat diberikan mulai usia 12 bulan. 🔴',
    ),

    // ── Japanese Encephalitis ─────────────────────────────────────────────
    (
      ['je', 'japanese encephalitis', 'ensefalitis jepang', 'radang otak'],
      'Vaksin Japanese Encephalitis (JE) melindungi dari radang otak yang '
          'ditularkan melalui gigitan nyamuk. '
          'Direkomendasikan untuk anak ≥ 9 bulan, terutama di daerah endemis seperti Bali. 🧠',
    ),

    // ── Varisela / Cacar Air ──────────────────────────────────────────────
    (
      ['varisela', 'varicella', 'cacar air', 'chickenpox'],
      'Vaksin Varisela melindungi dari cacar air yang sangat mudah menular. '
          'Diberikan 1 dosis pada usia 12–18 bulan, dan booster pada usia 6 tahun. '
          'Anak yang sudah divaksin mengalami gejala jauh lebih ringan jika tertular. 🌸',
    ),

    // ── HPV ───────────────────────────────────────────────────────────────
    (
      ['hpv', 'human papillomavirus', 'kanker serviks', 'kanker leher rahim'],
      'Vaksin HPV melindungi dari Human Papillomavirus penyebab kanker serviks. '
          'Program nasional diberikan untuk anak perempuan kelas 5 dan 6 SD (2 dosis). '
          'Vaksin lebih efektif bila diberikan sebelum aktif secara seksual. 🎗️',
    ),

    // ── Tifoid ────────────────────────────────────────────────────────────
    (
      ['tifoid', 'tifus', 'typhoid', 'demam tifoid', 'salmonella'],
      'Vaksin Tifoid melindungi dari demam tifoid (tifus) akibat Salmonella typhi. '
          'Diberikan mulai usia 2 tahun dan diulang setiap 3 tahun. '
          'Tetap jaga kebersihan makanan dan minuman sebagai perlindungan tambahan. 🦠',
    ),

    // ── Jadwal Imunisasi ──────────────────────────────────────────────────
    (
      ['jadwal', 'kapan', 'umur berapa', 'usia berapa', 'schedule'],
      'Jadwal imunisasi nasional dimulai sejak lahir (HB0 dan BCG), '
          'dilanjutkan usia 1, 2, 3, 4, 6, 9, 12, 18 bulan, hingga 5–6 tahun. '
          'Anda bisa melihat jadwal lengkap dan pengingat di menu Imunisasi di aplikasi ini. 📅',
    ),

    // ── Efek Samping / KIPI ───────────────────────────────────────────────
    (
      [
        'efek samping',
        'kipi',
        'kejadian ikutan',
        'reaksi vaksin',
        'merah bengkak',
      ],
      'Efek samping umum setelah vaksinasi (KIPI) meliputi demam ringan, '
          'kemerahan, dan bengkak di area suntikan — biasanya hilang dalam 1–3 hari. '
          'Segera hubungi dokter bila anak kejang, menangis terus > 3 jam, atau demam > 39°C. 🚨',
    ),

    // ── Demam setelah vaksin ──────────────────────────────────────────────
    (
      ['demam', 'panas', 'fever'],
      'Demam ringan (37,5–38,5°C) setelah vaksin adalah respons normal sistem imun. '
          'Kompres hangat, pastikan anak cukup minum, dan beri paracetamol sesuai dosis. '
          'Bila demam melebihi 38,5°C atau lebih dari 3 hari, segera konsultasikan ke dokter. 🌡️',
    ),

    // ── ASI ───────────────────────────────────────────────────────────────
    (
      ['asi', 'air susu ibu', 'menyusui', 'breast milk', 'breastfeeding'],
      'ASI eksklusif dianjurkan sampai usia 6 bulan dan dilanjutkan hingga 2 tahun. '
          'Imunisasi TETAP diberikan meski anak masih menyusui — ASI dan vaksin '
          'bekerja bersama melindungi bayi. Tidak ada vaksin yang dikontraindikasikan dengan menyusui. 🤱',
    ),

    // ── Berat Badan ───────────────────────────────────────────────────────
    (
      ['berat badan', 'bb', 'berat', 'weight', 'timbang'],
      'Berat badan ideal bayi baru lahir sekitar 2,5–4 kg, '
          'dan bertambah ±500–700 g per bulan di 6 bulan pertama. '
          'Pantau pertumbuhan anak secara rutin di Posyandu atau puskesmas, '
          'dan catat di Buku KIA. 📊',
    ),

    // ── Tinggi Badan ──────────────────────────────────────────────────────
    (
      ['tinggi badan', 'panjang badan', 'tb', 'height', 'panjang'],
      'Panjang badan bayi baru lahir rata-rata 48–52 cm dan bertambah ±2–3 cm per bulan '
          'di tahun pertama. '
          'Pengukuran rutin penting untuk mendeteksi masalah pertumbuhan sejak dini. 📏',
    ),

    // ── Stunting ──────────────────────────────────────────────────────────
    (
      ['stunting', 'pendek', 'gizi buruk', 'malnutrisi', 'kurang gizi'],
      'Stunting adalah kondisi tinggi badan anak yang jauh di bawah standar akibat '
          'kekurangan gizi kronis. '
          'Pencegahan terbaik: ASI eksklusif, MPASI bergizi, imunisasi lengkap, '
          'dan pemantauan tumbuh kembang rutin. 🥦',
    ),

    // ── Vitamin ───────────────────────────────────────────────────────────
    (
      ['vitamin', 'suplemen', 'vitamin a', 'vitamin d', 'zat besi', 'zinc'],
      'Vitamin A diberikan gratis tiap Februari dan Agustus di Posyandu '
          '(kapsul biru untuk 6–11 bulan, kapsul merah untuk 12–59 bulan). '
          'Vitamin D penting untuk pembentukan tulang — tanyakan dosis ke dokter anak. ☀️',
    ),

    // ── Posyandu ──────────────────────────────────────────────────────────
    (
      ['posyandu', 'pos pelayanan', 'penimbangan rutin'],
      'Posyandu adalah layanan kesehatan dasar masyarakat yang biasanya diadakan '
          'sebulan sekali. '
          'Di sana anak ditimbang, diukur, mendapat imunisasi, vitamin A, '
          'dan orang tua mendapat penyuluhan kesehatan. 🏥',
    ),

    // ── Dokter / Bidan / Faskes ───────────────────────────────────────────
    (
      ['dokter', 'bidan', 'dokter anak', 'spesialis anak', 'dsA'],
      'Kunjungi dokter anak minimal setiap bulan di tahun pertama kehidupan bayi '
          'untuk pemantauan tumbuh kembang dan imunisasi. '
          'Gunakan menu Direktori Faskes di aplikasi ini untuk menemukan dokter anak '
          'atau puskesmas terdekat. 🩺',
    ),
    (
      ['faskes', 'puskesmas', 'klinik', 'rumah sakit', 'rs', 'fasilitas'],
      'Untuk mencari fasilitas kesehatan (faskes) terdekat, '
          'gunakan menu Direktori Faskes di aplikasi ImuniKita. '
          'Anda bisa filter berdasarkan jenis layanan (imunisasi, KIA, umum). 🗺️',
    ),

    // ── MPASI ─────────────────────────────────────────────────────────────
    (
      [
        'mpasi',
        'makanan pendamping',
        'makan pertama',
        'bubur',
        'puree',
        'solid food',
      ],
      'MPASI (Makanan Pendamping ASI) dimulai pada usia 6 bulan, '
          'saat ASI saja tidak lagi mencukupi kebutuhan gizi. '
          'Mulai dari tekstur lunak (puree), kaya protein hewani, '
          'dan hindari gula/garam tambahan hingga usia 1 tahun. 🥣',
    ),

    // ── Tumbuh Kembang ────────────────────────────────────────────────────
    (
      [
        'tumbuh kembang',
        'milestone',
        'perkembangan',
        'motorik',
        'bicara',
        'duduk',
        'berdiri',
      ],
      'Milestone tumbuh kembang bayi meliputi: tersenyum (2 bulan), '
          'tengkurap (4 bulan), duduk (6 bulan), merangkak (9 bulan), '
          'berjalan (12 bulan). '
          'Keterlambatan signifikan perlu dikonsultasikan ke dokter tumbuh kembang. 👶',
    ),

    // ── Imunisasi booster / ulangan ──────────────────────────────────────
    (
      ['booster', 'ulangan', 'penguat', 'dosis kedua', 'lanjutan'],
      'Vaksin booster (penguat) diberikan setelah seri primer selesai '
          'untuk mempertahankan kekebalan jangka panjang. '
          'Contoh: DPT booster pada 18 bulan dan 5 tahun, Polio booster 18 bulan. '
          'Cek jadwal lengkap di menu Imunisasi. 🔁',
    ),

    // ── Apa itu vaksin / imunisasi ────────────────────────────────────────
    (
      [
        'apa itu vaksin',
        'apa itu imunisasi',
        'vaksin itu apa',
        'imunisasi itu apa',
        'imunisasi',
      ],
      'Imunisasi adalah pemberian vaksin untuk membangun kekebalan tubuh '
          'terhadap penyakit berbahaya tanpa harus terlebih dahulu sakit. '
          'WHO dan Kemenkes RI merekomendasikan imunisasi lengkap sejak bayi '
          'sebagai cara paling efektif mencegah penyakit menular. 💪',
    ),

    // ── Vaksin aman / halal ───────────────────────────────────────────────
    (
      ['aman', 'halal', 'efektivitas', 'manjur', 'terbukti'],
      'Semua vaksin yang ada dalam program imunisasi nasional telah melalui '
          'uji klinis ketat dan mendapat izin dari BPOM. '
          'MUI juga telah mengeluarkan fatwa bahwa vaksin yang diperlukan '
          'diperbolehkan meski mengandung komponen tertentu (darurat medis). ✅',
    ),

    // ── Harga / gratis ────────────────────────────────────────────────────
    (
      ['gratis', 'biaya', 'harga vaksin', 'bayar', 'program nasional'],
      'Semua vaksin dalam Program Imunisasi Nasional (PIN) tersedia GRATIS '
          'di Posyandu, Puskesmas, dan Rumah Sakit Pemerintah. '
          'Vaksin tambahan seperti Varisela, Rotavirus, dan HPV juga gratis '
          'untuk sasaran yang ditentukan pemerintah. 🎉',
    ),

    // ── Alergi / kontraindikasi ───────────────────────────────────────────
    (
      ['alergi', 'kontraindikasi', 'tidak boleh vaksin', 'sedang sakit'],
      'Anak yang sedang demam tinggi (> 38,5°C) atau sakit berat '
          'sebaiknya menunda vaksinasi hingga kondisi membaik. '
          'Alergi berat terhadap komponen vaksin adalah kontraindikasi — '
          'konsultasikan kondisi anak ke dokter sebelum imunisasi. ⚠️',
    ),
  ];

  final Random _random = Random();

  /// Kembalikan respons berbasis keyword untuk [userMessage].
  /// Mensimulasikan delay jaringan 300–700 ms.
  Future<String> getResponse(String userMessage) async {
    final delayMs = 300 + _random.nextInt(401); // 300–700 ms
    await Future.delayed(Duration(milliseconds: delayMs));

    final lower = userMessage.toLowerCase();

    for (final (keywords, response) in _rules) {
      for (final kw in keywords) {
        if (lower.contains(kw)) {
          return response;
        }
      }
    }

    return _defaultResponse;
  }
}
