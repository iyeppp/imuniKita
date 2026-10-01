import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../baby_profile/presentation/providers/baby_provider.dart';
import '../providers/journal_provider.dart';

class JournalListScreen extends ConsumerWidget {
  const JournalListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final babiesAsync = ref.watch(babyNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundOf(context),
      appBar: AppBar(
<<<<<<< Updated upstream
        title: Text('Jurnal Kesehatan', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
=======
        leading: IconButton(
          tooltip: 'Kembali',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go(AppRoutes.dashboard),
        ),
        title: Text(
          'Jurnal Kesehatan',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              tooltip: 'Tambah Jurnal',
              style: IconButton.styleFrom(
                backgroundColor: AppColors.coral,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.add, size: 22),
              onPressed: () => context.push(AppRoutes.addJournal),
            ),
          ),
        ],
>>>>>>> Stashed changes
      ),
      body: babiesAsync.when(
        data: (babies) {
          if (babies.isEmpty) return const Center(child: Text('Belum ada profil anak.'));
          final currentBaby = babies.first;
          final journalsAsync = ref.watch(journalProvider(currentBaby.babyId));

          return journalsAsync.when(
            data: (journals) {
              if (journals.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text('Belum ada catatan jurnal harian anak. Klik tombol + di bawah.', textAlign: TextAlign.center, style: GoogleFonts.poppins(color: AppColors.textSecondary)),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: journals.length,
                itemBuilder: (context, index) {
                  final item = journals[index];

                  // Swipe to dismiss and delete functionality wrap
                  return Dismissible(
                    key: Key(item.journalId),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      color: AppColors.red,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) async {
                      await ref.read(journalProvider(currentBaby.babyId).notifier).deleteJournal(item.journalId);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Catatan jurnal berhasil dihapus.')),
                        );
                      }
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${item.tanggalCatatan.day}/${item.tanggalCatatan.month}/${item.tanggalCatatan.year}',
<<<<<<< Updated upstream
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textSecondary),
                                ),
                                if (item.suhuTubuh != null)
                                  Chip(
                                    label: Text('${item.suhuTubuh}°C'),
                                    backgroundColor: item.suhuTubuh! >= 37.5 ? AppColors.red.withValues(alpha: 0.15) : AppColors.teal.withValues(alpha: 0.15),
                                  )
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(item.isiCatatan, style: GoogleFonts.poppins(fontSize: 14, color: AppColors.darkText)),
=======
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: AppColors.textSecondaryOf(context),
                                  ),
                                ),
                                if (item.suhuTubuh != null)
                                  StatusBadge(
                                    label: '${item.suhuTubuh}°C',
                                    color: item.suhuTubuh! >= 37.5
                                        ? AppColors.red
                                        : AppColors.teal,
                                    compact: true,
                                    textColor: AppColors.darkTextOf(context),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item.isiCatatan,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: AppColors.darkTextOf(context),
                              ),
                            ),
>>>>>>> Stashed changes
                            if (item.gejala.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
<<<<<<< Updated upstream
                                children: item.gejala.map((g) => Chip(
                                  label: Text(g, style: const TextStyle(fontSize: 11)),
                                  padding: EdgeInsets.zero,
                                )).toList(),
                              )
                            ]
=======
                                children: item.gejala
                                    .map(
                                      (g) => StatusBadge(
                                        label: g,
                                        color: AppColors.teal,
                                        compact: true,
                                        style: StatusBadgeStyle.soft,
                                        textColor: AppColors.darkTextOf(context),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ],
>>>>>>> Stashed changes
                          ],
                        ),
                      ),
                    ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go(AppRoutes.addJournal),
        backgroundColor: AppColors.yellow,
        child: const Icon(Icons.add, color: AppColors.darkText),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        onTap: (index) {
          if (index == 0) context.go(AppRoutes.dashboard);
          if (index == 1) context.go(AppRoutes.calendar);
          if (index == 2) context.go(AppRoutes.growth);
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
