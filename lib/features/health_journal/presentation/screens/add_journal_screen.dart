import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../baby_profile/presentation/providers/baby_provider.dart';
import '../providers/journal_provider.dart';
import '../../data/models/health_journal_model.dart';

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

  final List<String> _daftarGejala = ['Demam', 'Bengkak Bekas Suntik', 'Rewel', 'Muntah', 'Ruam Kulit', 'Batuk Pilek'];

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
      setState(() {
        _tanggalCatatan = picked;
      });
    }
  }

  Future<void> _saveJournal(String babyId) async {
    if (!_formKey.currentState!.validate()) return;

    final suhu = double.tryParse(_suhuController.text);

    final journal = HealthJournalModel(
      journalId: const Uuid().v4(),
      babyId: babyId,
      tanggalCatatan: _tanggalCatatan,
      isiCatatan: _catatanController.text.trim(),
      suhuTubuh: suhu,
      gejala: List.from(_selectedGejala),
    );

    await ref.read(journalProvider(babyId).notifier).addJournal(journal);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Catatan jurnal kesehatan berhasil disimpan! 📝'), backgroundColor: AppColors.green),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final babiesAsync = ref.watch(babyNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Tambah Jurnal Sehat', style: GoogleFonts.poppins(fontWeight: FontWeight.bold))),
      body: babiesAsync.when(
        data: (babies) {
          if (babies.isEmpty) return const Center(child: Text('Belum ada profil anak.'));
          final currentBaby = babies.first;

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
                      ListTile(
                        title: Text('Tanggal Kejadian:', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
                        subtitle: Text('${_tanggalCatatan.day}/${_tanggalCatatan.month}/${_tanggalCatatan.year}'),
                        trailing: const Icon(Icons.calendar_today, color: AppColors.yellow),
                        onTap: () => _selectDate(context),
                      ),
                      const Divider(),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _suhuController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Suhu Tubuh (°C) - Opsional', hintText: 'Contoh: 36.8'),
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            final val = double.tryParse(value);
                            if (val == null || val < 35 || val > 42) return 'Masukkan suhu tubuh valid antara 35 - 42°C';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      Text('Pilih Gejala yang Timbul:', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.darkText)),
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

                      TextFormField(
                        controller: _catatanController,
                        maxLines: 4,
                        decoration: const InputDecoration(labelText: 'Catatan Keluhan / Kondisi Kesehatan Bebas', hintText: 'Tulis deskripsi kondisi kesehatan anak di sini...'),
                        validator: (value) => value == null || value.trim().isEmpty ? 'Isi catatan keluhan wajib diisi' : null,
                      ),
                      const SizedBox(height: 32),

                      ElevatedButton(
                        onPressed: () => _saveJournal(currentBaby.babyId),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.yellow, foregroundColor: AppColors.darkText),
                        child: const Text('Simpan Catatan Jurnal'),
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
