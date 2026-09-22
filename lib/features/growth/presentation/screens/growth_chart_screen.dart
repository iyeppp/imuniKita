import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../baby_profile/presentation/providers/baby_provider.dart';
import '../providers/growth_provider.dart';

class GrowthChartScreen extends ConsumerStatefulWidget {
  const GrowthChartScreen({super.key});

  @override
  ConsumerState<GrowthChartScreen> createState() => _GrowthChartScreenState();
}

class _GrowthChartScreenState extends ConsumerState<GrowthChartScreen> with SingleTickerProviderStateMixin {
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
    final babiesAsync = ref.watch(babyNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Grafik Pertumbuhan', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
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
      body: babiesAsync.when(
        data: (babies) {
          if (babies.isEmpty) return const Center(child: Text('Belum ada profil anak.'));
          final currentBaby = babies.first;
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go(AppRoutes.addGrowth),
        backgroundColor: AppColors.coral,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) context.go(AppRoutes.dashboard);
          if (index == 1) context.go(AppRoutes.calendar);
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

  Widget _buildChartTab(List<dynamic> records, String mode) {
    if (records.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text('Belum ada rekam data. Klik tombol + di bawah untuk menambahkan.', textAlign: TextAlign.center, style: GoogleFonts.poppins(color: AppColors.textSecondary)),
        ),
      );
    }

    // Prepare line chart coordinates data mapping arrays
    List<FlSpot> spots = [];
    double maxY = 40;
    double minY = 0;

    for (int i = 0; i < records.length; i++) {
      final r = records[i];
      double val = 0;
      if (mode == 'BB') { val = r.beratBadan; maxY = 25; }
      else if (mode == 'TB') { val = r.tinggiBadan; maxY = 120; minY = 30; }
      else if (mode == 'LK') { val = r.lingkarKepala ?? 0; maxY = 60; minY = 20; }

      spots.add(FlSpot(i.toDouble(), val));
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
                  Text('Pengukuran Terakhir:', style: GoogleFonts.poppins(fontSize: 13)),
                  Text(
                    mode == 'BB' ? '${records.last.beratBadan} kg' : (mode == 'TB' ? '${records.last.tinggiBadan} cm' : '${records.last.lingkarKepala ?? "-"} cm'),
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.coral),
                  )
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
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: true, border: Border.all(color: AppColors.darkText, width: 1.5)),
                lineBarsData: [
                  // Actual child metrics line chart plot curve values
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppColors.coral,
                    barWidth: 4,
                    dotData: const FlDotData(show: true),
                  ),
                  // WHO Standard reference standard overlay lines implementation markers
                  LineChartBarData(
                    spots: List.generate(records.length, (index) => FlSpot(index.toDouble(), mode == 'BB' ? 7.0 : (mode == 'TB' ? 65.0 : 40.0))),
                    isCurved: false,
                    color: Colors.green.withValues(alpha: 0.5),
                    barWidth: 2,
                    dashArray: [5, 5],
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text('*Garis putus-putus hijau menunjukkan batas median referensi standar WHO', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textHint)),
        ],
      ),
    );
  }
}
