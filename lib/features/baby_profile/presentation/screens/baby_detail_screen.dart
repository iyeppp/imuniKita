import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/age_calculator.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../injection/dependency_injection.dart';
import '../../../../widgets/confirm_dialog.dart';
import '../../../growth/presentation/providers/growth_provider.dart';
import '../../../health_journal/presentation/providers/journal_provider.dart';
import '../../../immunization/presentation/providers/immunization_provider.dart';
import '../../domain/entities/baby_entity.dart';
import '../providers/active_baby_provider.dart';
import '../providers/baby_provider.dart';

/// Kelola satu profil bayi — Temuan #21.
///
/// `UpdateBabyUseCase` sudah ada sejak Sprint 1 tetapi belum dipakai UI mana
/// pun, sehingga salah input tanggal lahir tidak bisa diperbaiki tanpa
/// menghapus seluruh data aplikasi. Layar ini menyediakan ubah + hapus
/// (berkonfirmasi) sekaligus pemilihan bayi aktif (Temuan #2).
class BabyDetailScreen extends ConsumerWidget {
  const BabyDetailScreen({super.key, required this.babyId});

  final String babyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final babyAsync = ref.watch(babyByIdProvider(babyId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Kelola Profil Anak',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      body: babyAsync.when(
        data: (baby) {
          if (baby == null) {
            return const Center(child: Text('Profil anak tidak ditemukan.'));
          }
          return _FormKelolaBayi(baby: baby);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Gagal memuat profil anak: $err',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: AppColors.textSecondary),
            ),
          ),
        ),
      ),
    );
  }
}

class _FormKelolaBayi extends ConsumerStatefulWidget {
  const _FormKelolaBayi({required this.baby});

  final BabyEntity baby;

  @override
  ConsumerState<_FormKelolaBayi> createState() => _FormKelolaBayiState();
}

