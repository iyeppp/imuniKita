import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../baby_profile/presentation/providers/active_baby_provider.dart';
import '../providers/growth_provider.dart';
import '../../data/models/growth_record_model.dart';

class AddGrowthRecordScreen extends ConsumerStatefulWidget {
  const AddGrowthRecordScreen({super.key});

  @override
  ConsumerState<AddGrowthRecordScreen> createState() => _AddGrowthRecordScreenState();
}

class _AddGrowthRecordScreenState extends ConsumerState<AddGrowthRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _bbController = TextEditingController();
  final TextEditingController _tbController = TextEditingController();
  final TextEditingController _lkController = TextEditingController();
  DateTime _tanggalPengukuran = DateTime.now();

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
      setState(() {
        _tanggalPengukuran = picked;
      });
    }
  }

  Future<void> _saveRecord(String babyId) async {
    if (!_formKey.currentState!.validate()) return;

    final record = GrowthRecordModel(
      recordId: const Uuid().v4(),
      babyId: babyId,
      tanggalPengukuran: _tanggalPengukuran,
      beratBadan: double.parse(_bbController.text),
      tinggiBadan: double.parse(_tbController.text),
      lingkarKepala: _lkController.text.isNotEmpty ? double.parse(_lkController.text) : null,
    );

    await ref.read(growthProvider(babyId).notifier).addRecord(record);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data pertumbuhan berhasil disimpan! 📈'), backgroundColor: AppColors.green),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final babyAsync = ref.watch(activeBabyProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Tambah Pengukuran', style: GoogleFonts.poppins(fontWeight: FontWeight.bold))),
      body: babyAsync.when(
        data: (currentBaby) {
          if (currentBaby == null) return const Center(child: Text('Belum ada profil anak.'));

          return SingleChildScrollView(
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
                        title: Text('Tanggal Pengukuran:', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
                        subtitle: Text('${_tanggalPengukuran.day}/${_tanggalPengukuran.month}/${_tanggalPengukuran.year}'),
                        trailing: const Icon(Icons.calendar_today, color: AppColors.coral),
                        onTap: () => _selectDate(context),
                      ),
                      const Divider(),
                      const SizedBox(height: 16),

                      // Input entries text boxes with safety constraint boundaries
                      TextFormField(
                        controller: _bbController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Berat Badan (kg)', hintText: 'Contoh: 8.5'),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Berat badan wajib diisi';
                          final val = double.tryParse(value);
                          if (val == null || val <= 0 || val > 30) return 'Masukkan angka valid antara 0 - 30kg';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _tbController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Tinggi Badan (cm)', hintText: 'Contoh: 68.2'),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Tinggi badan wajib diisi';
                          final val = double.tryParse(value);
                          if (val == null || val <= 0 || val > 120) return 'Masukkan angka valid antara 0 - 120cm';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _lkController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Lingkar Kepala (cm) - Opsional', hintText: 'Contoh: 42.1'),
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            final val = double.tryParse(value);
                            if (val == null || val <= 0 || val > 60) return 'Masukkan angka valid antara 0 - 60cm';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),

                      ElevatedButton(
                        onPressed: () => _saveRecord(currentBaby.babyId),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.coral),
                        child: const Text('Simpan Pengukuran'),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Gagal: $err')),
      ),
    );
  }
}
