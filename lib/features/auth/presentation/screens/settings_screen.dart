import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/age_calculator.dart';
import '../../../../injection/dependency_injection.dart';
import '../../../../widgets/confirm_dialog.dart';
import '../../../baby_profile/domain/entities/baby_entity.dart';
import '../../../baby_profile/presentation/providers/baby_provider.dart';
import '../../../immunization/domain/entities/vaccine_schedule_entity.dart';
import '../../../immunization/presentation/providers/immunization_provider.dart';
import '../../data/models/user_model.dart';
import '../providers/auth_provider.dart';
import '../utils/auth_validators.dart';
import '../widgets/labeled_text_field.dart';

/// Settings / Profile (poin 8.1) — `lib/features/auth/presentation/screens/settings_screen.dart`.
///
/// Berisi: profil pengguna + sunting profil, daftar bayi terdaftar (+ tambah
/// bayi), preferensi notifikasi pengingat, info versi aplikasi, dan tombol
/// keluar (hapus sesi SharedPreferences tanpa menghapus data Hive CE).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Profil & Pengaturan',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      body: userAsync.when(
        data: (user) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(currentUserProvider);
            ref.invalidate(babyNotifierProvider);
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              _KartuProfil(user: user),
              const SizedBox(height: 24),

              const _JudulSeksi('Anak Terdaftar'),
              const _DaftarAnak(),
              const SizedBox(height: 24),

              const _JudulSeksi('Pengaturan'),
              const _KartuPengaturan(),
              const SizedBox(height: 24),

              const _TombolKeluar(),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  'ImuniKita v${AppConstants.appVersion}',
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    color: AppColors.textHint,
                  ),
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Gagal memuat profil: $err',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: AppColors.textSecondary),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 4,
        onTap: (index) {
          if (index == 0) context.go(AppRoutes.dashboard);
          if (index == 1) context.go(AppRoutes.calendar);
          if (index == 2) context.go(AppRoutes.growth);
          if (index == 3) context.go(AppRoutes.journal);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Kalender',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Pertumbuhan',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Jurnal'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// Profil pengguna
// ───────────────────────────────────────────────────────────────────────────

class _KartuProfil extends ConsumerWidget {
  const _KartuProfil({required this.user});

  /// `null` bila sesi login tidak ditemukan (mis. setelah keluar).
  final UserModel? user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final akun = user;

    if (akun == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Sesi login tidak ditemukan. Silakan masuk kembali untuk melihat profil.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.login),
                child: const Text('Masuk'),
              ),
            ],
          ),
        ),
      );
    }

    final nama = akun.namaLengkap.trim();
    final inisial = nama.isEmpty ? '?' : nama[0].toUpperCase();
    final kota = akun.lokasiKota?.trim() ?? '';

    return Card(
      elevation: 0,
      color: AppColors.coral.withValues(alpha: 0.12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: AppColors.coral,
              child: Text(
                inisial,
                style: GoogleFonts.baloo2(
                  fontSize: 26,
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
                    akun.namaLengkap,
                    style: GoogleFonts.baloo2(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    akun.email,
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      _InfoKecil(
                        ikon: Icons.phone_outlined,
                        teks: akun.nomorTelepon,
                      ),
                      if (kota.isNotEmpty)
                        _InfoKecil(
                          ikon: Icons.location_on_outlined,
                          teks: kota,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Sunting profil',
              icon: const Icon(Icons.edit_outlined, color: AppColors.darkText),
              onPressed: () => _bukaFormEditProfil(context, akun),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoKecil extends StatelessWidget {
  const _InfoKecil({required this.ikon, required this.teks});

  final IconData ikon;
  final String teks;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(ikon, size: 13, color: AppColors.textHint),
        const SizedBox(width: 4),
        Text(
          teks,
          style: GoogleFonts.poppins(
            fontSize: 11.5,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// Daftar bayi
// ───────────────────────────────────────────────────────────────────────────

class _DaftarAnak extends ConsumerWidget {
  const _DaftarAnak();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final babiesAsync = ref.watch(babyNotifierProvider);

    return babiesAsync.when(
      data: (babies) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (babies.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Belum ada profil anak yang terdaftar.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            )
          else
            ...babies.map((baby) => _KartuAnak(baby: baby)),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => context.push(AppRoutes.addBaby),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Tambah Bayi'),
          ),
        ],
      ),
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Text(
        'Gagal memuat data anak: $err',
        style: GoogleFonts.poppins(fontSize: 12.5, color: AppColors.error),
      ),
    );
  }
}

class _KartuAnak extends ConsumerWidget {
  const _KartuAnak({required this.baby});

  final BabyEntity baby;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Ringkasan progres imunisasi (13 jadwal dibuat otomatis saat bayi
    // didaftarkan) — sekaligus bukti data tersimpan untuk bayi ini.
    final jadwal = ref.watch(immunizationProvider(baby.babyId)).asData?.value;
    final selesai = jadwal
        ?.where((s) => s.status == VaccineStatus.selesai)
        .length;

    final file = baby.fotoProfilPath == null
        ? null
        : File(baby.fotoProfilPath!);
    final ImageProvider? fotoProfil = (file != null && file.existsSync())
        ? FileImage(file)
        : null;

    final gender = baby.jenisKelamin == BabyGender.laki
        ? 'Laki-laki'
        : 'Perempuan';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.teal.withValues(alpha: 0.15),
              backgroundImage: fotoProfil,
              child: fotoProfil != null
                  ? null
                  : Text(
                      baby.namaAnak.trim().isEmpty
                          ? '?'
                          : baby.namaAnak.trim()[0].toUpperCase(),
                      style: GoogleFonts.baloo2(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.tealDark,
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    baby.namaAnak,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${AgeCalculator.label(baby.tanggalLahir)} · $gender',
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    jadwal == null
                        ? 'Memuat jadwal imunisasi…'
                        : 'Imunisasi selesai: ${selesai ?? 0}/${jadwal.length}',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// Pengaturan
// ───────────────────────────────────────────────────────────────────────────

class _KartuPengaturan extends ConsumerWidget {
  const _KartuPengaturan();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifAsync = ref.watch(notificationEnabledProvider);
    final aktif = notifAsync.asData?.value ?? true;

    return Card(
      child: Column(
        children: [
          SwitchListTile(
            value: aktif,
            onChanged: notifAsync.isLoading
                ? null
                : (value) => _ubahNotifikasi(context, ref, value),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 4,
            ),
            title: Text(
              'Notifikasi Pengingat',
              style: GoogleFonts.poppins(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppColors.darkText,
              ),
            ),
            subtitle: Text(
              'Pengingat otomatis H-7 & H-1 sebelum jadwal imunisasi',
              style: GoogleFonts.poppins(
                fontSize: 11.5,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.info_outline, color: AppColors.darkText),
            title: Text(
              'Tentang Aplikasi',
              style: GoogleFonts.poppins(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppColors.darkText,
              ),
            ),
            subtitle: Text(
              'ImuniKita versi ${AppConstants.appVersion}',
              style: GoogleFonts.poppins(
                fontSize: 11.5,
                color: AppColors.textSecondary,
              ),
            ),
            onTap: () => _tampilkanTentang(context),
          ),
        ],
      ),
    );
  }
}

class _TombolKeluar extends ConsumerWidget {
  const _TombolKeluar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OutlinedButton.icon(
      onPressed: () => _keluar(context, ref),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.red,
        side: const BorderSide(color: AppColors.red, width: 1.5),
      ),
      icon: const Icon(Icons.logout, size: 18),
      label: const Text('Keluar'),
    );
  }
}

class _JudulSeksi extends StatelessWidget {
  const _JudulSeksi(this.judul);

  final String judul;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        judul,
        style: GoogleFonts.baloo2(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: AppColors.darkText,
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// Aksi
// ───────────────────────────────────────────────────────────────────────────

/// Toggle preferensi notifikasi pengingat.
///
/// Saat diaktifkan kembali, pengingat untuk seluruh jadwal yang masih
/// `BELUM` didaftarkan ulang (pada 1.5 penjadwalan hanya terjadi sekali).
Future<void> _ubahNotifikasi(
  BuildContext context,
  WidgetRef ref,
  bool aktif,
) async {
  final messenger = ScaffoldMessenger.of(context);

  try {
    await ref.read(notificationEnabledProvider.notifier).setEnabled(aktif);

    if (!aktif) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Notifikasi pengingat dimatikan.')),
      );
      return;
    }

    final jumlah = await _daftarkanUlangPengingat(ref);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          jumlah == 0
              ? 'Notifikasi pengingat diaktifkan. Belum ada jadwal yang perlu diingatkan.'
              : 'Notifikasi pengingat diaktifkan untuk $jumlah jadwal.',
        ),
        backgroundColor: AppColors.green,
      ),
    );
  } catch (e) {
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          e is Failure ? e.message : 'Gagal mengubah preferensi notifikasi: $e',
        ),
        backgroundColor: AppColors.error,
      ),
    );
  }
}

