import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../widgets/custom_text_field.dart';
import '../../../../widgets/empty_state_widget.dart';
import '../../../../widgets/error_state_widget.dart';
import '../../../../widgets/loading_overlay.dart';
import '../../../baby_profile/presentation/providers/active_baby_provider.dart';
import '../providers/growth_provider.dart';
import '../../domain/entities/growth_record_entity.dart';

class AddGrowthRecordScreen extends ConsumerStatefulWidget {
  const AddGrowthRecordScreen({super.key});

  @override
  ConsumerState<AddGrowthRecordScreen> createState() =>
      _AddGrowthRecordScreenState();
}

class _AddGrowthRecordScreenState extends ConsumerState<AddGrowthRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _bbController = TextEditingController();
  final TextEditingController _tbController = TextEditingController();
  final TextEditingController _lkController = TextEditingController();
  DateTime _tanggalPengukuran = DateTime.now();
  bool _menyimpan = false;

  @override
  void dispose() {
    _bbController.dispose();
    _tbController.dispose();
    _lkController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _tanggalPengukuran,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _tanggalPengukuran) {
      if (!mounted) return;
      setState(() {
        _tanggalPengukuran = picked;
      });
    }
  }

  Future<void> _saveRecord(String babyId) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _menyimpan = true);

    final record = GrowthRecordEntity(
      recordId: const Uuid().v4(),
      babyId: babyId,
      tanggalPengukuran: _tanggalPengukuran,
      beratBadan: double.parse(_bbController.text),
      tinggiBadan: double.parse(_tbController.text),
      lingkarKepala: _lkController.text.isNotEmpty
          ? double.parse(_lkController.text)
          : null,
    );

    try {
      await ref.read(growthProvider(babyId).notifier).addRecord(record);

      if (!mounted) return;
      setState(() => _menyimpan = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data pertumbuhan berhasil disimpan! 📈'),
          backgroundColor: AppColors.green,
        ),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _menyimpan = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan data pertumbuhan: $e'),
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
              context.canPop() ? context.pop() : context.go(AppRoutes.growth),
        ),
        title: Text(
          'Tambah Pengukuran',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      body: babyAsync.when(
        data: (currentBaby) {
          if (currentBaby == null) {
            return EmptyStateWidget(
              icon: Icons.child_care,
              title: 'Belum ada profil anak',
              message: 'Tambahkan profil anak sebelum mencatat pengukuran.',
              actionLabel: 'Tambah Profil Anak',
              onAction: () => context.push(AppRoutes.addBaby),
            );
          }

          return LoadingOverlay(
            isLoading: _menyimpan,
            message: 'Menyimpan pengukuran…',
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
                        // Date selector picker button
                        ListTile(
                          title: Text(
                            'Tanggal Pengukuran:',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            '${_tanggalPengukuran.day}/${_tanggalPengukuran.month}/${_tanggalPengukuran.year}',
                          ),
                          trailing: const Icon(
                            Icons.calendar_today,
                            color: AppColors.coral,
                          ),
                          onTap: () => _selectDate(context),
                        ),
                        const Divider(),
                        const SizedBox(height: 16),

                        // Input entries text boxes with safety constraint boundaries
                        CustomTextField(
                          label: 'Berat Badan (kg)',
                          controller: _bbController,
                          hint: 'Contoh: 8.5',
                          keyboardType: TextInputType.number,
                          enabled: !_menyimpan,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Berat badan wajib diisi';
                            }
                            final val = double.tryParse(value);
                            if (val == null || val <= 0 || val > 30) {
                              return 'Masukkan angka valid antara 0 - 30kg';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        CustomTextField(
                          label: 'Tinggi Badan (cm)',
                          controller: _tbController,
                          hint: 'Contoh: 68.2',
                          keyboardType: TextInputType.number,
                          enabled: !_menyimpan,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Tinggi badan wajib diisi';
                            }
                            final val = double.tryParse(value);
                            if (val == null || val <= 0 || val > 120) {
                              return 'Masukkan angka valid antara 0 - 120cm';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        CustomTextField(
                          label: 'Lingkar Kepala (cm) - Opsional',
                          controller: _lkController,
                          hint: 'Contoh: 42.1',
                          keyboardType: TextInputType.number,
                          enabled: !_menyimpan,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              final val = double.tryParse(value);
                              if (val == null || val <= 0 || val > 60) {
                                return 'Masukkan angka valid antara 0 - 60cm';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),

                        ElevatedButton(
                          onPressed: _menyimpan
                              ? null
                              : () => _saveRecord(currentBaby.babyId),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.coral,
                          ),
                          child: const Text('Simpan Pengukuran'),
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
