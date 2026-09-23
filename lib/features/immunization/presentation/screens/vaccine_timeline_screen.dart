import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../baby_profile/presentation/providers/active_baby_provider.dart';
import '../providers/immunization_provider.dart';
import '../../domain/entities/vaccine_schedule_entity.dart';
import '../../../../app/theme/app_colors.dart';

class VaccineTimelineScreen extends ConsumerWidget {
  const VaccineTimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final babyAsync = ref.watch(activeBabyProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Timeline Imunisasi', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
      ),
      body: babyAsync.when(
        data: (currentBaby) {
          if (currentBaby == null) return const Center(child: Text('Belum ada profil anak.'));
          final schedulesAsync = ref.watch(immunizationProvider(currentBaby.babyId));

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
                            backgroundColor: item.status == VaccineStatus.selesai ? AppColors.green : AppColors.teal,
                            child: Icon(
                              item.status == VaccineStatus.selesai ? Icons.check : Icons.radio_button_unchecked,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                          if (index != schedules.length - 1)
                            Container(width: 2, height: 60, color: AppColors.grey.withValues(alpha: 0.4)),
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
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      item.namaVaksin,
                                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    Chip(
                                      label: Text('${item.usiaBulanTarget} Bln'),
                                      labelStyle: const TextStyle(fontSize: 10),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(item.deskripsi, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: () => context.go('/calendar/detail/${item.scheduleId}'),
                                  child: Text(
                                    'Lihat Detail ›',
                                    style: GoogleFonts.poppins(color: AppColors.teal, fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      )
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
