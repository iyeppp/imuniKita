import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/local_storage_service.dart';
import '../../../../core/utils/age_calculator.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../injection/dependency_injection.dart';
import '../../../../widgets/custom_text_field.dart';
import '../../domain/entities/baby_entity.dart';
import '../providers/baby_provider.dart';

/// FR-01 — Form tambah profil bayi.
///
/// Alur setelah "Simpan Profil" ditekan (lihat dev plan §4 "Alur Kerja"):
/// `AddBabyUseCase` → `GenerateScheduleUseCase` (buat seluruh jadwal vaksin
/// nasional) → `ScheduleReminderUseCase` (daftarkan notifikasi lokal H-7 &
/// H-1 untuk tiap jadwal).
class AddBabyScreen extends ConsumerStatefulWidget {
  const AddBabyScreen({super.key});

  @override
  ConsumerState<AddBabyScreen> createState() => _AddBabyScreenState();
}

class _AddBabyScreenState extends ConsumerState<AddBabyScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();

  DateTime? _tanggalLahir;
  String? _jenisKelamin; // BabyGender.laki | BabyGender.perempuan
  String? _fotoProfilPath;
  bool _showDateError = false;
  bool _showGenderError = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (picked != null) {
        setState(() => _fotoProfilPath = picked.path);
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Gagal membuka galeri: $e', isError: true);
    }
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggalLahir ?? now,
      firstDate: DateTime(now.year - 6),
      lastDate: now,
      helpText: 'Pilih Tanggal Lahir',
    );
    if (picked != null) {
      setState(() {
        _tanggalLahir = picked;
        _showDateError = false;
      });
    }
  }

  void _selectGender(String gender) {
    setState(() {
      _jenisKelamin = gender;
      _showGenderError = false;
    });
  }

  Future<void> _handleSave() async {
    final isFormValid = _formKey.currentState!.validate();

    setState(() {
      _showDateError = _tanggalLahir == null;
      _showGenderError = _jenisKelamin == null;
    });

    if (!isFormValid || _tanggalLahir == null || _jenisKelamin == null) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = await LocalStorageService.getCurrentUserId();
      if (userId == null) {
        throw const LocalStorageFailure(
          'Sesi tidak ditemukan. Silakan masuk kembali.',
        );
      }

      final baby = BabyEntity(
        babyId: const Uuid().v4(),
        userId: userId,
        namaAnak: _nameController.text.trim(),
        tanggalLahir: _tanggalLahir!,
        jenisKelamin: _jenisKelamin!,
        fotoProfilPath: _fotoProfilPath,
        createdAt: DateTime.now(),
      );

      // 1. Simpan profil bayi.
      final savedBaby = await ref
          .read(babyNotifierProvider.notifier)
          .addBaby(baby);

      // 2. Generate seluruh jadwal imunisasi nasional untuk bayi ini.
      final schedules = await ref
          .read(generateScheduleUseCaseProvider)
          .execute(
            babyId: savedBaby.babyId,
            tanggalLahir: savedBaby.tanggalLahir,
          );

      // 3. Daftarkan notifikasi pengingat H-7 & H-1 untuk tiap jadwal.
      //    Sengaja non-fatal: bila izin alarm/notifikasi ditolak OS (umum di
      //    Android 14+), profil & jadwal tetap tersimpan dan user tetap
      //    diarahkan ke Dashboard.
      var reminderFailed = false;
      try {
        await ref
            .read(scheduleReminderUseCaseProvider)
            .execute(namaAnak: savedBaby.namaAnak, schedules: schedules);
      } catch (_) {
        reminderFailed = true;
      }

      if (!mounted) return;
      _showSnackBar(
        reminderFailed
            ? 'Profil ${savedBaby.namaAnak} tersimpan & ${schedules.length} '
                  'jadwal dibuat. Catatan: notifikasi pengingat belum aktif '
                  '(izin alarm/notifikasi belum diberikan).'
            : 'Profil ${savedBaby.namaAnak} berhasil disimpan! '
                  '${schedules.length} jadwal imunisasi telah dibuat.',
      );
      context.go(AppRoutes.dashboard);
    } catch (e) {
      if (!mounted) return;
      final message = e is Failure ? e.message : 'Gagal menyimpan profil: $e';
      _showSnackBar(message, isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError ? AppColors.error : AppColors.success,
        content: Text(message, style: GoogleFonts.poppins(color: Colors.white)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Kembali',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go(AppRoutes.dashboard),
        ),
        title: Text(
          'Tambah Profil Bayi',
          style: GoogleFonts.baloo2(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Lengkapi data buah hati Anda',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),

                // ── Avatar + upload foto ─────────────────────────────────
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 52,
                        backgroundColor: AppColors.primaryLighter,
                        backgroundImage: _fotoProfilPath != null
                            ? FileImage(File(_fotoProfilPath!))
                            : null,
                        child: _fotoProfilPath == null
                            ? const Icon(
                                Icons.child_care_rounded,
                                size: 48,
                                color: AppColors.primary,
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickPhoto,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.darkText,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              size: 18,
                              color: AppColors.darkText,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: _pickPhoto,
                    child: Text(
                      'Unggah Foto Profil',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Nama Anak ─────────────────────────────────────────────
                CustomTextField(
                  label: 'Nama Anak',
                  controller: _nameController,
                  hint: 'Nama Lengkap Anak',
                  keyboardType: TextInputType.name,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Nama anak wajib diisi'
                      : null,
                ),
                const SizedBox(height: 16),

                // ── Tanggal Lahir ─────────────────────────────────────────
                Text(
                  'Tanggal Lahir',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: _pickBirthDate,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      hintText: 'Pilih tanggal lahir',
                      suffixIcon: const Icon(
                        Icons.calendar_month_rounded,
                        color: AppColors.darkText,
                      ),
                      errorText: _showDateError
                          ? 'Tanggal lahir wajib dipilih'
                          : null,
                    ),
                    child: Text(
                      _tanggalLahir != null
                          ? DateFormatter.formatLong(_tanggalLahir!)
                          : 'Pilih tanggal lahir',
                      style: GoogleFonts.poppins(
                        color: _tanggalLahir != null
                            ? AppColors.darkText
                            : AppColors.textHint,
                      ),
                    ),
                  ),
                ),
                if (_tanggalLahir != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLighter,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.cake_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Usia saat ini: ${AgeCalculator.label(_tanggalLahir!)}',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),

                // ── Jenis Kelamin ─────────────────────────────────────────
                Text(
                  'Jenis Kelamin',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: _GenderOption(
                        label: 'Laki-laki',
                        icon: Icons.male_rounded,
                        selected: _jenisKelamin == BabyGender.laki,
                        onTap: () => _selectGender(BabyGender.laki),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _GenderOption(
                        label: 'Perempuan',
                        icon: Icons.female_rounded,
                        selected: _jenisKelamin == BabyGender.perempuan,
                        onTap: () => _selectGender(BabyGender.perempuan),
                      ),
                    ),
                  ],
                ),
                if (_showGenderError) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Jenis kelamin wajib dipilih',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.error,
                    ),
                  ),
                ],
                const SizedBox(height: 32),

                // ── Tombol Simpan ─────────────────────────────────────────
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: _isLoading
                        ? null
                        : const [
                            BoxShadow(
                              color: AppColors.darkText,
                              offset: Offset(3, 3),
                              blurRadius: 0,
                            ),
                          ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      side: const BorderSide(
                        color: AppColors.darkText,
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor: AppColors.primary.withValues(
                        alpha: 0.6,
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: AppColors.darkText,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            'Simpan Profil',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkText,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Toggle kartu pilihan jenis kelamin (L/P) bergaya neo-brutalist konsisten
/// dengan tombol lain di aplikasi (border tebal + drop shadow tegas saat aktif).
class _GenderOption extends StatelessWidget {
  const _GenderOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.darkText, width: 2),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: AppColors.darkText,
                    offset: Offset(3, 3),
                    blurRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.darkText),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: AppColors.darkText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
