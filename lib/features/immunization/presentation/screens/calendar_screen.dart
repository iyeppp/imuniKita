import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../baby_profile/presentation/providers/baby_provider.dart';
import '../providers/immunization_provider.dart';
import '../../data/models/vaccine_schedule_model.dart';

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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) context.go(AppRoutes.dashboard);
      },
      child: Scaffold(
      backgroundColor: AppColors.backgroundOf(context),
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
                if (_selectedFilter == 'Terjadwal') return s.status == 'BELUM';
                if (_selectedFilter == 'Selesai') return s.status == 'SELESAI';
                if (_selectedFilter == 'Terlewat') return s.status == 'TERLEWAT';
                return true;
              }).toList();

              // Events specific day finder
              List<VaccineScheduleModel> getEventsForDay(DateTime day) {
                return schedules.where((s) => isSameDay(s.tanggalTarget, day)).toList();
              }

              return Column(
                children: [
<<<<<<< Updated upstream
                  // Table Calendar Widget Integration
                  TableCalendar<VaccineScheduleModel>(
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
                            if (event.status == 'SELESAI') dotColor = AppColors.green;
                            if (event.status == 'TERLEWAT') dotColor = AppColors.red;
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 1),
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor),
                            );
                          }).toList(),
                        );
                      },
=======
                  // Card Kalender Interaktif
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceOf(context),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderOf(context)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TableCalendar<VaccineScheduleEntity>(
                      key: ValueKey(
                        '${effectiveFocusedDay.year}-${effectiveFocusedDay.month}',
                      ),
                      firstDay: firstDay,
                      lastDay: lastDay,
                      focusedDay: effectiveFocusedDay,
                      calendarFormat: _calendarFormat,
                      rowHeight: 42,
                      daysOfWeekHeight: 20,
                      selectedDayPredicate: (day) =>
                          _selectedDay != null && isSameDay(_selectedDay, day),
                      eventLoader: getEventsForDay,
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _selectedFilter = 'Semua';
                          _focusedDay = focusedDay;
                        });
                      },
                      onFormatChanged: (format) {
                        setState(() {
                          _calendarFormat = format;
                        });
                      },
                      onPageChanged: (focusedDay) {
                        setState(() {
                          _focusedDay = focusedDay;
                        });
                      },
                      headerStyle: HeaderStyle(
                        titleCentered: true,
                        formatButtonVisible: false,
                        titleTextStyle: GoogleFonts.baloo2(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.teal,
                        ),
                        leftChevronIcon: const Icon(
                          Icons.chevron_left,
                          color: AppColors.teal,
                        ),
                        rightChevronIcon: const Icon(
                          Icons.chevron_right,
                          color: AppColors.teal,
                        ),
                      ),
                      calendarStyle: CalendarStyle(
                        todayDecoration: const BoxDecoration(shape: BoxShape.circle),
                        todayTextStyle: TextStyle(
                          color: AppColors.textPrimaryOf(context),
                          fontWeight: FontWeight.bold,
                        ),
                        defaultTextStyle: TextStyle(
                          color: AppColors.textPrimaryOf(context),
                        ),
                        weekendTextStyle: TextStyle(
                          color: AppColors.textPrimaryOf(context),
                        ),
                        outsideTextStyle: TextStyle(
                          color: AppColors.textSecondaryOf(context),
                        ),
                        selectedDecoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.teal,
                        ),
                        selectedTextStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      calendarBuilders: CalendarBuilders(
                        markerBuilder: (context, date, events) {
                          if (events.isEmpty) return const SizedBox();
                          return Positioned(
                            bottom: 2,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: events.take(4).map((event) {
                                final dotColor = VaccineStatusStyle.color(
                                  event.status,
                                );
                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 1.5,
                                  ),
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: dotColor,
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        },
                      ),
>>>>>>> Stashed changes
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Filter Chips list representation
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
<<<<<<< Updated upstream
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
=======
                      children: ['Semua', 'Terjadwal', 'Selesai', 'Terlewat']
                          .map((filter) {
                            final isSelected = filter == 'Semua'
                                ? (_selectedFilter == 'Semua' && _selectedDay == null)
                                : (_selectedFilter == filter);
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: FilterChip(
                                label: Text(filter),
                                selected: isSelected,
                                onSelected: (_) {
                                  setState(() {
                                    _selectedDay = null;
                                    _selectedFilter =
                                        (filter == 'Semua' || isSelected)
                                            ? 'Semua'
                                            : filter;
                                  });
                                },
                                selectedColor: AppColors.teal,
                                checkmarkColor: Colors.white,
                                labelStyle: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.darkTextOf(context),
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            );
                          })
                          .toList(),
                    ),
                  ),

                  // Info Tanggal Jadwal
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _selectedFilter != 'Semua'
                            ? 'Jadwal $_selectedFilter (${filteredSchedules.length})'
                            : (_selectedDay != null
                                ? 'Jadwal: ${DateFormatter.formatLong(_selectedDay!)}'
                                : 'Semua Jadwal (${filteredSchedules.length})'),
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppColors.darkTextOf(context),
                        ),
                      ),
                    ),
                  ),

                  // Daftar jadwal yang sesuai
                  Expanded(
                    child: filteredSchedules.isEmpty
                        ? EmptyStateWidget(
                            icon: Icons.event_available,
                            title: _selectedFilter != 'Semua'
                                ? 'Tidak ada jadwal "$_selectedFilter"'
                                : 'Tidak ada jadwal',
                            message: _selectedFilter != 'Semua'
                                ? 'Coba pilih filter status atau tanggal lain.'
                                : (_selectedDay != null
                                    ? 'Tidak ada jadwal pada tanggal\n${DateFormatter.formatLong(_selectedDay!)}'
                                    : 'Belum ada data jadwal imunisasi.'),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            itemCount: filteredSchedules.length,
                            itemBuilder: (context, index) {
                              final item = filteredSchedules[index];
                              final warnaStatus = VaccineStatusStyle.color(
                                item.status,
                              );

                              return VaccineCard(
                                schedule: item,
                                compact: true,
                                showDescription: false,
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                backgroundColor: warnaStatus.withValues(
                                  alpha: 0.12,
                                ),
                                trailing: StatusBadge(
                                  label: item.status,
                                  color: warnaStatus,
                                  compact: true,
                                ),
                                onTap: () => context.push(
                                  '/calendar/detail/${item.scheduleId}',
                                ),
                              );
>>>>>>> Stashed changes
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
                              backgroundColor: item.status == 'SELESAI' 
                                  ? AppColors.green.withValues(alpha: 0.2) 
                                  : (item.status == 'TERLEWAT' ? AppColors.red.withValues(alpha: 0.2) : AppColors.teal.withValues(alpha: 0.2)),
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
<<<<<<< Updated upstream
=======
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 1),
      ),
>>>>>>> Stashed changes
    );
  }
}
