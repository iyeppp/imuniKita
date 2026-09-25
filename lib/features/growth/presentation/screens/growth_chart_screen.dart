import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
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
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(AppRoutes.dashboard),
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
            return const Center(child: Text('Belum ada profil anak.'));
          }
          final recordsAsync = ref.watch(growthProvider(currentBaby.babyId));

          return recordsAsync.when(
            data: (records) {
              return TabBarView(
                controller: _tabController,
                children: [
                  _buildChartTab(records, 'BB'),
                  _buildChartTab(records, 'TB'),
                  _buildChartTab(records, 'LK'),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Gagal: $err')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Gagal: $err')),
      ),

    );
  }

  Widget _buildChartTab(List<dynamic> records, String mode) {
    if (records.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'Belum ada rekam data. Klik tombol + di atas untuk menambahkan.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    // Prepare line chart coordinates data mapping arrays
    List<FlSpot> spots = [];
    double maxY = 40;
    double minY = 0;
    double whoRef = 7.0;

    for (int i = 0; i < records.length; i++) {
      final r = records[i];
      double val = 0;
      if (mode == 'BB') {
        val = r.beratBadan;
        whoRef = 7.0;
        // Dynamically expand maxY so data never clips above the chart
        final dataMax = spots.isNotEmpty
            ? spots.map((s) => s.y).reduce((a, b) => a > b ? a : b)
            : 0.0;
        maxY = (dataMax > 23 ? dataMax + 3 : 25).ceilToDouble();
      } else if (mode == 'TB') {
        val = r.tinggiBadan;
        whoRef = 65.0;
        maxY = 120;
        minY = 30;
      } else if (mode == 'LK') {
        val = r.lingkarKepala ?? 0;
        whoRef = 40.0;
        maxY = 60;
        minY = 20;
      }

      spots.add(FlSpot(i.toDouble(), val));
    }

    // Final maxY check after all spots are added
    if (mode == 'BB' && spots.isNotEmpty) {
      final dataMax = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
      maxY = (dataMax > 23 ? dataMax + 3 : 25).ceilToDouble();
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Header descriptive panel cards text summaries
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
                    mode == 'BB'
                        ? '${records.last.beratBadan} kg'
                        : (mode == 'TB'
                              ? '${records.last.tinggiBadan} cm'
                              : '${records.last.lingkarKepala ?? "-"} cm'),
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

          // High Performance interactive fl_chart Line Chart curves widget implementation block
          Expanded(
            child: LineChart(
              LineChartData(
                minY: minY,
                maxY: maxY,
                gridData: const FlGridData(show: true),
                titlesData: const FlTitlesData(
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                lineBarsData: [
                  // Actual child metrics line chart plot curve values
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppColors.coral,
                    barWidth: 4,
                    dotData: const FlDotData(show: true),
                  ),
                  // WHO Standard reference overlay — lebih tebal & solid agar mudah terlihat
                  LineChartBarData(
                    spots: List.generate(
                      records.length,
                      (index) => FlSpot(index.toDouble(), whoRef),
                    ),
                    isCurved: false,
                    color: const Color(0xFF16A34A), // green-700 solid
                    barWidth: 2.5,
                    dashArray: [8, 4],
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF16A34A).withValues(alpha: 0.07),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '*Garis putus-putus hijau menunjukkan batas median referensi standar WHO',
            style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textHint),
          ),
        ],
      ),
    );
  }
}
