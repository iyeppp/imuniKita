import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../baby_profile/presentation/providers/baby_provider.dart';
import '../../../immunization/presentation/providers/immunization_provider.dart';
import '../../../growth/presentation/providers/growth_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final babiesAsync = ref.watch(babyNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundOf(context),
      body: SafeArea(
        child: babiesAsync.when(
          data: (babies) {
            if (babies.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.child_care, size: 80, color: AppColors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada profil anak',
                        style: GoogleFonts.baloo2(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => context.go(AppRoutes.addBaby),
                        child: const Text('Tambah Profil Anak'),
                      )
                    ],
                  ),
                ),
              );
            }

            final currentBaby = babies.first;
            final schedulesAsync = ref.watch(immunizationProvider(currentBaby.babyId));
            final growthAsync = ref.watch(growthProvider(currentBaby.babyId));

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
                    // Header Card Component
                    Card(
                      elevation: 0,
                      color: AppColors.coral.withValues(alpha: 0.15),
<<<<<<< Updated upstream
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: AppColors.coral,
                              child: const Icon(Icons.face, size: 40, color: Colors.white),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Selamat Pagi!',
                                    style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
=======
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () =>
                            _showBabySelector(context, ref, currentBaby.babyId),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              BabyAvatar(
                                radius: 28,
                                name: currentBaby.namaAnak,
                                photoPath: currentBaby.fotoProfilPath,
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
                                        color: AppColors.textSecondaryOf(context),
                                      ),
                                    ),
                                    Text(
                                      currentBaby.namaAnak,
                                      style: GoogleFonts.baloo2(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimaryOf(context),
                                      ),
                                    ),
                                    Text(
                                      '${currentBaby.jenisKelamin == "L" ? "Laki-laki" : "Perempuan"} • ${AgeCalculator.label(currentBaby.tanggalLahir)}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: AppColors.textSecondaryOf(context),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Shortcut Ganti Bayi
                              Material(
                                color: AppColors.surfaceOf(context),
                                borderRadius: BorderRadius.circular(20),
                                elevation: 0.5,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () => _showBabySelector(
                                    context,
                                    ref,
                                    currentBaby.babyId,
>>>>>>> Stashed changes
                                  ),
                                  Text(
                                    currentBaby.namaAnak,
                                    style: GoogleFonts.baloo2(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.darkText),
                                  ),
                                  Text(
                                    'Jenis Kelamin: ${currentBaby.jenisKelamin == "L" ? "Laki-laki" : "Perempuan"}',
                                    style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Next Vaccine Countdown Component
                    Text(
                      'Jadwal Imunisasi Terdekat',
                      style: GoogleFonts.baloo2(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkText),
                    ),
                    const SizedBox(height: 8),
                    schedulesAsync.when(
                      data: (schedules) {
                        final upcoming = schedules.where((s) => s.status == 'BELUM').toList();
                        if (upcoming.isEmpty) {
                          return const Card(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text('Semua imunisasi telah diselesaikan! 🎉'),
                            ),
                          );
                        }
                        final nextVaccine = upcoming.first;
                        final daysLeft = nextVaccine.tanggalTarget.difference(DateTime.now()).inDays;
                        final isWarning = daysLeft < 7;

<<<<<<< Updated upstream
                        return Card(
                          color: isWarning ? AppColors.yellow.withValues(alpha: 0.2) : Colors.white,
                          child: ListTile(
                            leading: Icon(
                              Icons.vaccines,
                              color: isWarning ? AppColors.red : AppColors.teal,
                              size: 32,
                            ),
                            title: Text(
                              nextVaccine.namaVaksin,
                              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            subtitle: Text(nextVaccine.deskripsi, maxLines: 2, overflow: TextOverflow.ellipsis),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isWarning ? AppColors.red : AppColors.teal,
                                borderRadius: BorderRadius.circular(20),
=======
                        return VaccineCard(
                          schedule: nextVaccine,
                          showMeta: false,
                          backgroundColor: isWarning
                              ? AppColors.yellow.withValues(alpha: 0.2)
                              : AppColors.surfaceOf(context),
                          onTap: () => context.push(
                            '${AppRoutes.calendar}?date=${nextVaccine.tanggalTarget.toIso8601String()}',
                            extra: nextVaccine.tanggalTarget,
                          ),
                          leading: Icon(
                            Icons.vaccines,
                            color: isWarning ? AppColors.red : AppColors.teal,
                            size: 32,
                          ),
                          trailing: StatusBadge(
                            label: daysLeft <= 0
                                ? 'Hari Ini'
                                : '$daysLeft Hari Lagi',
                            color: isWarning ? AppColors.red : AppColors.teal,
                            style: StatusBadgeStyle.filled,
                            textColor: Colors.white,
                          ),
                          footer: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Target: ${DateFormatter.formatLong(nextVaccine.tanggalTarget)}',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: AppColors.textSecondaryOf(context),
                                ),
>>>>>>> Stashed changes
                              ),
                              child: Text(
                                daysLeft <= 0 ? 'Hari Ini' : '$daysLeft Hari Lagi',
                                style: GoogleFonts.poppins(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        );
                      },
                      loading: () => const LinearProgressIndicator(),
                      error: (err, _) => Text('Gagal memuat jadwal terdekat: $err'),
                    ),
                    const SizedBox(height: 24),

                    // Quick Actions Grid (2x2)
                    Text(
                      'Menu Utama',
                      style: GoogleFonts.baloo2(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkText),
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
                        _buildMenuCard(context, 'Kalender', Icons.calendar_month, AppColors.teal, AppRoutes.calendar),
                        _buildMenuCard(context, 'Tumbuh Kembang', Icons.bar_chart, AppColors.coral, AppRoutes.growth),
                        _buildMenuCard(context, 'Jurnal Sehat', Icons.book_outlined, AppColors.yellow, AppRoutes.journal),
                        _buildMenuCard(context, 'ImuniBot 🤖', Icons.chat_bubble_outline, Colors.purple, AppRoutes.chatbot),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Growth Summary Card Component
                    Text(
                      'Catatan Pertumbuhan Terakhir',
                      style: GoogleFonts.baloo2(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkText),
                    ),
                    const SizedBox(height: 8),
                    growthAsync.when(
                      data: (records) {
                        if (records.isEmpty) {
                          return Card(
                            child: ListTile(
                              title: const Text('Belum ada data pengukuran pertumbuhan.'),
                              trailing: IconButton(
                                icon: const Icon(Icons.add, color: AppColors.coral),
                                onPressed: () => context.go(AppRoutes.addGrowth),
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
<<<<<<< Updated upstream
                                _buildGrowthMetric('Berat Badan', '${latest.beratBadan} kg', Icons.scale),
                                _buildGrowthMetric('Tinggi Badan', '${latest.tinggiBadan} cm', Icons.straighten),
                                _buildGrowthMetric('Lingkar Kepala', latest.lingkarKepala != null ? '${latest.lingkarKepala} cm' : '-', Icons.face_retouching_natural),
=======
                                _buildGrowthMetric(
                                  'Berat Badan',
                                  '${latest.beratBadan} kg',
                                  Icons.scale,
                                  context,
                                ),
                                _buildGrowthMetric(
                                  'Tinggi Badan',
                                  '${latest.tinggiBadan} cm',
                                  Icons.straighten,
                                  context,
                                ),
                                _buildGrowthMetric(
                                  'Lingkar Kepala',
                                  latest.lingkarKepala != null
                                      ? '${latest.lingkarKepala} cm'
                                      : '-',
                                  Icons.face_retouching_natural,
                                  context,
                                ),
>>>>>>> Stashed changes
                              ],
                            ),
                          ),
                        );
                      },
                      loading: () => const LinearProgressIndicator(),
                      error: (err, _) => Text('Gagal memuat rekam pertumbuhan: $err'),
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
          if (index == 2) context.go(AppRoutes.growth);
          if (index == 3) context.go(AppRoutes.journal);
          if (index == 4) context.go(AppRoutes.settings);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Kalender'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Pertumbuhan'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Jurnal'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon, Color color, String route) {
    return GestureDetector(
      onTap: () => context.go(route),
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
<<<<<<< Updated upstream
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.darkText),
            )
=======
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppColors.textPrimaryOf(context),
              ),
            ),
>>>>>>> Stashed changes
          ],
        ),
      ),
    );
  }

  Widget _buildGrowthMetric(String label, String value, IconData icon, BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.coral, size: 28),
        const SizedBox(height: 4),
