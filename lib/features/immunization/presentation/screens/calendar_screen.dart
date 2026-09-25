import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../widgets/app_bottom_nav_bar.dart';
import '../../../../widgets/empty_state_widget.dart';
import '../../../../widgets/error_state_widget.dart';
import '../../../../widgets/loading_overlay.dart';
import '../../../../widgets/status_badge.dart';
import '../../../../widgets/vaccine_card.dart';
import '../../../baby_profile/presentation/providers/active_baby_provider.dart';
import '../providers/immunization_provider.dart';
import '../../domain/entities/vaccine_schedule_entity.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  final DateTime? initialDate;
  const CalendarScreen({super.key, this.initialDate});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  String? _selectedFilter = 'Semua';

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  void initState() {
    super.initState();
    if (widget.initialDate != null) {
      final target = _dateOnly(widget.initialDate!);
      _focusedDay = target;
      _selectedDay = target;
      _selectedFilter = null;
    } else {
      _focusedDay = _dateOnly(DateTime.now());
      _selectedDay = null;
      _selectedFilter = 'Semua';
    }
  }

  @override
  void didUpdateWidget(covariant CalendarScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialDate != null) {
      final target = _dateOnly(widget.initialDate!);
      setState(() {
        _focusedDay = target;
        _selectedDay = target;
        _selectedFilter = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final babyAsync = ref.watch(activeBabyProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Kalender Imunisasi',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Timeline Imunisasi',
            icon: const Icon(Icons.list_alt),
            onPressed: () => context.push(AppRoutes.vaccineTimeline),
          ),
        ],
      ),
      body: babyAsync.when(
        data: (currentBaby) {
          if (currentBaby == null) {
            return EmptyStateWidget(
              icon: Icons.child_care,
              title: 'Belum ada profil anak',
              message: 'Silakan tambahkan profil anak terlebih dahulu.',
              actionLabel: 'Tambah Profil Anak',
              onAction: () => context.push(AppRoutes.addBaby),
            );
          }

          final schedulesAsync = ref.watch(
            immunizationProvider(currentBaby.babyId),
          );

          // Batasi kalender mulai dari bulan kelahiran bayi (tidak bisa digeser ke sebelum lahir)
          final firstDay = DateTime(
            currentBaby.tanggalLahir.year,
            currentBaby.tanggalLahir.month,
            1,
          );
          final lastDay = DateTime(currentBaby.tanggalLahir.year + 6, 12, 31);

          DateTime effectiveFocusedDay = _focusedDay;
          if (effectiveFocusedDay.isBefore(firstDay)) {
            effectiveFocusedDay = firstDay;
          } else if (effectiveFocusedDay.isAfter(lastDay)) {
            effectiveFocusedDay = lastDay;
          }

          return schedulesAsync.when(
            data: (schedules) {
              // Filtering logics
              final filteredSchedules = schedules.where((s) {
                // filter per hari terpilih (jika ada tanggal yang di-tap)
                if (_selectedDay != null &&
                    !isSameDay(s.tanggalTarget, _selectedDay!)) {
                  return false;
                }
                // filter status
                if (_selectedFilter == 'Terjadwal') {
                  return s.status == VaccineStatus.belum;
                }
                if (_selectedFilter == 'Selesai') {
                  return s.status == VaccineStatus.selesai;
                }
                if (_selectedFilter == 'Terlewat') {
                  return s.status == VaccineStatus.terlewat;
                }
                return true;
              }).toList();

              // Events specific day finder untuk marker kalender
              List<VaccineScheduleEntity> getEventsForDay(DateTime day) {
                return schedules
                    .where((s) => isSameDay(s.tanggalTarget, day))
                    .toList();
              }

              return Column(
                children: [
                  // Card Kalender Interaktif
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
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
                          _selectedFilter = null; // Unselect centang "Semua" saat tanggal dipilih
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
                      calendarStyle: const CalendarStyle(
                        todayDecoration: BoxDecoration(shape: BoxShape.circle),
                        todayTextStyle: TextStyle(
                          color: AppColors.darkText,
                          fontWeight: FontWeight.bold,
                        ),
                        selectedDecoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.teal,
                        ),
                        selectedTextStyle: TextStyle(
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
                                Color dotColor = AppColors.teal;
                                if (event.status == VaccineStatus.selesai) {
                                  dotColor = AppColors.green;
                                } else if (event.status ==
                                    VaccineStatus.terlewat) {
                                  dotColor = AppColors.red;
                                }
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
                    ),
                  ),

                  // Filter status chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: ['Semua', 'Terjadwal', 'Selesai', 'Terlewat']
                          .map((filter) {
                            final isSelected = filter == 'Semua'
                                ? (_selectedDay == null &&
                                      (_selectedFilter == null ||
                                          _selectedFilter == 'Semua'))
                                : (_selectedFilter == filter);
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: FilterChip(
                                label: Text(filter),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    if (filter == 'Semua') {
                                      // Pencet 'Semua' -> tampilkan seluruh jadwal
                                      _selectedDay = null;
                                      _selectedFilter = 'Semua';
                                    } else {
                                      if (isSelected) {
                                        _selectedFilter = null;
                                      } else {
                                        _selectedFilter = filter;
                                      }
                                    }
                                  });
                                },
                                selectedColor: AppColors.teal,
                                checkmarkColor: Colors.white,
                                labelStyle: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.darkText,
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
                        _selectedDay != null
                            ? 'Jadwal: ${DateFormatter.formatLong(_selectedDay!)}'
                            : (_selectedFilter != null &&
                                      _selectedFilter != 'Semua'
                                  ? 'Jadwal $_selectedFilter (${filteredSchedules.length})'
                                  : 'Semua Jadwal (${filteredSchedules.length})'),
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppColors.darkText,
                        ),
                      ),
                    ),
                  ),

                  // Daftar jadwal yang sesuai
                  Expanded(
                    child: filteredSchedules.isEmpty
                        ? EmptyStateWidget(
                            icon: Icons.event_available,
                            title: _selectedDay != null
                                ? 'Tidak ada jadwal'
                                : 'Tidak ada jadwal "$_selectedFilter"',
                            message: _selectedDay != null
                                ? 'Tidak ada jadwal pada tanggal\n'
                                      '${DateFormatter.formatLong(_selectedDay!)}'
                                : 'Coba pilih filter status atau tanggal lain.',
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            itemCount: filteredSchedules.length,
                            itemBuilder: (context, index) {
                              final item = filteredSchedules[index];
                              final warnaStatus =
                                  item.status == VaccineStatus.selesai
                                  ? AppColors.green
                                  : (item.status == VaccineStatus.terlewat
                                        ? AppColors.red
                                        : AppColors.yellow);

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
                                  textColor: item.status == VaccineStatus.belum
                                      ? AppColors.darkText
                                      : null,
                                ),
                                onTap: () => context.push(
                                  '/calendar/detail/${item.scheduleId}',
                                ),
                              );
                            },
                          ),
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
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 1),
    );
  }
}
