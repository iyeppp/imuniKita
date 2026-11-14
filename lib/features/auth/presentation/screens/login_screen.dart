import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/errors/failures.dart';
import '../../../../widgets/custom_text_field.dart';
import '../../domain/usecases/login_usecase.dart';
import '../providers/auth_provider.dart';
import '../utils/auth_validators.dart';
import '../utils/snackbar_helper.dart';
import '../widgets/app_logo_pill.dart';
import '../widgets/neo_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Temuan #22: seluruh logika auth dipindahkan ke use case
  /// (`LoginUseCase` lewat `currentUserProvider`); layar tidak lagi
  /// membuka `Hive.openBox`/`SharedPreferences` sendiri.
  ///
  /// B2-3: kredensial (email + password) diverifikasi Firebase Auth.
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Delay singkat agar transisi tombol terasa halus (perilaku lama).
    await Future.delayed(const Duration(milliseconds: 600));

    try {
      final hasil = await ref
          .read(currentUserProvider.notifier)
          .login(_emailController.text, _passwordController.text);

      if (!mounted) return;

      switch (hasil.status) {
        case LoginStatus.belumAdaAkun:
          SnackbarHelper.showError(
            context,
            'Belum ada akun terdaftar. Dialihkan ke halaman pendaftaran.',
          );
          context.go(AppRoutes.register);
        case LoginStatus.emailTidakDitemukan:
          SnackbarHelper.showError(
            context,
            'Email salah atau tidak terdaftar!',
          );
        case LoginStatus.sandiSalah:
          SnackbarHelper.showError(
            context,
            'Password salah. Periksa kembali lalu coba lagi.',
          );
        case LoginStatus.sukses:
          SnackbarHelper.showSuccess(
            context,
            'Selamat datang kembali, ${hasil.user!.namaLengkap}!',
          );
          context.go(AppRoutes.dashboard);
      }
    } catch (e) {
      if (!mounted) return;
      SnackbarHelper.showError(
        context,
        e is Failure ? e.message : 'Terjadi kesalahan: $e',
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// B2-1/B2-2: kirim tautan atur ulang password lewat Firebase Auth.
  ///
  /// Field email dipakai sebagai tujuan; bila kosong/tidak valid, user diminta
  /// melengkapinya dulu (tanpa memanggil server).
  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();
    final validation = AuthValidators.email(email);
    if (validation != null) {
      SnackbarHelper.showError(
        context,
        'Isi email yang terdaftar terlebih dahulu.',
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(currentUserProvider.notifier).sendPasswordReset(email);

      if (!mounted) return;
      SnackbarHelper.showSuccess(
        context,
        'Tautan atur ulang password telah dikirim ke $email.',
      );
    } catch (e) {
      if (!mounted) return;
      SnackbarHelper.showError(
        context,
        e is Failure ? e.message : 'Gagal mengirim tautan atur ulang: $e',
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (context.canPop()) {
          context.pop();
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const AppLogoPill(),
                    const SizedBox(height: 40),

                    Text(
                      'Selamat Datang Kembali',
                      style: GoogleFonts.baloo2(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Masuk untuk memantau imunisasi buah hati Anda',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // B2-4: kebijakan migrasi akun lokal UTS → Firebase.
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLighter,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.teal.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.info_outline,
                            size: 18,
                            color: AppColors.tealDark,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Akun kini tersinkron ke cloud. Jika Anda mendaftar '
                              'di versi awal aplikasi, silakan daftar ulang memakai '
                              'email yang sama — data bayi tetap tersimpan di '
                              'perangkat dan akan diadopsi setelah masuk.',
                              style: GoogleFonts.poppins(
                                fontSize: 11.5,
                                height: 1.35,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Email Input Field
                    CustomTextField(
                      label: 'Email',
                      controller: _emailController,
                      hint: 'nama@email.com',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        color: AppColors.darkText,
                      ),
                      validator: AuthValidators.email,
                    ),
                    const SizedBox(height: 20),

                    // Password Input Field
                    CustomTextField(
                      label: 'Password',
                      controller: _passwordController,
                      hint: '••••••••',
                      obscureText: _obscurePassword,
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: AppColors.darkText,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.darkText,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      validator: AuthValidators.password,
                    ),
                    const SizedBox(height: 8),

                    // B2-1: atur ulang password lewat Firebase Auth.
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _isLoading ? null : _handleForgotPassword,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          minimumSize: const Size(0, 32),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Lupa password?',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Login Button
                    NeoButton(
                      label: 'Masuk',
                      isLoading: _isLoading,
                      onPressed: _handleLogin,
                      backgroundColor: AppColors.teal,
                    ),
                    const SizedBox(height: 24),

                    // Link to Register Screen
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Belum punya akun? ',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.go(AppRoutes.register),
                          child: Text(
                            'Daftar',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
