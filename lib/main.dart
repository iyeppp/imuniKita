import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz_loc;

import 'app/app.dart';
import 'core/errors/failures.dart';
import 'core/firebase/firebase_bootstrap.dart';
import 'core/services/notification_service.dart';
import 'core/services/push_service.dart';
import 'hive_registrar.g.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 0.
  try {
    await FirebaseBootstrap.initialize();
  } on FirebaseConfigFailure catch (failure) {
    runApp(_BootstrapErrorApp(message: failure.message));
    return;
  }

  // 1.
  await Hive.initFlutter();
  Hive.registerAdapters();

  // 2.
  tz.initializeTimeZones();
  tz_loc.setLocalLocation(tz_loc.getLocation('Asia/Jakarta'));

  // 3.
  await NotificationService.init();

  // 4.
  await PushService.instance.init();

  runApp(const ProviderScope(child: ImuniKitaApp()));
}

/// Layar darurat saat konfigurasi Firebase belum benar.
class _BootstrapErrorApp extends StatelessWidget {
  const _BootstrapErrorApp({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.local_fire_department,
                  size: 48,
                  color: Colors.deepOrange,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Konfigurasi Firebase belum benar',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                SelectableText(message),
                const SizedBox(height: 16),
                const Text(
                  'Setelah kredensial asli dipasang, jalankan ulang aplikasi.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
