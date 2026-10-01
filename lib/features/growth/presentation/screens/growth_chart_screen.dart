import 'dart:math';
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
      backgroundColor: AppColors.backgroundOf(context),
      appBar: AppBar(
        title: Text('Grafik Pertumbuhan', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.coral,
          labelColor: AppColors.darkTextOf(context),
          unselectedLabelColor: AppColors.textHintOf(context),
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

<<<<<<< Updated upstream
=======
    if (spots.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.show_chart,
        title: 'Belum ada data untuk grafik ini',
        message: 'Lingkar kepala belum pernah diisi pada pengukuran mana pun.',
      );
    }

    final maxBulan = spots.map((s) => s.x).reduce((a, b) => a > b ? a : b);

    // Kurva referensi WHO (median, −2SD, +2SD) pada rentang bulan tertentu.
    List<FlSpot> kurva(
      double? Function(double) ambil, {
      required double startBulan,
      required double endBulan,
    }) {
      final titik = <FlSpot>[];
      if (who == null) return titik;
      if (startBulan > maxBulan) return titik;
      final batas = maxBulan < endBulan ? maxBulan : endBulan;
      for (var bulan = startBulan; bulan <= batas; bulan += 1) {
        final nilai = ambil(bulan);
        if (nilai != null) titik.add(FlSpot(bulan, nilai));
      }
      return titik;
    }

    // Rentang 0–24 bulan (Warna Hijau)
    final medianSpots0To24 =
        kurva((b) => who?.medianAt(b), startBulan: 0, endBulan: 24);
    final minus2Spots0To24 =
        kurva((b) => who?.minus2SdAt(b), startBulan: 0, endBulan: 24);
    final plus2Spots0To24 =
        kurva((b) => who?.plus2SdAt(b), startBulan: 0, endBulan: 24);

    // Rentang >24–60 bulan (Warna Biru)
    final medianSpots24To60 =
        kurva((b) => who?.medianAt(b), startBulan: 24, endBulan: 60);
    final minus2Spots24To60 =
        kurva((b) => who?.minus2SdAt(b), startBulan: 24, endBulan: 60);
    final plus2Spots24To60 =
        kurva((b) => who?.plus2SdAt(b), startBulan: 24, endBulan: 60);

    final semuaNilai = [
      ...spots.map((s) => s.y),
      ...medianSpots0To24.map((s) => s.y),
      ...minus2Spots0To24.map((s) => s.y),
      ...plus2Spots0To24.map((s) => s.y),
      ...medianSpots24To60.map((s) => s.y),
      ...minus2Spots24To60.map((s) => s.y),
      ...plus2Spots24To60.map((s) => s.y),
    ];
    final nilaiMin = semuaNilai.reduce((a, b) => a < b ? a : b);
    final nilaiMax = semuaNilai.reduce((a, b) => a > b ? a : b);
    final rentang = (nilaiMax - nilaiMin).abs();
    final margin = rentang < 5 ? 1.0 : rentang * 0.15;

    const warnaWho0To24 = Color(0xFF16A34A); // green-700
    const warnaWhoAbove24 = Color(0xFF2563EB); // blue-600
    final modeLabel = who?.label ?? mode;
    final unit = who?.unit ?? '';

>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
                titlesData: const FlTitlesData(
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
=======
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    axisNameWidget: Text(
                      ' $modeLabel ($unit)',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: AppColors.textHintOf(context),
                      ),
                    ),
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 48,
                      interval: _niceInterval(nilaiMin - margin, nilaiMax + margin, 5),
                      getTitlesWidget: (value, meta) {
                        // Skip min/max edge labels to prevent clipping
                        if (value == meta.min || value == meta.max) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(
                            value.toStringAsFixed(1),
                            style: GoogleFonts.poppins(
                              fontSize: 9.5,
                              color: AppColors.textHintOf(context),
                            ),
                            textAlign: TextAlign.right,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    axisNameWidget: Text(
                      'usia (bulan)',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: AppColors.textHintOf(context),
                      ),
                    ),
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: _niceInterval(0, maxBulan < 1 ? 1 : maxBulan, 6),
                      getTitlesWidget: (value, meta) {
                        if (value == meta.min || value == meta.max) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            value.toInt().toString(),
                            style: GoogleFonts.poppins(
                              fontSize: 9.5,
                              color: AppColors.textHintOf(context),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: AppColors.borderOf(context), width: 1),
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
                  // WHO Standard reference standard overlay lines implementation markers
                  LineChartBarData(
                    spots: List.generate(records.length, (index) => FlSpot(index.toDouble(), mode == 'BB' ? 7.0 : (mode == 'TB' ? 65.0 : 40.0))),
                    isCurved: false,
                    color: Colors.green.withValues(alpha: 0.5),
                    barWidth: 2,
                    dashArray: [5, 5],
                    dotData: const FlDotData(show: false),
                  ),
=======
                  // Median WHO (0-24 bulan)
                  if (medianSpots0To24.isNotEmpty)
                    LineChartBarData(
                      spots: medianSpots0To24,
                      isCurved: true,
                      color: warnaWho0To24,
                      barWidth: 2.5,
                      dotData: const FlDotData(show: false),
                    ),
                  // −2SD WHO (0-24 bulan)
                  if (minus2Spots0To24.isNotEmpty)
                    LineChartBarData(
                      spots: minus2Spots0To24,
                      isCurved: true,
                      color: warnaWho0To24.withValues(alpha: 0.55),
                      barWidth: 1.5,
                      dashArray: [6, 4],
                      dotData: const FlDotData(show: false),
                    ),
                  // +2SD WHO (0-24 bulan)
                  if (plus2Spots0To24.isNotEmpty)
                    LineChartBarData(
                      spots: plus2Spots0To24,
                      isCurved: true,
                      color: warnaWho0To24.withValues(alpha: 0.55),
                      barWidth: 1.5,
                      dashArray: [6, 4],
                      dotData: const FlDotData(show: false),
                    ),
                  // Median WHO (>24 bulan)
                  if (medianSpots24To60.isNotEmpty)
                    LineChartBarData(
                      spots: medianSpots24To60,
                      isCurved: true,
                      color: warnaWhoAbove24,
                      barWidth: 2.5,
                      dotData: const FlDotData(show: false),
                    ),
                  // −2SD WHO (>24 bulan)
                  if (minus2Spots24To60.isNotEmpty)
                    LineChartBarData(
                      spots: minus2Spots24To60,
                      isCurved: true,
                      color: warnaWhoAbove24.withValues(alpha: 0.55),
                      barWidth: 1.5,
                      dashArray: [6, 4],
                      dotData: const FlDotData(show: false),
                    ),
                  // +2SD WHO (>24 bulan)
                  if (plus2Spots24To60.isNotEmpty)
                    LineChartBarData(
                      spots: plus2Spots24To60,
                      isCurved: true,
                      color: warnaWhoAbove24.withValues(alpha: 0.55),
                      barWidth: 1.5,
                      dashArray: [6, 4],
                      dotData: const FlDotData(show: false),
                    ),
>>>>>>> Stashed changes
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
<<<<<<< Updated upstream
          Text('*Garis putus-putus hijau menunjukkan batas median referensi standar WHO', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textHint)),
=======
          Text(
            '*Garis hijau = referensi WHO 0–24 bulan, garis biru = referensi WHO >24 bulan (median, −2SD, +2SD, '
            '${isLakiLaki ? 'laki-laki' : 'perempuan'}) — indikatif, bukan diagnosis.',
            style: GoogleFonts.poppins(
              fontSize: 10.5,
              color: AppColors.textHintOf(context),
            ),
          ),
>>>>>>> Stashed changes
        ],
      ),
    );
  }

  /// Hitung interval "rapi" agar sumbu menghasilkan paling banyak [maxTicks] label.
  double _niceInterval(double minVal, double maxVal, int maxTicks) {
    final range = (maxVal - minVal).abs();
    if (range == 0) return 1;
    final rawInterval = range / maxTicks;
    // Bulatkan ke nilai "bersih": 0.5, 1, 2, 5, 10, 20, ...
    final magnitude = pow(10, (log(rawInterval) / ln10).floor()).toDouble();
    final normalized = rawInterval / magnitude;
    double nice;
    if (normalized < 1.5) {
      nice = 1;
    } else if (normalized < 3.5) {
      nice = 2;
    } else if (normalized < 7.5) {
      nice = 5;
    } else {
      nice = 10;
    }
    return nice * magnitude;
  }
}
