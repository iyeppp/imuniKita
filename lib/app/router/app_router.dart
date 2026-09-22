import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
<<<<<<< Updated upstream
=======
import '../../features/baby_profile/presentation/screens/add_baby_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/immunization/presentation/screens/calendar_screen.dart';
import '../../features/immunization/presentation/screens/vaccine_timeline_screen.dart';
import '../../features/immunization/presentation/screens/vaccine_detail_screen.dart';
import '../../features/growth/presentation/screens/growth_chart_screen.dart';
import '../../features/growth/presentation/screens/add_growth_record_screen.dart';
import '../../features/health_journal/presentation/screens/journal_list_screen.dart';
import '../../features/health_journal/presentation/screens/add_journal_screen.dart';
>>>>>>> Stashed changes

// ---------------------------------------------------------------------------
// Placeholder — diganti dengan screen asli saat Sprint 1–4
// ---------------------------------------------------------------------------
class _PlaceholderScreen extends StatelessWidget {
  final String label;
  const _PlaceholderScreen(this.label);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(label)),
      body: Center(
        child: Text(
          '$label\n(coming soon)',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Route path constants
// ---------------------------------------------------------------------------
abstract class AppRoutes {
  // Auth & Onboarding
  static const splash      = '/';
  static const onboarding  = '/onboarding';
  static const login       = '/login';
  static const register    = '/register';

  // Baby profile
  static const addBaby     = '/add-baby';

  // Main tabs
  static const dashboard   = '/dashboard';

  // Imunisasi & Kalender
  static const calendar         = '/calendar';
  static const vaccineTimeline  = '/calendar/timeline';
  static const vaccineDetail    = '/calendar/detail/:id';

  // Pertumbuhan
  static const growth    = '/growth';
  static const addGrowth = '/growth/add';

  // Jurnal Kesehatan
  static const journal    = '/journal';
  static const addJournal = '/journal/add';

  // Edukasi
  static const education     = '/education';
  static const articleDetail = '/education/article/:id';
  static const quiz          = '/education/quiz/:id';

  // Direktori Faskes
  static const faskes  = '/faskes';

  // Chatbot
  static const chatbot = '/chatbot';

  // Settings
  static const settings = '/settings';
}

// ---------------------------------------------------------------------------
// Router provider
// ---------------------------------------------------------------------------
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    routes: [
      // ── Auth & Onboarding ──────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, _) => const SplashScreen(),
      ),

      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, _) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (_, _) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (_, _) => const RegisterScreen(),
      ),

      // ── Baby Profile ───────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.addBaby,
        builder: (_, _) => const _PlaceholderScreen('Tambah Profil Bayi'),
      ),

      // ── Dashboard ──────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (_, _) => const DashboardScreen(),
      ),

      // ── Imunisasi & Kalender (nested) ──────────────────────────────────
      GoRoute(
        path: AppRoutes.calendar,
        builder: (_, _) => const CalendarScreen(),
        routes: [
          GoRoute(
            path: 'timeline',
            builder: (_, _) => const VaccineTimelineScreen(),
          ),
          GoRoute(
            path: 'detail/:id',
            builder: (_, state) => VaccineDetailScreen(
              scheduleId: state.pathParameters['id'] ?? '',
            ),
          ),
        ],
      ),

      // ── Pertumbuhan (nested) ───────────────────────────────────────────
      GoRoute(
        path: AppRoutes.growth,
        builder: (_, _) => const GrowthChartScreen(),
        routes: [
          GoRoute(
            path: 'add',
            builder: (_, _) => const AddGrowthRecordScreen(),
          ),
        ],
      ),

      // ── Jurnal Kesehatan (nested) ──────────────────────────────────────
      GoRoute(
        path: AppRoutes.journal,
        builder: (_, _) => const JournalListScreen(),
        routes: [
          GoRoute(
            path: 'add',
            builder: (_, _) => const AddJournalScreen(),
          ),
        ],
      ),

      // ── Edukasi (nested) ───────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.education,
        builder: (_, _) => const _PlaceholderScreen('Education Hub'),
        routes: [
          GoRoute(
            path: 'article/:id',
            builder: (_, state) => _PlaceholderScreen(
              'Artikel — ${state.pathParameters['id']}',
            ),
          ),
          GoRoute(
            path: 'quiz/:id',
            builder: (_, state) => _PlaceholderScreen(
              'Kuis — ${state.pathParameters['id']}',
            ),
          ),
        ],
      ),

      // ── Direktori Faskes ───────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.faskes,
        builder: (_, _) => const _PlaceholderScreen('Direktori Faskes'),
      ),

      // ── Chatbot ────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.chatbot,
        builder: (_, _) => const _PlaceholderScreen('ImuniBot 🤖'),
      ),

      // ── Settings ───────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.settings,
        builder: (_, _) => const _PlaceholderScreen('Settings & Profil'),
      ),
    ],
  );
});
