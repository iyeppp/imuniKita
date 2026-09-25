import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../injection/dependency_injection.dart';
import '../widgets/confetti_dots_painter.dart';

/// Splash Screen ImuniKita (Design System v1.0).
/// Mengikuti spesifikasi revisi:
/// - Two-zone layout: Zona coral 62% (atas) + Zona teal 38% (bawah garis lurus)
/// - Confetti dots bervariasi ukuran (XL, M, S) di layer belakang
/// - Karakter Ibu & Bayi flat vector style Petdegree (tanpa background, transparent PNG)
/// - Scaling responsif mengikuti tinggi & lebar layar pengguna
/// - Headline Baloo 2 ExtraBold & Subtitle Poppins di zona teal bawah
/// - Animasi entry berurutan & routing otomatis ke Onboarding / Login / Dashboard
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _mainAnimController;
  late final AnimationController _floatAnimController;

  // Staggered Animations
  late final Animation<double> _confettiAnim;
  late final Animation<Offset> _characterSlideAnim;
  late final Animation<double> _characterFadeAnim;
  late final Animation<Offset> _tealBlockSlideAnim;
  late final Animation<double> _textFadeAnim;
  late final Animation<double> _floatAnim;

  Timer? _navTimer;

  @override
  void initState() {
    super.initState();

    // 1. Controller Animasi Masuk (1200ms)
    _mainAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // 2. Controller Animasi Floating halus untuk karakter
    _floatAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    _floatAnim = Tween<double>(begin: 0.0, end: -6.0).animate(
      CurvedAnimation(
        parent: _floatAnimController,
        curve: Curves.easeInOutSine,
      ),
    );

    // Confetti Dots: Pop-in bertahap (100ms - 800ms)
    _confettiAnim = CurvedAnimation(
      parent: _mainAnimController,
      curve: const Interval(0.08, 0.70, curve: Curves.easeOut),
    );

    // Karakter Ibu + Bayi: Slide Up + Fade (150ms - 750ms)
    _characterSlideAnim =
        Tween<Offset>(begin: const Offset(0.0, 0.18), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _mainAnimController,
            curve: const Interval(0.12, 0.65, curve: Curves.easeOutCubic),
          ),
        );
    _characterFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainAnimController,
        curve: const Interval(0.12, 0.50, curve: Curves.easeIn),
      ),
    );

    // Blok Teal Bawah: SlideUp dari bawah (300ms - 900ms)
    _tealBlockSlideAnim =
        Tween<Offset>(begin: const Offset(0.0, 0.35), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _mainAnimController,
            curve: const Interval(0.25, 0.75, curve: Curves.easeOutCubic),
          ),
        );

    // Teks Bawah: FadeIn (450ms - 950ms)
    _textFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainAnimController,
        curve: const Interval(0.40, 0.85, curve: Curves.easeIn),
      ),
    );

    // Jalankan animasi masuk, lalu loop floating bob
    _mainAnimController.forward().then((_) {
      if (mounted) {
        _floatAnimController.repeat(reverse: true);
      }
    });

    // Inisialisasi navigasi otomatis setelah 2.8 detik
    _startNavigationTimer();
  }

  void _startNavigationTimer() {
    _navTimer = Timer(const Duration(milliseconds: 2800), () async {
      if (!mounted) return;

      try {
        // Temuan #22: status sesi dibaca lewat use case, bukan SharedPreferences
        // langsung dari layar.
        final status = await ref.read(checkAuthStateUseCaseProvider).execute();

        if (!mounted) return;

        if (status.loggedIn) {
          context.go(AppRoutes.dashboard);
        } else if (status.seenOnboarding) {
          context.go(AppRoutes.login);
        } else {
          context.go(AppRoutes.onboarding);
        }
      } catch (_) {
        if (mounted) {
          context.go(AppRoutes.onboarding);
        }
      }
    });
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _mainAnimController.dispose();
    _floatAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final screenHeight = media.size.height;
    final screenWidth = media.size.width;

    // Rasio pembagian layout: 62% Coral (atas) & 38% Teal (bawah)
    final topZoneHeight = screenHeight * 0.62;
    final bottomZoneHeight = screenHeight * 0.38;

    return Scaffold(
      backgroundColor: AppColors.coral,
      body: SizedBox(
        width: screenWidth,
        height: screenHeight,
        child: Stack(
          children: [
            // ── LAYER 1: Background Coral Atas ──────────────────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: topZoneHeight,
              child: Container(color: AppColors.coral),
            ),

            // ── LAYER 2: Confetti Dots Dinamis (XL, M, S) ───────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: topZoneHeight,
              child: AnimatedBuilder(
                animation: _confettiAnim,
                builder: (context, _) {
                  return CustomPaint(
                    painter: ConfettiDotsPainter(
                      animationProgress: _confettiAnim.value,
                    ),
                    size: Size(screenWidth, topZoneHeight),
                  );
                },
              ),
            ),

            // ── LAYER 3: Karakter Ibu & Bayi (Asset Transparan & Responsive)
            Positioned(
              top: media.padding.top + 16,
              left: 0,
              right: 0,
              bottom: bottomZoneHeight,
              child: SlideTransition(
                position: _characterSlideAnim,
                child: FadeTransition(
                  opacity: _characterFadeAnim,
                  child: AnimatedBuilder(
                    animation: _floatAnim,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _floatAnim.value),
                        child: child,
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Image.asset(
                        'assets/images/splash_character.png',
                        fit: BoxFit.contain,
                        alignment: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── LAYER 5: Blok Bawah Teal Solid (38% Layar) ──────────────────
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: bottomZoneHeight,
              child: SlideTransition(
                position: _tealBlockSlideAnim,
                child: Container(
                  width: screenWidth,
                  height: bottomZoneHeight,
                  color: AppColors.teal,
                  padding: EdgeInsets.fromLTRB(
                    32,
                    28,
                    32,
                    media.padding.bottom + 20,
                  ),
                  child: FadeTransition(
                    opacity: _textFadeAnim,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Headline Utama (Baloo 2 ExtraBold)
                        Text(
                          'Si kecil,\nterlindungi',
                          style: GoogleFonts.baloo2(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkText,
                            height: 1.08,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Subtitle Deskripsi (Poppins Regular)
                        Text(
                          'Jadwal imunisasi dalam genggamanmu',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: AppColors.darkText,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
