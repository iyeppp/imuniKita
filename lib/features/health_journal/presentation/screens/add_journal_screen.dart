import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/health_gejala.dart';
import '../../../../widgets/custom_text_field.dart';
import '../../../../widgets/empty_state_widget.dart';
import '../../../../widgets/error_state_widget.dart';
import '../../../../widgets/loading_overlay.dart';
import '../../../baby_profile/presentation/providers/active_baby_provider.dart';
import '../providers/journal_provider.dart';
import '../../domain/entities/health_journal_entity.dart';

class AddJournalScreen extends ConsumerStatefulWidget {
  const AddJournalScreen({super.key});

  @override
  ConsumerState<AddJournalScreen> createState() => _AddJournalScreenState();
}

class _AddJournalScreenState extends ConsumerState<AddJournalScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _catatanController = TextEditingController();
  final TextEditingController _suhuController = TextEditingController();
  DateTime _tanggalCatatan = DateTime.now();
  final List<String> _selectedGejala = [];
  bool _menyimpan = false;

  final List<String> _daftarGejala = HealthGejala.daftar;

  @override
  void dispose() {
    _catatanController.dispose();
    _suhuController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _tanggalCatatan,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _tanggalCatatan) {
      if (!mounted) return;
      setState(() {
        _tanggalCatatan = picked;
      });
    }
  }

  Future<void> _saveJournal(String babyId) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _menyimpan = true);

    final suhu = double.tryParse(_suhuController.text);

    final journal = HealthJournalEntity(
      journalId: const Uuid().v4(),
      babyId: babyId,
      tanggalCatatan: _tanggalCatatan,
      isiCatatan: _catatanController.text.trim(),
      suhuTubuh: suhu,
      gejala: List.from(_selectedGejala),
    );

    try {
      await ref.read(journalProvider(babyId).notifier).addJournal(journal);

      if (!mounted) return;
      setState(() => _menyimpan = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Catatan jurnal kesehatan berhasil disimpan! 📝'),
          backgroundColor: AppColors.green,
        ),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _menyimpan = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan catatan jurnal: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final babyAsync = ref.watch(activeBabyProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Kembali',
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(AppRoutes.journal),
        ),
        title: Text(
          'Tambah Jurnal Sehat',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      body: babyAsync.when(
        data: (currentBaby) {
          if (currentBaby == null) {
            return EmptyStateWidget(
              icon: Icons.child_care,
              title: 'Belum ada profil anak',
              message: 'Tambahkan profil anak sebelum mencatat jurnal.',
              actionLabel: 'Tambah Profil Anak',
              onAction: () => context.push(AppRoutes.addBaby),
            );
          }

          return LoadingOverlay(
            isLoading: _menyimpan,
            message: 'Menyimpan catatan…',
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ListTile(
                          title: Text(
                            'Tanggal Kejadian:',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            '${_tanggalCatatan.day}/${_tanggalCatatan.month}/${_tanggalCatatan.year}',
                          ),
                          trailing: const Icon(
                            Icons.calendar_today,
                            color: AppColors.yellow,
                          ),
                          onTap: () => _selectDate(context),
                        ),
                        const Divider(),
                        const SizedBox(height: 16),

                        CustomTextField(
                          label: 'Suhu Tubuh (°C) - Opsional',
                          controller: _suhuController,
                          hint: 'Contoh: 36.8',
                          keyboardType: TextInputType.number,
                          enabled: !_menyimpan,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              final val = double.tryParse(value);
                              if (val == null || val < 35 || val > 42) {
                                return 'Masukkan suhu tubuh valid antara 35 - 42°C';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        Text(
                          'Pilih Gejala yang Timbul:',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: AppColors.darkText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: _daftarGejala.map((gejala) {
                            final isSelected = _selectedGejala.contains(gejala);
                            return FilterChip(
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
                        const SizedBox(height: 20),

                        CustomTextField(
                          label: 'Catatan Keluhan / Kondisi Kesehatan Bebas',
                          controller: _catatanController,
                          hint: 'Tulis deskripsi kondisi kesehatan anak di sini...',
                          maxLines: 4,
                          enabled: !_menyimpan,
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'Isi catatan keluhan wajib diisi'
                              : null,
                        ),
                        const SizedBox(height: 32),

                        ElevatedButton(
                          onPressed: _menyimpan
                              ? null
                              : () => _saveJournal(currentBaby.babyId),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.yellow,
                            foregroundColor: AppColors.darkText,
                          ),
                          child: const Text('Simpan Catatan Jurnal'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
        loading: () => const AppLoadingIndicator(),
        error: (err, _) => ErrorStateWidget(message: '$err'),
      ),
    );
  }
}
