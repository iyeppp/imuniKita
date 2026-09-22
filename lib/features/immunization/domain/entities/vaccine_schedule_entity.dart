/// Nilai valid untuk `VaccineScheduleEntity.status`.
abstract class VaccineStatus {
  static const String belum = 'BELUM';
  static const String selesai = 'SELESAI';
  static const String terlewat = 'TERLEWAT';
}

/// Entity domain — satu baris jadwal imunisasi milik seorang bayi.
///
/// Dibuat otomatis oleh `GenerateScheduleUseCase` saat bayi didaftarkan,
/// lalu diperbarui `MarkVaccineDoneUseCase` (Sprint 2) saat status berubah.
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
  });

  final String scheduleId;
  final String babyId;
  final String namaVaksin;
  final String deskripsi;

  /// Usia target pemberian dalam bulan (0, 1, 2, ... dari `VaccineMaster`).
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

  VaccineScheduleEntity copyWith({
    String? status,
    DateTime? tanggalRealisasi,
    String? catatanReaksi,
    bool? reminderH7Sent,
    bool? reminderH1Sent,
  }) {
    return VaccineScheduleEntity(
      scheduleId: scheduleId,
      babyId: babyId,
      namaVaksin: namaVaksin,
      deskripsi: deskripsi,
      usiaBulanTarget: usiaBulanTarget,
      tanggalTarget: tanggalTarget,
      status: status ?? this.status,
      tanggalRealisasi: tanggalRealisasi ?? this.tanggalRealisasi,
      catatanReaksi: catatanReaksi ?? this.catatanReaksi,
      reminderH7Sent: reminderH7Sent ?? this.reminderH7Sent,
      reminderH1Sent: reminderH1Sent ?? this.reminderH1Sent,
    );
  }
}
