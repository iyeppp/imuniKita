import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../baby_profile/presentation/providers/active_baby_provider.dart';
import '../providers/immunization_provider.dart';
import '../../domain/entities/vaccine_schedule_entity.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/router/app_router.dart';
import '../../../../widgets/error_state_widget.dart';
import '../../../../widgets/loading_overlay.dart';
import '../../../../widgets/status_badge.dart';
import '../../../../widgets/vaccine_card.dart';

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
                        child: VaccineCard(
                          schedule: item,
                          margin: const EdgeInsets.only(bottom: 16),
                          trailing: StatusBadge(
                            label: '${item.usiaBulanTarget} Bln',
                            color: AppColors.teal,
                          ),
                          footer: Text(
                            'Lihat Detail ›',
                            style: GoogleFonts.poppins(
                              color: AppColors.teal,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          onTap: () => context.push(
                            '/calendar/detail/${item.scheduleId}',
                          ),
                        ),
                      ),
                    ],
                  );
                },
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
}
