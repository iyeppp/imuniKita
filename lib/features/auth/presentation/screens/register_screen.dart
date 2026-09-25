import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/models/user_model.dart';
import '../utils/auth_validators.dart';
import '../utils/snackbar_helper.dart';
import '../widgets/labeled_text_field.dart';
import '../widgets/neo_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate registration loading state
    await Future.delayed(const Duration(milliseconds: 1200));

    try {
      final userBox = await Hive.openBox<UserModel>(AppConstants.usersBox);

      final localId = const Uuid().v4();
      final newUser = UserModel(
        localId: localId,
        namaLengkap: _nameController.text.trim(),
        email: _emailController.text.trim().toLowerCase(),
        nomorTelepon: _phoneController.text.trim(),
        lokasiKota: _cityController.text.trim(),
        createdAt: DateTime.now(),
      );

      // Save to Hive CE database
      await userBox.put(localId, newUser);

      // Save to SharedPreferences session wrapper
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.prefIsLoggedIn, true);
      await prefs.setString(AppConstants.prefUserId, localId);
      await prefs.setString(AppConstants.prefUserName, newUser.namaLengkap);

      if (mounted) {
        SnackbarHelper.showSuccess(
          context,
          'Registrasi berhasil! Selamat bergabung, ${newUser.namaLengkap}.',
        );
        // Redirect to AddBaby screen as specified
        context.go(AppRoutes.addBaby);
      }
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showError(context, 'Gagal mendaftar: $e');
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Kembali',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go(AppRoutes.login),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Title Header
                  Text(
                    'Buat Akun Baru',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.baloo2(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Lengkapi formulir di bawah ini untuk memulai',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Full Name Field
                  LabeledTextField(
                    label: 'Nama Lengkap',
                    controller: _nameController,
                    hint: 'Nama Lengkap Anda',
                    keyboardType: TextInputType.name,
                    validator: (val) => AuthValidators.required(val, 'Nama lengkap'),
                  ),
                  const SizedBox(height: 16),

                  // Email Field
                  LabeledTextField(
                    label: 'Email',
                    controller: _emailController,
                    hint: 'nama@email.com',
                    keyboardType: TextInputType.emailAddress,
                    validator: AuthValidators.email,
                  ),
                  const SizedBox(height: 16),

                  // Phone Number Field
                  LabeledTextField(
                    label: 'Nomor HP',
                    controller: _phoneController,
                    hint: '081234567890',
                    keyboardType: TextInputType.phone,
                    validator: (val) => AuthValidators.required(val, 'Nomor HP'),
                  ),
                  const SizedBox(height: 16),

                  // City Field
                  LabeledTextField(
                    label: 'Kota Tempat Tinggal',
                    controller: _cityController,
                    hint: 'Contoh: Jakarta',
                    validator: (val) => AuthValidators.required(val, 'Kota'),
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  LabeledTextField(
                    label: 'Password',
                    controller: _passwordController,
                    hint: '••••••••',
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.darkText,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    validator: AuthValidators.password,
                  ),
                  const SizedBox(height: 16),

                  // Confirm Password Field
                  LabeledTextField(
                    label: 'Konfirmasi Password',
                    controller: _confirmPasswordController,
                    hint: '••••••••',
                    obscureText: _obscureConfirmPassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.darkText,
                      ),
                      onPressed: () => setState(() =>
                          _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                    validator: (val) => AuthValidators.confirmPassword(
                      val,
                      _passwordController.text,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Register Button
                  NeoButton(
                    label: 'Daftar',
                    isLoading: _isLoading,
                    onPressed: _handleRegister,
                    backgroundColor: AppColors.primary,
                  ),
                  const SizedBox(height: 20),

                  // Link to Login Screen
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Sudah punya akun? ',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.go(AppRoutes.login),
                        child: Text(
                          'Masuk',
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
