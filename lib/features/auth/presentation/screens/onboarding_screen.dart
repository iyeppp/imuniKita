import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _slides = [
    {
      'title': 'Pantau Imunisasi Buah Hati',
      'description': 'Catat dan pantau riwayat imunisasi anak dengan mudah demi perlindungan optimal sejak lahir.',
      'icon': Icons.child_care,
      'color': AppColors.coral,
    },
    {
      'title': 'Pengingat Otomatis H-7 & H-1',
      'description': 'Jangan lewatkan jadwal penting. Aplikasi akan memberikan notifikasi otomatis sebelum hari imunisasi.',
      'icon': Icons.calendar_month,
      'color': AppColors.teal,
    },
    {
      'title': 'Pantau Tumbuh Kembang si Kecil',
      'description': 'Pantau grafik berat badan, tinggi badan, dan lingkar kepala sesuai standar referensi WHO.',
      'icon': Icons.bar_chart,
      'color': AppColors.yellow,
    },
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seen_onboarding', true);
    if (mounted) {
      context.go(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Skip Button
            Align(
              alignmen  t: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: _currentPage < _slides.length - 1
                    ? TextButton(
                        onPressed: _completeOnboarding,
                        child: Text(
                          'Lewati',
                          style: GoogleFonts.poppins(
                            color: AppColors.darkText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : const SizedBox(height: 48),
              ),
            ),

            // PageView Slides
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Illustration/Icon Container with Thick Border (Bold Flat Style)
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: (slide['color'] as Color).withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.darkText, width: 3),
                            boxShadow: const [
                              BoxShadow(
                                color: AppColors.darkText,
                                offset: Offset(4, 4),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: Icon(
                            slide['icon'] as IconData,
                            size: 100,
                            color: AppColors.darkText,
                          ),
                        ),
                        const SizedBox(height: 48),

                        // Title text
                        Text(
                          slide['title'],
                          textAlign: TextAlign.center,
                          style: GoogleFonts.baloo2(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkText,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Description text
                        Text(
                          slide['description'],
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Page Indicator Dots and Action Buttons
            Padding(
              padding: EdgeInsets.fromLTRB(32, 16, 32, media.padding.bottom + 24),
              child: Column(
                children: [
                  // Animated Page Indicator Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_slides.length, (index) {
                      final isSelected = _currentPage == index;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 10,
                        width: isSelected ? 24 : 10,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.teal : AppColors.grey.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: AppColors.darkText, width: 1.5),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 32),

                  // Bottom Action Buttons with Bold Neo-brutalism Style
                  _currentPage == _slides.length - 1
                      ? Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                color: AppColors.darkText,
                                offset: Offset(3, 3),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _completeOnboarding,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.teal,
                              side: const BorderSide(color: AppColors.darkText, width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Mulai Sekarang',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkText,
                              ),
                            ),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(width: 60), // Balanced spacing
                            Container(
                              width: 140,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: const [
                                  BoxShadow(
                                    color: AppColors.darkText,
                                    offset: Offset(3, 3),
                                    blurRadius: 0,
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  _pageController.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.coral,
                                  side: const BorderSide(color: AppColors.darkText, width: 2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Selanjutnya',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.darkText,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.arrow_forward, color: AppColors.darkText, size: 18),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
