import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/services/notification_service.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class ImuniKitaApp extends ConsumerStatefulWidget {
  const ImuniKitaApp({super.key});

  @override
  ConsumerState<ImuniKitaApp> createState() => _ImuniKitaAppState();
}

class _ImuniKitaAppState extends ConsumerState<ImuniKitaApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    // Fix Temuan #43: registrasi router ke NotificationService (untuk navigasi
    // dari ketukan notifikasi) dilakukan sekali di `initState`, bukan di dalam
    // `build()` yang bisa dipanggil berkali-kali.
    _router = ref.read(appRouterProvider);
    NotificationService.setRouter(_router);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ImuniKita',
      theme: AppTheme.lightTheme,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
