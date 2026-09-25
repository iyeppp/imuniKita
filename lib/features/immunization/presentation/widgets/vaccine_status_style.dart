import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/entities/vaccine_schedule_entity.dart';

/// Pemetaan status jadwal vaksin → warna (satu sumber kebenaran).
///
/// Fix Bug #33: sebelumnya mapping ini ditulis ulang di Kalender, Timeline, dan
/// Detail dengan hasil yang **tidak konsisten** — `BELUM` berwarna kuning di
/// daftar Kalender tetapi teal di Timeline/Detail. Kini semuanya memakai helper
/// ini (`BELUM` → teal, selaras dengan marker di Kalender & `statusScheduled`).
abstract class VaccineStatusStyle {
  static Color color(String status) {
    switch (status) {
      case VaccineStatus.selesai:
        return AppColors.green;
      case VaccineStatus.terlewat:
        return AppColors.red;
      default:
        return AppColors.statusScheduled;
    }
  }
}
