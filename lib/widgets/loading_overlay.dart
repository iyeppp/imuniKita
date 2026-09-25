import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app/theme/app_colors.dart';

/// Indikator loading inline yang terpusat (komponen UI global).
///
/// Dipakai sebagai isi `AsyncValue.when(loading: ...)` agar tiap layar tidak
/// lagi menulis `Center(child: CircularProgressIndicator())` sendiri.
class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({super.key, this.size = 36, this.message});

  final double size;

  /// Keterangan opsional di bawah spinner (mis. "Menyimpan profil…").
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: const CircularProgressIndicator(
              strokeWidth: 3,
              color: AppColors.teal,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 12),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Memblokir interaksi [child] dengan scrim transparan + spinner selama
/// [isLoading] bernilai `true`.
///
/// Cocok untuk aksi simpan/hapus asinkron: mencegah double-tap dan memberi
/// umpan balik jelas tanpa harus mengganti isi layar.
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
    this.opacity = 0.55,
  });

  final bool isLoading;
  final Widget child;
  final String? message;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: AbsorbPointer(
              child: ColoredBox(
                color: AppColors.surface.withValues(alpha: opacity),
                child: AppLoadingIndicator(message: message),
              ),
            ),
          ),
      ],
    );
  }
}