class _FormKelolaBayiState extends ConsumerState<_FormKelolaBayi> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nama = TextEditingController(
    text: widget.baby.namaAnak,
  );
  late DateTime _tanggalLahir = widget.baby.tanggalLahir;
  late String _jenisKelamin = widget.baby.jenisKelamin;

  bool _menyimpan = false;
  bool _menghapus = false;

  @override
  void dispose() {
    _nama.dispose();
    super.dispose();
  }

  bool get _tanggalLahirBerubah =>
      !_samaTanggal(_tanggalLahir, widget.baby.tanggalLahir);

  static bool _samaTanggal(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Future<void> _pilihTanggal() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggalLahir,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) {
      setState(() => _tanggalLahir = picked);
    }
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _menyimpan = true);

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final babyId = widget.baby.babyId;
    final nama = _nama.text.trim();
    final tanggalBerubah = _tanggalLahirBerubah;

    try {
      await ref
          .read(babyNotifierProvider.notifier)
          .updateBaby(
            widget.baby.copyWith(
              namaAnak: nama,
              tanggalLahir: _tanggalLahir,
              jenisKelamin: _jenisKelamin,
            ),
          );

      // Tanggal lahir berubah → seluruh jadwal imunisasi harus dihitung ulang,
      // kalau tidak tanggal target vaksin tetap mengikuti tanggal lahir lama.
      if (tanggalBerubah) {
        await _hitungUlangJadwal(babyId, nama);
      }

      ref.invalidate(babyByIdProvider(babyId));

      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            tanggalBerubah
                ? 'Profil diperbarui & 13 jadwal imunisasi dihitung ulang.'
                : 'Profil ${widget.baby.namaAnak} berhasil diperbarui.',
          ),
          backgroundColor: AppColors.green,
        ),
      );
      navigator.pop();
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            e is Failure ? e.message : 'Gagal menyimpan profil: $e',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _menyimpan = false);
    }
  }

  /// Bersihkan jadwal lama lalu bangun ulang 13 jadwal dari tanggal lahir baru.
  Future<void> _hitungUlangJadwal(String babyId, String nama) async {
    await ref.read(immunizationProvider(babyId).notifier).deleteAllForBaby();

    final jadwal = await ref
        .read(generateScheduleUseCaseProvider)
        .execute(babyId: babyId, tanggalLahir: _tanggalLahir);

    try {
      await ref
          .read(scheduleReminderUseCaseProvider)
          .execute(namaAnak: nama, schedules: jadwal);
    } catch (_) {
      // Non-fatal — sama seperti alur Tambah Bayi (izin alarm bisa ditolak).
    }
  }

  Future<void> _jadikanAktif() async {
    await ref.read(activeBabyProvider.notifier).selectBaby(widget.baby.babyId);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.baby.namaAnak} kini menjadi anak aktif.'),
        backgroundColor: AppColors.green,
      ),
    );
  }

  Future<void> _hapus() async {
    final konfirmasi = await ConfirmDialog.show(
      context: context,
      title: 'Hapus profil ${widget.baby.namaAnak}?',
      message:
          'Jadwal imunisasi, rekam pertumbuhan, dan jurnal kesehatan anak ini '
          'ikut terhapus permanen dan tidak bisa dikembalikan.',
      confirmLabel: 'Hapus',
      isDestructive: true,
    );
    if (!konfirmasi || !mounted) return;

    setState(() => _menghapus = true);

    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    final babyId = widget.baby.babyId;
    final nama = widget.baby.namaAnak;

    try {
      // Cascade: bersihkan data tiap fitur sebelum profilnya dihapus agar
      // tidak menyisakan jadwal/pertumbuhan/jurnal yatim di Hive.
      await ref.read(immunizationProvider(babyId).notifier).deleteAllForBaby();
      await ref.read(growthProvider(babyId).notifier).deleteAllForBaby();
      await ref.read(journalProvider(babyId).notifier).deleteAllForBaby();
      await ref.read(babyNotifierProvider.notifier).deleteBaby(babyId);

      messenger.showSnackBar(
        SnackBar(
          content: Text('Profil $nama beserta seluruh datanya telah dihapus.'),
          backgroundColor: AppColors.green,
        ),
      );
      router.go(AppRoutes.settings);
    } catch (e) {
      if (!mounted) return;
      setState(() => _menghapus = false);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            e is Failure ? e.message : 'Gagal menghapus profil: $e',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final nama = _nama.text.trim();
    final inisial = nama.isEmpty ? '?' : nama[0].toUpperCase();
    final aktif =
        ref.watch(activeBabyProvider).asData?.value?.babyId ==
        widget.baby.babyId;
    final sibuk = _menyimpan || _menghapus;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Ringkasan bayi
            Card(
              elevation: 0,
              color: AppColors.teal.withValues(alpha: 0.10),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.teal,
                      child: Text(
                        inisial,
                        style: GoogleFonts.baloo2(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nama.isEmpty ? widget.baby.namaAnak : nama,
                            style: GoogleFonts.baloo2(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkText,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${AgeCalculator.label(_tanggalLahir)} · '
                            'lahir ${DateFormatter.formatLong(_tanggalLahir)}',
                            style: GoogleFonts.poppins(
                              fontSize: 11.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (aktif)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.green.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.green),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              size: 13,
                              color: AppColors.green,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Aktif',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Data Anak',
              style: GoogleFonts.baloo2(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 10),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nama,
                      enabled: !sibuk,
                      decoration: const InputDecoration(
                        labelText: 'Nama Anak',
                        prefixIcon: Icon(Icons.child_care),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Nama anak wajib diisi'
                          : null,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),

                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Tanggal Lahir',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText,
                        ),
                      ),
                      subtitle: Text(
                        DateFormatter.formatLong(_tanggalLahir),
                        style: GoogleFonts.poppins(fontSize: 12.5),
                      ),
                      trailing: const Icon(
                        Icons.calendar_today,
                        color: AppColors.coral,
                      ),
                      onTap: sibuk ? null : _pilihTanggal,
                    ),
                    const Divider(),

                    const SizedBox(height: 8),
                    Text(
                      'Jenis Kelamin',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _PilihanGender(
                          label: 'Laki-laki',
                          ikon: Icons.male,
                          terpilih: _jenisKelamin == BabyGender.laki,
                          onTap: sibuk
                              ? null
                              : () => setState(
                                  () => _jenisKelamin = BabyGender.laki,
                                ),
                        ),
                        const SizedBox(width: 10),
                        _PilihanGender(
                          label: 'Perempuan',
                          ikon: Icons.female,
                          terpilih: _jenisKelamin == BabyGender.perempuan,
                          onTap: sibuk
                              ? null
                              : () => setState(
                                  () => _jenisKelamin = BabyGender.perempuan,
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            if (_tanggalLahirBerubah) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.yellow.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.yellow),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 18,
                      color: AppColors.darkText,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tanggal lahir berubah — seluruh jadwal imunisasi akan '
                        'dihitung ulang saat disimpan.',
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          color: AppColors.darkText,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: sibuk ? null : _simpan,
              child: _menyimpan
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Simpan Perubahan'),
            ),

            if (!aktif) ...[
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: sibuk ? null : _jadikanAktif,
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: const Text('Jadikan Anak Aktif'),
              ),
            ],

            const SizedBox(height: 28),
            const Divider(),
            const SizedBox(height: 12),
            Text(
              'Zona Berbahaya',
              style: GoogleFonts.baloo2(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.red,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Hapus profil anak beserta seluruh jadwal imunisasi, rekam '
              'pertumbuhan, dan jurnal kesehatannya.',
              style: GoogleFonts.poppins(
                fontSize: 11.5,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: sibuk ? null : _hapus,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.red,
                side: const BorderSide(color: AppColors.red, width: 1.5),
              ),
              icon: _menghapus
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.delete_outline, size: 18),
              label: const Text('Hapus Profil Anak'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PilihanGender extends StatelessWidget {
  const _PilihanGender({
    required this.label,
    required this.ikon,
    required this.terpilih,
    this.onTap,
  });

  final String label;
  final IconData ikon;
  final bool terpilih;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: terpilih
                ? AppColors.teal.withValues(alpha: 0.15)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: terpilih ? AppColors.teal : AppColors.border,
              width: terpilih ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                ikon,
                size: 18,
                color: terpilih ? AppColors.tealDark : AppColors.grey,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: terpilih ? FontWeight.w600 : FontWeight.w400,
                  color: AppColors.darkText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