<<<<<<< Updated upstream
        Text(label, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)),
        Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.darkText)),
      ],
    );
  }
=======
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: AppColors.textSecondaryOf(context),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: AppColors.textPrimaryOf(context),
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
      backgroundColor: AppColors.surfaceOf(context),
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
                            color: AppColors.textPrimaryOf(context),
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
                          return const EmptyStateWidget(
                            icon: Icons.child_care,
                            title: 'Belum ada data anak',
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

                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 2,
                                horizontal: 6,
                              ),
                              leading: BabyAvatar(
                                radius: 22,
                                name: baby.namaAnak,
                                photoPath: baby.fotoProfilPath,
                              ),
                              title: Text(
                                baby.namaAnak,
                                style: GoogleFonts.poppins(
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? AppColors.teal
                                      : AppColors.textPrimaryOf(context),
                                ),
                              ),
                              subtitle: Text(
                                '${baby.jenisKelamin == "L" ? "Laki-laki" : "Perempuan"} • ${AgeCalculator.label(baby.tanggalLahir)}',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: AppColors.textSecondaryOf(context),
                                ),
                              ),
                              trailing: isSelected
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
                      loading: () => const Padding(
                        padding: EdgeInsets.all(16),
                        child: AppLoadingIndicator(size: 28),
                      ),
                      error: (e, _) => ErrorStateWidget(
                        compact: true,
                        title: 'Gagal memuat daftar anak',
                        message: '$e',
                      ),
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
>>>>>>> Stashed changes
}
