import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/age_calculator.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../baby_profile/presentation/providers/active_baby_provider.dart';
import '../../../baby_profile/presentation/providers/baby_provider.dart';
import '../../../immunization/domain/entities/vaccine_schedule_entity.dart';
import '../../../immunization/presentation/providers/immunization_provider.dart';
import '../../../growth/presentation/providers/growth_provider.dart';

String _getGreeting() {
  final hour = DateTime.now().hour;
  if (hour < 11) return 'Selamat Pagi! 🌤️';
  if (hour < 15) return 'Selamat Siang! ☀️';
  if (hour < 18) return 'Selamat Sore! 🌇';
  return 'Selamat Malam! 🌙';
}

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final babyAsync = ref.watch(activeBabyProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: babyAsync.when(
          data: (currentBaby) {
            if (currentBaby == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.child_care,
                        size: 80,
                        color: AppColors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada profil anak',
                        style: GoogleFonts.baloo2(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => context.go(AppRoutes.addBaby),
                        child: const Text('Tambah Profil Anak'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final schedulesAsync = ref.watch(
              immunizationProvider(currentBaby.babyId),
            );
            final growthAsync = ref.watch(growthProvider(currentBaby.babyId));

            final babyFile = currentBaby.fotoProfilPath == null
                ? null
                : File(currentBaby.fotoProfilPath!);
            final ImageProvider? babyPhoto =
                (babyFile != null && babyFile.existsSync())
                    ? FileImage(babyFile)
                    : null;
            final babyInitial = currentBaby.namaAnak.trim().isEmpty
                ? '?'
                : currentBaby.namaAnak.trim()[0].toUpperCase();

            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(babyNotifierProvider);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Card Component with direct Switch Baby Shortcut
                    Card(
                      elevation: 0,
                      color: AppColors.coral.withValues(alpha: 0.15),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => _showBabySelector(context, ref, currentBaby.babyId),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor:
                                    AppColors.teal.withValues(alpha: 0.15),
                                backgroundImage: babyPhoto,
                                child: babyPhoto != null
                                    ? null
                                    : Text(
                                        babyInitial,
                                        style: GoogleFonts.baloo2(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.tealDark,
                                        ),
                                      ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _getGreeting(),
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    Text(
                                      currentBaby.namaAnak,
                                      style: GoogleFonts.baloo2(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.darkText,
                                      ),
                                    ),
                                    Text(
                                      '${currentBaby.jenisKelamin == "L" ? "Laki-laki" : "Perempuan"} • ${AgeCalculator.label(currentBaby.tanggalLahir)}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Shortcut Ganti Bayi
                              Material(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                elevation: 0.5,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () => _showBabySelector(context, ref, currentBaby.babyId),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.swap_horiz, size: 16, color: AppColors.coral),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Ganti',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.coral,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Next Vaccine Countdown Component with Direct Button to Calendar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Jadwal Imunisasi Terdekat',
                          style: GoogleFonts.baloo2(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkText,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => context.push(AppRoutes.calendar),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            visualDensity: VisualDensity.compact,
                          ),
                          icon: const Icon(
                            Icons.calendar_month,
                            size: 16,
                            color: AppColors.teal,
                          ),
                          label: Text(
                            'Buka Kalender',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.teal,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    schedulesAsync.when(
                      data: (schedules) {
                        final upcoming = schedules
                            .where((s) => s.status == VaccineStatus.belum)
                            .toList();
                        if (upcoming.isEmpty) {
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  const Expanded(
                                    child: Text(
                                      'Semua imunisasi telah diselesaikan! 🎉',
                                    ),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.teal,
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: () => context.push(AppRoutes.calendar),
                                    child: const Text('Buka Kalender'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        final nextVaccine = upcoming.first;
                        final daysLeft = nextVaccine.tanggalTarget
                            .difference(DateTime.now())
                            .inDays;
                        final isWarning = daysLeft < 7;

                        return Card(
                          color: isWarning
                              ? AppColors.yellow.withValues(alpha: 0.2)
                              : Colors.white,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => context.push(
                              '${AppRoutes.calendar}?date=${nextVaccine.tanggalTarget.toIso8601String()}',
                              extra: nextVaccine.tanggalTarget,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                children: [
                                  ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: Icon(
                                      Icons.vaccines,
                                      color: isWarning ? AppColors.red : AppColors.teal,
                                      size: 32,
                                    ),
                                    title: Text(
                                      nextVaccine.namaVaksin,
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    subtitle: Text(
                                      nextVaccine.deskripsi,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    trailing: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isWarning
                                            ? AppColors.red
                                            : AppColors.teal,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        daysLeft <= 0
                                            ? 'Hari Ini'
                                            : '$daysLeft Hari Lagi',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Divider(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Target: ${DateFormatter.formatLong(nextVaccine.tanggalTarget)}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            'Lihat di Kalender',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.teal,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          const Icon(
                                            Icons.arrow_forward,
                                            size: 14,
                                            color: AppColors.teal,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      loading: () => const LinearProgressIndicator(),
                      error: (err, _) =>
                          Text('Gagal memuat jadwal terdekat: $err'),
                    ),
                    const SizedBox(height: 24),

                    // Quick Actions Grid (2x2)
                    Text(
                      'Menu Utama',
                      style: GoogleFonts.baloo2(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.4,
                      children: [
                        _buildMenuCard(
                          context,
                          'Kalender',
                          Icons.calendar_month,
                          AppColors.teal,
                          AppRoutes.calendar,
                        ),
                        _buildMenuCard(
                          context,
                          'Tumbuh Kembang',
                          Icons.bar_chart,
                          AppColors.coral,
                          AppRoutes.growth,
                          push: true,
                        ),
                        _buildMenuCard(
                          context,
                          'Jurnal Sehat',
                          Icons.book_outlined,
                          AppColors.yellow,
                          AppRoutes.journal,
                          push: true,
                        ),
                        // Edukasi dibuka dengan push karena tidak punya bottom nav.
                        _buildMenuCard(
                          context,
                          'Edukasi',
                          Icons.menu_book,
                          AppColors.pinkLogo,
                          AppRoutes.education,
                          push: true,
                        ),
                        _buildMenuCard(
                          context,
                          'ImuniBot 🤖',
                          Icons.chat_bubble_outline,
                          AppColors.tealDark,
                          AppRoutes.chatbot,
                        ),
                        _buildMenuCard(
                          context,
                          'Direktori Faskes',
                          Icons.local_hospital_outlined,
                          AppColors.green,
                          AppRoutes.faskes,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Growth Summary Card Component
                    Text(
                      'Catatan Pertumbuhan Terakhir',
                      style: GoogleFonts.baloo2(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    growthAsync.when(
                      data: (records) {
                        if (records.isEmpty) {
                          return Card(
                            child: ListTile(
                              title: const Text(
                                'Belum ada data pengukuran pertumbuhan.',
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.add,
                                  color: AppColors.coral,
                                ),
                                onPressed: () =>
                                    context.go(AppRoutes.addGrowth),
                              ),
                            ),
                          );
                        }
                        final latest = records.last;
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildGrowthMetric(
                                  'Berat Badan',
                                  '${latest.beratBadan} kg',
                                  Icons.scale,
                                ),
                                _buildGrowthMetric(
                                  'Tinggi Badan',
                                  '${latest.tinggiBadan} cm',
                                  Icons.straighten,
                                ),
                                _buildGrowthMetric(
                                  'Lingkar Kepala',
                                  latest.lingkarKepala != null
                                      ? '${latest.lingkarKepala} cm'
                                      : '-',
                                  Icons.face_retouching_natural,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      loading: () => const LinearProgressIndicator(),
                      error: (err, _) =>
                          Text('Gagal memuat rekam pertumbuhan: $err'),
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Terjadi Kesalahan: $err')),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) context.go(AppRoutes.calendar);
          if (index == 2) context.go(AppRoutes.faskes);
          if (index == 3) context.go(AppRoutes.chatbot);
          if (index == 4) context.go(AppRoutes.settings);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Kalender',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_hospital_outlined),
            label: 'Faskes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'ImuniBot',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    String route, {
    bool push = false,
  }) {
    return GestureDetector(
      onTap: () => push ? context.push(route) : context.go(route),
      child: Card(
        color: color.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: color, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 36),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppColors.darkText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrowthMetric(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.coral, size: 28),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: AppColors.darkText,
          ),
        ),
      ],
    );
  }

  void _showBabySelector(
    BuildContext context,
    WidgetRef ref,
    String currentBabyId,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Consumer(
          builder: (context, ref, _) {
            final babiesAsync = ref.watch(babyNotifierProvider);
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Pilih Profil Anak',
                          style: GoogleFonts.baloo2(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkText,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    babiesAsync.when(
                      data: (babies) {
                        if (babies.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Text('Belum ada data anak.'),
                          );
                        }
                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: babies.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (_, index) {
                            final baby = babies[index];
                            final isSelected = baby.babyId == currentBabyId;
                            final file = baby.fotoProfilPath == null
                                ? null
                                : File(baby.fotoProfilPath!);
                            final ImageProvider? foto =
                                (file != null && file.existsSync())
                                    ? FileImage(file)
                                    : null;
                            final inisial = baby.namaAnak.trim().isEmpty
                                ? '?'
                                : baby.namaAnak.trim()[0].toUpperCase();

                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 2,
                                horizontal: 6,
                              ),
                              leading: CircleAvatar(
                                radius: 22,
                                backgroundColor:
                                    AppColors.teal.withValues(alpha: 0.15),
                                backgroundImage: foto,
                                child: foto != null
                                    ? null
                                    : Text(
                                        inisial,
                                        style: GoogleFonts.baloo2(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.tealDark,
                                        ),
                                      ),
                              ),
                              title: Text(
                                baby.namaAnak,
                                style: GoogleFonts.poppins(
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                  color:
                                      isSelected
                                          ? AppColors.teal
                                          : AppColors.darkText,
                                ),
                              ),
                              subtitle: Text(
                                '${baby.jenisKelamin == "L" ? "Laki-laki" : "Perempuan"} • ${AgeCalculator.label(baby.tanggalLahir)}',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              trailing:
                                  isSelected
                                      ? const Icon(
                                          Icons.check_circle,
                                          color: AppColors.teal,
                                        )
                                      : null,
                              onTap: () {
                                ref
                                    .read(activeBabyProvider.notifier)
                                    .selectBaby(baby.babyId);
                                Navigator.pop(ctx);
                              },
                            );
                          },
                        );
                      },
                      loading:
                          () => const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(),
                            ),
                          ),
                      error: (e, _) => Text('Gagal: $e'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(44),
                        side: const BorderSide(color: AppColors.teal),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.add, color: AppColors.teal),
                      label: Text(
                        'Tambah Profil Anak',
                        style: GoogleFonts.poppins(
                          color: AppColors.teal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        context.push(AppRoutes.addBaby);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
