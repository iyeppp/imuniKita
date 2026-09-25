/// Entity domain — satu catatan jurnal kesehatan bayi.
///
/// Bebas dari Hive CE (`HealthJournalModel` hanya dipakai di lapisan data).
class HealthJournalEntity {
  const HealthJournalEntity({
    required this.journalId,
    required this.babyId,
    this.vaccineScheduleId,
    required this.tanggalCatatan,
    required this.isiCatatan,
    this.suhuTubuh,
    this.gejala = const [],
  });

  final String journalId;
  final String babyId;

  /// Jadwal imunisasi terkait (bila catatan dibuat pasca vaksinasi).
  final String? vaccineScheduleId;
  final DateTime tanggalCatatan;
  final String isiCatatan;

  /// Suhu tubuh (°C) — opsional.
  final double? suhuTubuh;

  /// Daftar gejala yang timbul.
  final List<String> gejala;

  HealthJournalEntity copyWith({
    DateTime? tanggalCatatan,
    String? isiCatatan,
    double? suhuTubuh,
    List<String>? gejala,
  }) {
    return HealthJournalEntity(
      journalId: journalId,
      babyId: babyId,
      vaccineScheduleId: vaccineScheduleId,
      tanggalCatatan: tanggalCatatan ?? this.tanggalCatatan,
      isiCatatan: isiCatatan ?? this.isiCatatan,
      suhuTubuh: suhuTubuh ?? this.suhuTubuh,
      gejala: gejala ?? this.gejala,
    );
  }
}
