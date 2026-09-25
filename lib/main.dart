import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz_loc;

import 'app/app.dart';
import 'core/services/notification_service.dart';
import 'hive_registrar.g.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inisialisasi Hive CE (local database)
  await Hive.initFlutter();
  Hive.registerAdapters();

  // 2. Inisialisasi timezone — default WIB (UTC+7)
  tz.initializeTimeZones();
  tz_loc.setLocalLocation(tz_loc.getLocation('Asia/Jakarta'));

  // 3. Inisialisasi NotificationService
  //
  // Pengingat H-7/H-1 dijadwalkan sekali via `zonedSchedule` (AlarmManager),
  // lalu dipulihkan otomatis setelah reboot oleh `ScheduledNotificationBootReceiver`
  // di AndroidManifest. WorkManager tidak dipakai lagi (Temuan #6): normalisasi
  // status `TERLEWAT` sudah dilakukan saat data dibaca (`VaccineStatus.effective`),
  // sehingga task background harian tidak diperlukan.
  await NotificationService.init();

  runApp(const ProviderScope(child: ImuniKitaApp()));
}
