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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(AppRoutes.dashboard);
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
            labelColor: Theme.of(context).colorScheme.onSurface,
            unselectedLabelColor: AppColors.textHint,
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
      ),
    );
  }

  /// Sumbu X grafik = **usia (bulan)** saat pengukuran & umur anak saat ini.
  /// Kurva acuan WHO menyesuaikan secara dinamis sampai umur anak saat ini.
  Widget _buildChartTab(
    List<GrowthRecordEntity> records,
    String mode, {
    required DateTime tanggalLahir,
    required bool isLakiLaki,
  }) {
    final who = WhoGrowthReference.forMode(mode, isLakiLaki: isLakiLaki);
    final whoOver24 = WhoGrowthReference.forMode(
      mode,
      isLakiLaki: isLakiLaki,
      over24: true,
    );

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

    final umurAnakBulan =
        DateTime.now().difference(tanggalLahir).inDays / 30.4375;
    final maxBulanAnak = umurAnakBulan < 0 ? 0.0 : umurAnakBulan;
    final maxBulanData = spots.isNotEmpty
        ? spots.map((s) => s.x).reduce((a, b) => a > b ? a : b)
        : 0.0;

    // Grafik acuan optimal menyesuaikan dinamis sampai umur anak saat ini (atau max data pengukuran)
    final maxBulanChart =
        maxBulanData > maxBulanAnak ? maxBulanData : maxBulanAnak;
    final rangeX = maxBulanChart < 1 ? 1.0 : maxBulanChart;

    if (records.isEmpty && maxBulanAnak == 0) {
      return const EmptyStateWidget(
        icon: Icons.show_chart,
        title: 'Belum ada rekam data',
        message:
            'Klik tombol + di kanan atas untuk menambahkan pengukuran pertama.',
      );
    }

    // Kurva referensi WHO (median, −2SD, +2SD) dinamis sampai umur anak.
    List<FlSpot> kurva(
      WhoSeries? series,
      double? Function(double) ambil,
    ) {
      final titik = <FlSpot>[];
      if (series == null) return titik;
      final start = series.startMonth.toDouble();
      if (maxBulanChart < start) return titik;
      final batas = maxBulanChart < series.maxMonth
          ? maxBulanChart
          : series.maxMonth.toDouble();
      for (var bulan = start; bulan <= batas; bulan += 1) {
        final nilai = ambil(bulan);
        if (nilai != null) titik.add(FlSpot(bulan, nilai));
      }
      if (titik.isNotEmpty &&
          batas > titik.last.x &&
          batas <= series.maxMonth) {
        final nilaiBatas = ambil(batas);
        if (nilaiBatas != null) titik.add(FlSpot(batas, nilaiBatas));
      }
      return titik;
    }

    final medianSpots = kurva(who, (b) => who?.medianAt(b));
    final minus2Spots = kurva(who, (b) => who?.minus2SdAt(b));
    final plus2Spots = kurva(who, (b) => who?.plus2SdAt(b));

    final medianOver24Spots =
        kurva(whoOver24, (b) => whoOver24?.medianAt(b));
    final minus2Over24Spots =
        kurva(whoOver24, (b) => whoOver24?.minus2SdAt(b));
    final plus2Over24Spots =
        kurva(whoOver24, (b) => whoOver24?.plus2SdAt(b));

    final semuaNilai = [
      ...spots.map((s) => s.y),
      ...medianSpots.map((s) => s.y),
      ...minus2Spots.map((s) => s.y),
      ...plus2Spots.map((s) => s.y),
      ...medianOver24Spots.map((s) => s.y),
      ...minus2Over24Spots.map((s) => s.y),
      ...plus2Over24Spots.map((s) => s.y),
    ];

    if (semuaNilai.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.show_chart,
        title: 'Belum ada data untuk grafik ini',
        message: 'Lingkar kepala belum pernah diisi pada pengukuran mana pun.',
      );
    }

    final nilaiMin = semuaNilai.reduce((a, b) => a < b ? a : b);
    final nilaiMax = semuaNilai.reduce((a, b) => a > b ? a : b);
    final rentangY = (nilaiMax - nilaiMin).abs();
    final marginY = rentangY < 5 ? 1.5 : rentangY * 0.15;
    final minYChart = (nilaiMin - marginY).clamp(0.0, double.infinity);
    final maxYChart = nilaiMax + marginY;

    const warnaWho = Color(0xFF16A34A); // green-700 (0–24 bulan)
    const warnaWhoOver24 = Color(0xFF2563EB); // blue-600 (> 24 bulan)
    final modeLabel = who?.label ?? mode;
    final unit = who?.unit ?? '';

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dividerColor = Theme.of(context).dividerColor;
    final textStyleAxis = GoogleFonts.poppins(
      fontSize: 9.5,
      color: isDark ? const Color(0xFFA1A1AA) : AppColors.textHint,
    );

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Ringkasan pengukuran terakhir
          Card(
            color: context.cardBackgroundColor,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pengukuran Terakhir:',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: context.primaryTextColor,
                    ),
                  ),
                  Text(
                    records.isNotEmpty && nilaiUntuk(records.last) != null
                        ? '${nilaiUntuk(records.last)!.toStringAsFixed(1)} $unit'
                        : 'Belum ada data',
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
          const SizedBox(height: 20),

          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Hitung interval dinamis sumbu X berdasarkan lebar layar
                final chartWidth = constraints.maxWidth - 52;
                final maxXTicks = (chartWidth / 48).floor().clamp(3, 7);
                final rawIntervalX = rangeX / maxXTicks;
                double intervalX;
                if (rawIntervalX <= 1.0) {
                  intervalX = 1.0;
                } else if (rawIntervalX <= 2.0) {
                  intervalX = 2.0;
                } else if (rawIntervalX <= 3.0) {
                  intervalX = 3.0;
                } else if (rawIntervalX <= 6.0) {
                  intervalX = 6.0;
                } else {
                  intervalX = 12.0;
                }

                // Hitung interval dinamis sumbu Y
                double intervalY;
                if (rentangY <= 5) {
                  intervalY = 1.0;
                } else if (rentangY <= 15) {
                  intervalY = 2.0;
                } else if (rentangY <= 30) {
                  intervalY = 5.0;
                } else if (rentangY <= 60) {
                  intervalY = 10.0;
                } else {
                  intervalY = 20.0;
                }

                return LineChart(
                  LineChartData(
                    clipData: const FlClipData.all(),
                    minX: 0,
                    maxX: rangeX,
                    minY: minYChart,
                    maxY: maxYChart,
                    gridData: FlGridData(
                      show: true,
                      getDrawingHorizontalLine: (val) => FlLine(
                        color: dividerColor.withValues(alpha: 0.3),
                        strokeWidth: 1,
                      ),
                      getDrawingVerticalLine: (val) => FlLine(
                        color: dividerColor.withValues(alpha: 0.3),
                        strokeWidth: 1,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        axisNameWidget: Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            'usia (bulan)',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: isDark
                                  ? const Color(0xFFA1A1AA)
                                  : AppColors.textHint,
                            ),
                          ),
                        ),
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 32,
                          interval: intervalX,
                          getTitlesWidget: (value, meta) {
                            if (value < -0.05 || value > rangeX + 0.05) {
                              return const SizedBox.shrink();
                            }
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              space: 6,
                              child: Text(
                                '${value.toInt()}bln',
                                style: textStyleAxis,
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        axisNameWidget: Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            '$modeLabel ($unit)',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: isDark
                                  ? const Color(0xFFA1A1AA)
                                  : AppColors.textHint,
                            ),
                          ),
                        ),
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 52,
                          interval: intervalY,
                          getTitlesWidget: (value, meta) {
                            if (value < minYChart - 0.05 ||
                                value > maxYChart + 0.05) {
                              return const SizedBox.shrink();
                            }
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              space: 6,
                              child: Text(
                                value.toStringAsFixed(
                                  value % 1 == 0 ? 0 : 1,
                                ),
                                style: textStyleAxis,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: dividerColor, width: 1),
                    ),
                    lineBarsData: [
                      // Data anak
                      if (spots.isNotEmpty)
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: AppColors.coral,
                          barWidth: 4,
                          dotData: const FlDotData(show: true),
                        ),
                      // Median WHO (0–24 bulan)
                      if (medianSpots.isNotEmpty)
                        LineChartBarData(
                          spots: medianSpots,
                          isCurved: true,
                          color: warnaWho,
                          barWidth: 2.5,
                          dotData: const FlDotData(show: false),
                        ),
                      // −2SD WHO (0–24 bulan)
                      if (minus2Spots.isNotEmpty)
                        LineChartBarData(
                          spots: minus2Spots,
                          isCurved: true,
                          color: warnaWho.withValues(alpha: 0.55),
                          barWidth: 1.5,
                          dashArray: [6, 4],
                          dotData: const FlDotData(show: false),
                        ),
                      // +2SD WHO (0–24 bulan)
                      if (plus2Spots.isNotEmpty)
                        LineChartBarData(
                          spots: plus2Spots,
                          isCurved: true,
                          color: warnaWho.withValues(alpha: 0.55),
                          barWidth: 1.5,
                          dashArray: [6, 4],
                          dotData: const FlDotData(show: false),
                        ),
                      // Median WHO (> 24 bulan)
                      if (medianOver24Spots.isNotEmpty)
                        LineChartBarData(
                          spots: medianOver24Spots,
                          isCurved: true,
                          color: warnaWhoOver24,
                          barWidth: 2.5,
                          dotData: const FlDotData(show: false),
                        ),
                      // −2SD WHO (> 24 bulan)
                      if (minus2Over24Spots.isNotEmpty)
                        LineChartBarData(
                          spots: minus2Over24Spots,
                          isCurved: true,
                          color: warnaWhoOver24.withValues(alpha: 0.55),
                          barWidth: 1.5,
                          dashArray: [6, 4],
                          dotData: const FlDotData(show: false),
                        ),
                      // +2SD WHO (> 24 bulan)
                      if (plus2Over24Spots.isNotEmpty)
                        LineChartBarData(
                          spots: plus2Over24Spots,
                          isCurved: true,
                          color: warnaWhoOver24.withValues(alpha: 0.55),
                          barWidth: 1.5,
                          dashArray: [6, 4],
                          dotData: const FlDotData(show: false),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '*Garis hijau = standar WHO (0–24 bulan), garis biru = standar WHO (> 24 bulan) '
            '(${isLakiLaki ? 'laki-laki' : 'perempuan'}) — indikatif, '
            'bukan diagnosis.',
            style: GoogleFonts.poppins(
              fontSize: 10.5,
              color: isDark ? const Color(0xFFA1A1AA) : AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }
}
