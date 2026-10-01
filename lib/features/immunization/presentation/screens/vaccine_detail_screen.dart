import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:hive_ce/hive_ce.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/immunization_provider.dart';
import '../../data/models/vaccine_schedule_model.dart';
import '../../../health_journal/data/models/health_journal_model.dart';
import '../../../health_journal/presentation/providers/journal_provider.dart';

class VaccineDetailScreen extends ConsumerStatefulWidget {
  final String scheduleId;
  const VaccineDetailScreen({super.key, required this.scheduleId});

  @override
  ConsumerState<VaccineDetailScreen> createState() => _VaccineDetailScreenState();
}

class _VaccineDetailScreenState extends ConsumerState<VaccineDetailScreen> {
  final _kipiFormKey = GlobalKey<FormState>();
  final TextEditingController _suhuController = TextEditingController();
  final TextEditingController _catatanController = TextEditingController();
  final List<String> _selectedGejala = [];

  final List<String> _daftarGejala = ['Demam', 'Bengkak', 'Rewel', 'Muntah', 'Ruam Merah'];

  @override
  void dispose() {
    _suhuController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _submitKipi(VaccineScheduleModel schedule) async {
    if (!_kipiFormKey.currentState!.validate()) return;

    final suhu = double.tryParse(_suhuController.text);
    
    // 1. Update Immunization Database block values notes
    await ref.read(immunizationProvider(schedule.babyId).notifier).updateStatus(
      widget.scheduleId,
      'SELESAI',
      realisasiDate: DateTime.now(),
      reaksi: _catatanController.text.trim(),
    );

    // 2. Automatically link inside Health Journal block database
    final journalId = const Uuid().v4();
    final newJournal = HealthJournalModel(
      journalId: journalId,
      babyId: schedule.babyId,
      vaccineScheduleId: widget.scheduleId,
      tanggalCatatan: DateTime.now(),
      isiCatatan: 'Pasca Vaksinasi ${schedule.namaVaksin}: ${_catatanController.text.trim()}',
      suhuTubuh: suhu,
      gejala: List.from(_selectedGejala),
    );

    await ref.read(journalProvider(schedule.babyId).notifier).addJournal(newJournal);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status diperbarui dan dicatat ke Jurnal Sehat! ✅'), backgroundColor: AppColors.green),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Search record matches by scheduleId directly
    return Scaffold(
<<<<<<< Updated upstream
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Detail Imunisasi', style: GoogleFonts.poppins(fontWeight: FontWeight.bold))),
      body: FutureBuilder<Box<VaccineScheduleModel>>(
        future: Hive.openBox<VaccineScheduleModel>(AppConstants.vaccineSchedulesBox),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final box = snapshot.data!;
          final item = box.get(widget.scheduleId);
=======
      backgroundColor: AppColors.backgroundOf(context),
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Kembali',
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(AppRoutes.calendar),
        ),
        title: Text(
          'Detail Imunisasi',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      body: LoadingOverlay(
        isLoading: _menyimpan,
        message: 'Menyimpan perubahan…',
        child: jadwalAsync.when(
          data: (item) {
            if (item == null) {
              return const EmptyStateWidget(
                icon: Icons.event_busy,
                title: 'Jadwal tidak ditemukan',
                message: 'Jadwal imunisasi yang kamu cari tidak tersedia.',
              );
            }
>>>>>>> Stashed changes

          if (item == null) return const Center(child: Text('Jadwal tidak ditemukan.'));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info block
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(item.namaVaksin, style: GoogleFonts.baloo2(fontSize: 24, fontWeight: FontWeight.bold)),
                            Chip(label: Text(item.status)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Target Pengambilan: Usia ${item.usiaBulanTarget} Bulan', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 8),
                        Text(item.deskripsi, style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Form toggle checklist update action button triggers
                if (item.status != 'SELESAI') ...[
                  Text('Tandai Sudah Diberikan & Catat Efek Samping (KIPI)', style: GoogleFonts.baloo2(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _kipiFormKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              controller: _suhuController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Suhu Tubuh (°C) - Opsional', hintText: 'Contoh: 37.5'),
                            ),
<<<<<<< Updated upstream
                            const SizedBox(height: 16),
                            Text('Gejala yang Timbul:', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 8,
                              children: _daftarGejala.map((gejala) {
                                final isSelected = _selectedGejala.contains(gejala);
                                return ChoiceChip(
                                  label: Text(gejala),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        _selectedGejala.add(gejala);
                                      } else {
                                        _selectedGejala.remove(gejala);
                                      }
                                    });
                                  },
                                );
                              }).toList(),
=======
                          ),
                          const SizedBox(height: 4),
                          // Tanggal target -- Fix checklist #3.3
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_outlined,
                                size: 14,
                                color: AppColors.teal,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Tanggal Target: ${item.tanggalTarget.day}/${item.tanggalTarget.month}/${item.tanggalTarget.year}',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: AppColors.teal,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.deskripsi,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: AppColors.textSecondaryOf(context),
>>>>>>> Stashed changes
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _catatanController,
                              maxLines: 3,
                              decoration: const InputDecoration(labelText: 'Catatan Reaksi / Kondisi Anak', hintText: 'Tulis reaksi pasca imunisasi di sini...'),
                              validator: (value) => value == null || value.trim().isEmpty ? 'Catatan kondisi wajib diisi' : null,
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () => _submitKipi(item),
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.teal),
                              child: const Text('Simpan & Selesaikan Imunisasi'),
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                ] else ...[
                  Card(
                    color: AppColors.green.withValues(alpha: 0.1),
                    child: const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: AppColors.green, size: 28),
                          SizedBox(width: 12),
                          Text('Imunisasi ini telah berhasil diselesaikan dan dicatat. ✓'),
                        ],
                      ),
                    ),
<<<<<<< Updated upstream
                  )
                ]
              ],
            ),
          );
        },
