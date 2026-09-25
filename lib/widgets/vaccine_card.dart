import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app/theme/app_colors.dart';
import '../core/utils/date_formatter.dart';
import '../features/immunization/domain/entities/vaccine_schedule_entity.dart';

/// Kartu ringkasan satu jadwal imunisasi (komponen UI global).
///
/// Dipakai di Dashboard ("jadwal terdekat"), Kalender, dan Timeline agar nama,
/// tanggal target, usia sasaran, tanggal realisasi, serta deskripsi selalu
/// tampil dengan susunan yang sama. Bagian yang khas per layar (ikon pemicu,
/// badge countdown/status, tombol) disuntikkan lewat [leading], [trailing],
/// dan [footer].
class VaccineCard extends StatelessWidget {
  const VaccineCard({
    super.key,
    required this.schedule,
    this.onTap,
    this.margin,
    this.backgroundColor,
    this.leading,
    this.trailing,
    this.footer,
    this.showDescription = true,
    this.showMeta = true,
    this.compact = false,
  });

  final VaccineScheduleEntity schedule;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;

  /// Widget di kiri judul, mis. ikon vaksin atau titik timeline.
  final Widget? leading;

  /// Widget di kanan judul, mis. badge status atau countdown.
  final Widget? trailing;

  /// Baris tambahan di bawah deskripsi, mis. tautan "Lihat Detail".
  final Widget? footer;

  final bool showDescription;

  /// Tampilkan baris tanggal target + usia sasaran.
  final bool showMeta;

  /// Ukuran lebih rapat untuk dipakai di dalam daftar panjang.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final metaStyle = GoogleFonts.poppins(
      fontSize: 12,
      color: AppColors.textSecondary,
    );

    final content = Padding(
      padding: EdgeInsets.all(compact ? 12 : 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 12)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        schedule.namaVaksin,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: compact ? 14 : 15,
                          color: AppColors.darkText,
                        ),
                      ),
                    ),
                    if (trailing != null) ...[
                      const SizedBox(width: 8),
                      trailing!,
                    ],
                  ],
                ),
                if (showMeta) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6,
                    runSpacing: 2,
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 12,
                        color: AppColors.textSecondary,
                      ),
                      Text(
                        DateFormatter.formatLong(schedule.tanggalTarget),
                        style: metaStyle,
                      ),
                      Text(
                        '•  ${schedule.usiaBulanTarget} Bulan',
                        style: metaStyle,
                      ),
                    ],
                  ),
                ],
                if (schedule.status == VaccineStatus.selesai &&
                    schedule.tanggalRealisasi != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Diberikan: '
                    '${DateFormatter.formatLong(schedule.tanggalRealisasi!)}',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                if (showDescription && schedule.deskripsi.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    schedule.deskripsi,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
                if (footer != null) ...[const SizedBox(height: 10), footer!],
              ],
            ),
          ),
        ],
      ),
    );

    return Card(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 4),
      color: backgroundColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: onTap == null
          ? content
          : InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onTap,
              child: content,
            ),
    );
  }
}