/// Daftarkan ulang pengingat H-7 & H-1 untuk semua bayi milik user.
///
/// Mengembalikan jumlah jadwal berstatus `BELUM` yang diproses.
Future<int> _daftarkanUlangPengingat(WidgetRef ref) async {
  final babies = await ref.read(babyNotifierProvider.future);
  if (babies.isEmpty) return 0;

  final repository = ref.read(immunizationRepositoryProvider);
  final useCase = ref.read(scheduleReminderUseCaseProvider);

  var jumlah = 0;
  for (final baby in babies) {
    final schedules = await repository.getSchedulesByBaby(baby.babyId);
    if (schedules.isEmpty) continue;

    await useCase.execute(namaAnak: baby.namaAnak, schedules: schedules);
    jumlah += schedules.where((s) => s.status == VaccineStatus.belum).length;
  }
  return jumlah;
}

/// Keluar dari akun — selalu lewat konfirmasi karena sesi akan dihapus.
Future<void> _keluar(BuildContext context, WidgetRef ref) async {
  final konfirmasi = await ConfirmDialog.show(
    context: context,
    title: 'Keluar dari akun?',
    message:
        'Kamu perlu masuk kembali untuk mengakses data anak. Seluruh data '
        '(profil bayi, jadwal imunisasi, pertumbuhan, jurnal) tetap '
        'tersimpan di perangkat ini.',
    confirmLabel: 'Keluar',
    isDestructive: true,
  );
  if (!konfirmasi || !context.mounted) return;

  final messenger = ScaffoldMessenger.of(context);
  final router = GoRouter.of(context);

  await ref.read(currentUserProvider.notifier).logout();

  messenger.showSnackBar(
    const SnackBar(content: Text('Kamu telah keluar dari akun.')),
  );
  router.go(AppRoutes.login);
}

