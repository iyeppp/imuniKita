import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../baby_profile/presentation/providers/baby_provider.dart';
import '../providers/immunization_provider.dart';
import '../../domain/entities/vaccine_schedule_entity.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String _selectedFilter = 'Semua';

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final babiesAsync = ref.watch(babyNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Kalender Imunisasi', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt),
            onPressed: () => context.go(AppRoutes.vaccineTimeline),
          )
        ],
      ),
      body: babiesAsync.when(
        data: (babies) {
          if (babies.isEmpty) {
            return const Center(child: Text('Silakan tambahkan profil anak terlebih dahulu.'));
          }
          final currentBaby = babies.first;
          final schedulesAsync = ref.watch(immunizationProvider(currentBaby.babyId));

          return schedulesAsync.when(
            data: (schedules) {
              // Filtering logics
              final filteredSchedules = schedules.where((s) {
                if (_selectedFilter == 'Terjadwal') return s.status == VaccineStatus.belum;
                if (_selectedFilter == 'Selesai') return s.status == VaccineStatus.selesai;
                if (_selectedFilter == 'Terlewat') return s.status == VaccineStatus.terlewat;
                return true;
              }).toList();

              // Events specific day finder
              List<VaccineScheduleEntity> getEventsForDay(DateTime day) {
                return schedules.where((s) => isSameDay(s.tanggalTarget, day)).toList();
              }

              return Column(
                children: [
                  // Table Calendar Widget Integration
                  TableCalendar<VaccineScheduleEntity>(
                    firstDay: DateTime.now().subtract(const Duration(days: 365)),
                    lastDay: DateTime.now().add(const Duration(days: 1825)),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    eventLoader: getEventsForDay,
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    onFormatChanged: (format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },
                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (context, date, events) {
                        if (events.isEmpty) return const SizedBox();
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: events.map((event) {
                            Color dotColor = AppColors.teal;
                            if (event.status == VaccineStatus.selesai) dotColor = AppColors.green;
                            if (event.status == VaccineStatus.terlewat) dotColor = AppColors.red;
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 1),
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Filter Chips list representation
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: ['Semua', 'Terjadwal', 'Selesai', 'Terlewat'].map((filter) {
                        final isSelected = _selectedFilter == filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: FilterChip(
                            label: Text(filter),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedFilter = filter;
                              });
                            },
                            selectedColor: AppColors.teal,
                            checkmarkColor: Colors.white,
                            labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.darkText),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Display records corresponding to selected values
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: filteredSchedules.length,
                      itemBuilder: (context, index) {
                        final item = filteredSchedules[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            title: Text(item.namaVaksin, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                            subtitle: Text('Target: ${item.usiaBulanTarget} Bulan'),
                            trailing: Chip(
                              label: Text(item.status),
                              backgroundColor: item.status == VaccineStatus.selesai 
                                  ? AppColors.green.withValues(alpha: 0.2) 
                                  : (item.status == VaccineStatus.terlewat ? AppColors.red.withValues(alpha: 0.2) : AppColors.teal.withValues(alpha: 0.2)),
                            ),
                            onTap: () => context.go('/calendar/detail/${item.scheduleId}'),
                          ),
                        );
                      },
                    ),
                  ),
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) context.go(AppRoutes.dashboard);
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
}
