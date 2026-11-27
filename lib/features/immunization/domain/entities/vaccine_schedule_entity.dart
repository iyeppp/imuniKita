/// Nilai valid untuk `VaccineScheduleEntity.status`.
abstract class VaccineStatus {
  static const String belum = 'BELUM';
  static const String selesai = 'SELESAI';
  static const String terlewat = 'TERLEWAT';

  /// Status **efektif** pada tanggal [now] (default: hari ini).
  static String effective({
    required String status,
    required DateTime tanggalTarget,
    DateTime? now,
  }) {
    if (status != belum) return status;

    final today = _dateOnly(now ?? DateTime.now());
    return _dateOnly(tanggalTarget).isBefore(today) ? terlewat : belum;
  }

  /// `true` bila jadwal sudah terlewat pada tanggal [now].
  static bool isOverdue({
    required String status,
    required DateTime tanggalTarget,
    DateTime? now,
  }) =>
      effective(status: status, tanggalTarget: tanggalTarget, now: now) ==
      terlewat;

  /// Bandingkan tanggal saja (tanpa jam) agar hasil konsisten di hari yang sama.
  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}

/// Entity domain — satu baris jadwal imunisasi milik seorang bayi.
class VaccineScheduleEntity {
  const VaccineScheduleEntity({
    required this.scheduleId,
    required this.babyId,
    required this.namaVaksin,
    required this.deskripsi,
    required this.usiaBulanTarget,
    required this.tanggalTarget,
    this.status = VaccineStatus.belum,
    this.tanggalRealisasi,
    this.catatanReaksi,
    this.reminderH7Sent = false,
    this.reminderH1Sent = false,
    this.updatedAt,
  });

  final String scheduleId;
  final String babyId;
  final String namaVaksin;
  final String deskripsi;

  /// Usia target pemberian dalam bulan (0, 1, 2,...
  final int usiaBulanTarget;
  final DateTime tanggalTarget;

  /// `VaccineStatus.belum` | `.selesai` | `.terlewat`.
  final String status;
  final DateTime? tanggalRealisasi;

  /// Catatan KIPI (Kejadian Ikutan Pasca Imunisasi) bila ada.
  final String? catatanReaksi;

  /// Penanda agar notifikasi H-7/H-1 tidak dijadwalkan berulang.
  final bool reminderH7Sent;
  final bool reminderH1Sent;

  final DateTime? updatedAt;

  VaccineScheduleEntity copyWith({
    String? status,
    DateTime? tanggalRealisasi,
    String? catatanReaksi,
    bool? reminderH7Sent,
    bool? reminderH1Sent,
    DateTime? updatedAt,
    // Field nullable perlu flag eksplisit agar bisa dikosongkan (`??
    bool clearTanggalRealisasi = false,
    bool clearCatatanReaksi = false,
  }) {
    return VaccineScheduleEntity(
      scheduleId: scheduleId,
      babyId: babyId,
      namaVaksin: namaVaksin,
      deskripsi: deskripsi,
      usiaBulanTarget: usiaBulanTarget,
      tanggalTarget: tanggalTarget,
      status: status ?? this.status,
      tanggalRealisasi: clearTanggalRealisasi
          ? null
          : (tanggalRealisasi ?? this.tanggalRealisasi),
      catatanReaksi: clearCatatanReaksi
          ? null
          : (catatanReaksi ?? this.catatanReaksi),
      reminderH7Sent: reminderH7Sent ?? this.reminderH7Sent,
      reminderH1Sent: reminderH1Sent ?? this.reminderH1Sent,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
