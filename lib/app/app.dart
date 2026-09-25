import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/notification_service.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class ImuniKitaApp extends ConsumerWidget {
  const ImuniKitaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    // Fix Bug #6: daftarkan router ke NotificationService agar ketukan
    // notifikasi bisa menavigasi ke VaccineDetailScreen.
    NotificationService.setRouter(router);

    return MaterialApp.router(
      title: 'ImuniKita',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}