=======
                  ),
                  const SizedBox(height: 20),

                  // Form KIPI — hanya untuk jadwal yang belum selesai.
                  if (item.status != VaccineStatus.selesai) ...[
                    const SectionHeader(
                      title:
                          'Tandai Sudah Diberikan & Catat Efek Samping (KIPI)',
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Form(
                          key: _kipiFormKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              CustomTextField(
                                label: 'Suhu Tubuh (°C) - Opsional',
                                controller: _suhuController,
                                hint: 'Contoh: 37.5',
                                keyboardType: TextInputType.number,
                                enabled: !_menyimpan,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Gejala yang Timbul:',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 8,
                                children: _daftarGejala.map((gejala) {
                                  final isSelected = _selectedGejala.contains(
                                    gejala,
                                  );
                                  return ChoiceChip(
                                    label: Text(gejala),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      setState(() {
                                        if (selected) {
                                          _selectedGejala.add(gejala);
                                        } else {
                                          _selectedGejala.remove(gejala);
                                        }
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 16),
                              CustomTextField(
                                label: 'Catatan Reaksi / Kondisi Anak',
                                controller: _catatanController,
                                hint: 'Tulis reaksi pasca imunisasi di sini...',
                                maxLines: 3,
                                enabled: !_menyimpan,
                                validator: (value) =>
                                    value == null || value.trim().isEmpty
                                    ? 'Catatan kondisi wajib diisi'
                                    : null,
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () => _submitKipi(item),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.teal,
                                ),
                                child: const Text(
                                  'Simpan & Selesaikan Imunisasi',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    Card(
                      color: AppColors.green.withValues(alpha: 0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: AppColors.green,
                                  size: 28,
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Imunisasi ini telah berhasil diselesaikan. ✓',
                                  ),
                                ),
                              ],
                            ),
                            if (item.tanggalRealisasi != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Tanggal diberikan: ${item.tanggalRealisasi!.day}/${item.tanggalRealisasi!.month}/${item.tanggalRealisasi!.year}',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: AppColors.textSecondaryOf(context),
                                ),
                              ),
                            ],
                            if (item.catatanReaksi != null &&
                                item.catatanReaksi!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Catatan: ${item.catatanReaksi}',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: AppColors.textSecondaryOf(context),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
          loading: () => const AppLoadingIndicator(),
          error: (err, _) =>
              ErrorStateWidget(message: 'Gagal memuat jadwal: $err'),
        ),
>>>>>>> Stashed changes
      ),
    );
  }
}