/// Dialog info singkat aplikasi + versi.
Future<void> _tampilkanTentang(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.border),
      ),
      title: Text(
        'ImuniKita',
        style: GoogleFonts.baloo2(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: AppColors.darkText,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Versi ${AppConstants.appVersion}',
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Aplikasi pemantau imunisasi dan tumbuh kembang anak. '
            'Fase UTS menyimpan seluruh data secara lokal di perangkat, '
            'tanpa mengirim apa pun ke server.',
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Tutup'),
        ),
      ],
    ),
  );
}

/// Buka form sunting profil (bottom sheet).
Future<void> _bukaFormEditProfil(BuildContext context, UserModel akun) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (_) => _FormEditProfil(akun: akun),
  );
}

class _FormEditProfil extends ConsumerStatefulWidget {
  const _FormEditProfil({required this.akun});

  final UserModel akun;

  @override
  ConsumerState<_FormEditProfil> createState() => _FormEditProfilState();
}

class _FormEditProfilState extends ConsumerState<_FormEditProfil> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nama = TextEditingController(
    text: widget.akun.namaLengkap,
  );
  late final TextEditingController _email = TextEditingController(
    text: widget.akun.email,
  );
  late final TextEditingController _telepon = TextEditingController(
    text: widget.akun.nomorTelepon,
  );
  late final TextEditingController _kota = TextEditingController(
    text: widget.akun.lokasiKota ?? '',
  );

  bool _menyimpan = false;

  @override
  void dispose() {
    _nama.dispose();
    _email.dispose();
    _telepon.dispose();
    _kota.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _menyimpan = true);

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final kota = _kota.text.trim();

    try {
      await ref
          .read(currentUserProvider.notifier)
          .updateProfile(
            UserModel(
              localId: widget.akun.localId,
              namaLengkap: _nama.text.trim(),
              email: _email.text.trim(),
              nomorTelepon: _telepon.text.trim(),
              lokasiKota: kota.isEmpty ? null : kota,
              createdAt: widget.akun.createdAt,
            ),
          );

      if (!mounted) return;
      navigator.pop();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Profil berhasil diperbarui.'),
          backgroundColor: AppColors.green,
        ),
      );
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Sunting Profil',
                  style: GoogleFonts.baloo2(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 16),
                LabeledTextField(
                  label: 'Nama Lengkap',
                  controller: _nama,
                  hint: 'Nama orang tua',
                  validator: (value) =>
                      AuthValidators.required(value, 'Nama lengkap'),
                ),
                const SizedBox(height: 16),
                LabeledTextField(
                  label: 'Email',
                  controller: _email,
                  hint: 'nama@email.com',
                  keyboardType: TextInputType.emailAddress,
                  validator: AuthValidators.email,
                ),
                const SizedBox(height: 16),
                LabeledTextField(
                  label: 'Nomor HP',
                  controller: _telepon,
                  hint: '08xxxxxxxxxx',
                  keyboardType: TextInputType.phone,
                  validator: (value) =>
                      AuthValidators.required(value, 'Nomor HP'),
                ),
                const SizedBox(height: 16),
                LabeledTextField(
                  label: 'Kota',
                  controller: _kota,
                  hint: 'Contoh: Bandung',
                  validator: (value) => AuthValidators.required(value, 'Kota'),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _menyimpan ? null : _simpan,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
