import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz_loc;
import 'package:workmanager/workmanager.dart';

import 'app/app.dart';
import 'core/services/notification_service.dart';

/// Entry point WorkManager — harus top-level function
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // TODO(Sprint 2): cek jadwal vaksin & kirim notifikasi H-7 / H-1
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inisialisasi Hive CE (local database)
  await Hive.initFlutter();

  // 2. Inisialisasi timezone — default WIB (UTC+7)
  tz.initializeTimeZones();
  tz_loc.setLocalLocation(tz_loc.getLocation('Asia/Jakarta'));

  // 3. Inisialisasi NotificationService
  await NotificationService.init();

  // 4. Inisialisasi WorkManager untuk background check
  await Workmanager().initialize(
    callbackDispatcher,
  );

  runApp(
    const ProviderScope(
      child: ImuniKitaApp(),
    ),
  );
}
