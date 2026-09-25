import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/who_growth_reference.dart';
import '../../../../widgets/empty_state_widget.dart';
import '../../../../widgets/error_state_widget.dart';
import '../../../../widgets/loading_overlay.dart';
import '../../domain/entities/growth_record_entity.dart';
import '../../../baby_profile/domain/entities/baby_entity.dart';
import '../../../baby_profile/presentation/providers/active_baby_provider.dart';
import '../providers/growth_provider.dart';

class GrowthChartScreen extends ConsumerStatefulWidget {
  const GrowthChartScreen({super.key});

  @override
  ConsumerState<GrowthChartScreen> createState() => _GrowthChartScreenState();
}

class _GrowthChartScreenState extends ConsumerState<GrowthChartScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final babyAsync = ref.watch(activeBabyProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Kembali',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go(AppRoutes.dashboard),
        ),
        title: Text(
          'Grafik Pertumbuhan',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              tooltip: 'Tambah Pengukuran',
              style: IconButton.styleFrom(
                backgroundColor: AppColors.coral,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.add, size: 22),
              onPressed: () => context.push(AppRoutes.addGrowth),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.coral,
          labelColor: AppColors.darkText,
          tabs: const [
            Tab(text: 'Berat Badan'),
            Tab(text: 'Tinggi Badan'),
            Tab(text: 'Lingkar Kepala'),
          ],
        ),
      ),
      body: babyAsync.when(
        data: (currentBaby) {
          if (currentBaby == null) {
            return EmptyStateWidget(
              icon: Icons.child_care,
              title: 'Belum ada profil anak',
              message:
                  'Tambahkan profil anak untuk melihat grafik pertumbuhan.',
              actionLabel: 'Tambah Profil Anak',
              onAction: () => context.push(AppRoutes.addBaby),
            );
          }
          final recordsAsync = ref.watch(growthProvider(currentBaby.babyId));

          final isLakiLaki = currentBaby.jenisKelamin == BabyGender.laki;

          return recordsAsync.when(
            data: (records) {
              return TabBarView(
                controller: _tabController,
                children: [
                  _buildChartTab(
                    records,
                    'BB',
                    tanggalLahir: currentBaby.tanggalLahir,
                    isLakiLaki: isLakiLaki,
                  ),
                  _buildChartTab(
                    records,
                    'TB',
                    tanggalLahir: currentBaby.tanggalLahir,
                    isLakiLaki: isLakiLaki,
                  ),
                  _buildChartTab(
                    records,
                    'LK',
                    tanggalLahir: currentBaby.tanggalLahir,
                    isLakiLaki: isLakiLaki,
                  ),
                ],
              );
            },
            loading: () => const AppLoadingIndicator(),
            error: (err, _) => ErrorStateWidget(message: '$err'),
          );
        },
        loading: () => const AppLoadingIndicator(),
        error: (err, _) => ErrorStateWidget(message: '$err'),
      ),
    );
  }

  /// Sumbu X grafik = **usia (bulan)** saat pengukuran, sehingga titik anak
  /// bisa dibandingkan langsung dengan kurva referensi WHO (Temuan #8).
  /// Titik lingkar kepala yang kosong dilewati, bukan diplot 0 (Temuan #47).
  Widget _buildChartTab(
    List<GrowthRecordEntity> records,
    String mode, {
    required DateTime tanggalLahir,
    required bool isLakiLaki,
  }) {
    if (records.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.show_chart,
        title: 'Belum ada rekam data',
        message:
            'Klik tombol + di kanan atas untuk menambahkan pengukuran pertama.',
      );
    }

    final who = WhoGrowthReference.forMode(mode, isLakiLaki: isLakiLaki);

    double? nilaiUntuk(GrowthRecordEntity r) => switch (mode) {
      'BB' => r.beratBadan,
      'TB' => r.tinggiBadan,
      'LK' => r.lingkarKepala,
      _ => null,
    };

    final spots = <FlSpot>[];
    for (final r in records) {
      final nilai = nilaiUntuk(r);
      if (nilai == null) continue; // lingkar kepala opsional
      final bulan =
          r.tanggalPengukuran.difference(tanggalLahir).inDays / 30.4375;
      spots.add(FlSpot(bulan < 0 ? 0 : bulan, nilai));
    }

    if (spots.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.show_chart,
        title: 'Belum ada data untuk grafik ini',
        message: 'Lingkar kepala belum pernah diisi pada pengukuran mana pun.',
      );
    }

    final maxBulan = spots.map((s) => s.x).reduce((a, b) => a > b ? a : b);

    // Kurva referensi WHO (median, −2SD, +2SD) sepanjang rentang data anak.
    List<FlSpot> kurva(double? Function(double) ambil) {
      final titik = <FlSpot>[];
      if (who == null) return titik;
      final batas = maxBulan < who.maxMonth
          ? maxBulan
          : who.maxMonth.toDouble();
      for (var bulan = 0.0; bulan <= batas; bulan += 1) {
        final nilai = ambil(bulan);
        if (nilai != null) titik.add(FlSpot(bulan, nilai));
      }
      return titik;
    }

    final medianSpots = kurva((b) => who?.medianAt(b));
    final minus2Spots = kurva((b) => who?.minus2SdAt(b));
    final plus2Spots = kurva((b) => who?.plus2SdAt(b));

    final semuaNilai = [
      ...spots.map((s) => s.y),
      ...medianSpots.map((s) => s.y),
      ...minus2Spots.map((s) => s.y),
      ...plus2Spots.map((s) => s.y),
    ];
    final nilaiMin = semuaNilai.reduce((a, b) => a < b ? a : b);
    final nilaiMax = semuaNilai.reduce((a, b) => a > b ? a : b);
    final rentang = (nilaiMax - nilaiMin).abs();
    final margin = rentang < 5 ? 1.0 : rentang * 0.15;

    const warnaWho = Color(0xFF16A34A); // green-700
    final modeLabel = who?.label ?? mode;
    final unit = who?.unit ?? '';

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Ringkasan pengukuran terakhir
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pengukuran Terakhir:',
                    style: GoogleFonts.poppins(fontSize: 13),
                  ),
                  Text(
                    '${nilaiUntuk(records.last)?.toStringAsFixed(1) ?? '-'} $unit',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.coral,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          Expanded(
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: maxBulan < 1 ? 1 : maxBulan,
                minY: nilaiMin - margin,
                maxY: nilaiMax + margin,
                gridData: const FlGridData(show: true),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    axisNameWidget: Text(
                      'usia (bulan)',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: AppColors.textHint,
                      ),
                    ),
                    sideTitles: const SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    axisNameWidget: Text(
                      ' $modeLabel ($unit)',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: AppColors.textHint,
                      ),
                    ),
                    sideTitles: const SideTitles(
                      showTitles: true,
                      reservedSize: 38,
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                lineBarsData: [
                  // Data anak
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppColors.coral,
                    barWidth: 4,
                    dotData: const FlDotData(show: true),
                  ),
                  // Median WHO
                  if (medianSpots.isNotEmpty)
                    LineChartBarData(
                      spots: medianSpots,
                      isCurved: true,
                      color: warnaWho,
                      barWidth: 2.5,
                      dotData: const FlDotData(show: false),
                    ),
                  // −2SD WHO
                  if (minus2Spots.isNotEmpty)
                    LineChartBarData(
                      spots: minus2Spots,
                      isCurved: true,
                      color: warnaWho.withValues(alpha: 0.55),
                      barWidth: 1.5,
                      dashArray: [6, 4],
                      dotData: const FlDotData(show: false),
                    ),
                  // +2SD WHO
                  if (plus2Spots.isNotEmpty)
                    LineChartBarData(
                      spots: plus2Spots,
                      isCurved: true,
                      color: warnaWho.withValues(alpha: 0.55),
                      barWidth: 1.5,
                      dashArray: [6, 4],
                      dotData: const FlDotData(show: false),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '*Garis hijau = median, −2SD, dan +2SD WHO Child Growth Standards '
            '(${isLakiLaki ? 'laki-laki' : 'perempuan'}, 0–24 bulan) — indikatif, '
            'bukan diagnosis.',
            style: GoogleFonts.poppins(
              fontSize: 10.5,
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }
}
