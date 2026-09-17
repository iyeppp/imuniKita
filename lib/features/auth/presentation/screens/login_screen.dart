import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../data/models/user_model.dart';
import '../utils/auth_validators.dart';
import '../utils/snackbar_helper.dart';
import '../widgets/app_logo_pill.dart';
import '../widgets/labeled_text_field.dart';
import '../widgets/neo_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate short loading delay
    await Future.delayed(const Duration(milliseconds: 1200));

    try {
      final userBox = await Hive.openBox<UserModel>('userBox');

      if (userBox.isEmpty) {
        if (mounted) {
          SnackbarHelper.showError(
            context,
            'Belum ada akun terdaftar. Dialihkan ke halaman pendaftaran.',
          );
          context.go(AppRoutes.register);
        }
        return;
      }

      // Check if user with matching email exists
      UserModel? matchedUser;
      for (var user in userBox.values) {
        if (user.email.trim().toLowerCase() ==
            _emailController.text.trim().toLowerCase()) {
          matchedUser = user;
          break;
        }
      }

      if (matchedUser != null) {
        // Successful login
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_logged_in', true);
        await prefs.setString('user_id', matchedUser.localId);
        await prefs.setString('user_name', matchedUser.namaLengkap);

        if (mounted) {
          SnackbarHelper.showSuccess(
            context,
            'Selamat datang kembali, ${matchedUser.namaLengkap}!',
          );
          context.go(AppRoutes.dashboard);
        }
      } else {
        // User not found or incorrect info
        if (mounted) {
          SnackbarHelper.showError(
            context,
            'Email salah atau tidak terdaftar!',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showError(context, 'Terjadi kesalahan: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                  const SizedBox(height: 36),

                  // Email Input Field
                  LabeledTextField(
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
                  LabeledTextField(
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
                  const SizedBox(height: 32),

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
    );
  }
}
