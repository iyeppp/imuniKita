import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../baby_profile/presentation/providers/active_baby_provider.dart';
import '../providers/immunization_provider.dart';
import '../../domain/entities/vaccine_schedule_entity.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/router/app_router.dart';

class VaccineTimelineScreen extends ConsumerWidget {
  const VaccineTimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final babyAsync = ref.watch(activeBabyProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Kembali',
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(AppRoutes.calendar),
        ),
        title: Text(
          'Timeline Imunisasi',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      body: babyAsync.when(
        data: (currentBaby) {
          if (currentBaby == null) {
            return const Center(child: Text('Belum ada profil anak.'));
          }
          final schedulesAsync = ref.watch(
            immunizationProvider(currentBaby.babyId),
          );

          return schedulesAsync.when(
            data: (schedules) {
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: schedules.length,
                itemBuilder: (context, index) {
                  final item = schedules[index];
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sequential Vertical Line Representation
                      Column(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor:
                                item.status == VaccineStatus.selesai
                                ? AppColors.green
                                : (item.status == VaccineStatus.terlewat
                                    ? AppColors.red
                                    : AppColors.teal),
                            child: Icon(
                              item.status == VaccineStatus.selesai
                                  ? Icons.check
                                  : (item.status == VaccineStatus.terlewat
                                      ? Icons.close
                                      : Icons.radio_button_unchecked),
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                          if (index != schedules.length - 1)
                            Container(
                              width: 2,
                              height: 60,
                              color: AppColors.grey.withValues(alpha: 0.4),
                            ),
                        ],
                      ),
                      const SizedBox(width: 16),

                      // Card item data content panel
                      Expanded(
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.namaVaksin,
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.teal.withValues(
                                          alpha: 0.15,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: AppColors.teal.withValues(
                                            alpha: 0.3,
                                          ),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        '${item.usiaBulanTarget} Bln',
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.deskripsi,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: () => context.push(
                                    '/calendar/detail/${item.scheduleId}',
                                  ),
                                  child: Text(
                                    'Lihat Detail ›',
                                    style: GoogleFonts.poppins(
                                      color: AppColors.teal,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
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
}
