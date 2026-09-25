import '../repositories/i_auth_repository.dart';

/// Status sesi & onboarding untuk routing awal (Splash Screen).
class AuthState {
  const AuthState({required this.loggedIn, required this.seenOnboarding});

  final bool loggedIn;
  final bool seenOnboarding;
}

/// Baca status sesi + onboarding dalam satu panggilan.
class CheckAuthStateUseCase {
  const CheckAuthStateUseCase(this._repository);

  final IAuthRepository _repository;

  Future<AuthState> execute() async {
    final loggedIn = await _repository.isLoggedIn();
    final seen = await _repository.hasSeenOnboarding();
    return AuthState(loggedIn: loggedIn, seenOnboarding: seen);
  }
}

/// Tandai onboarding sudah pernah dilewati (dipakai OnboardingScreen).
class MarkOnboardingSeenUseCase {
  const MarkOnboardingSeenUseCase(this._repository);

  final IAuthRepository _repository;

  Future<void> execute() => _repository.markOnboardingSeen();
}
