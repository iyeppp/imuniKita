import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imunikita/core/constants/health_gejala.dart';
import 'package:imunikita/core/utils/notification_helper.dart';
import 'package:imunikita/features/immunization/domain/entities/vaccine_schedule_entity.dart';
import 'package:imunikita/widgets/app_bottom_nav_bar.dart';
import 'package:imunikita/widgets/baby_avatar.dart';
import 'package:imunikita/widgets/custom_text_field.dart';
import 'package:imunikita/widgets/empty_state_widget.dart';
import 'package:imunikita/widgets/error_state_widget.dart';
import 'package:imunikita/widgets/loading_overlay.dart';
import 'package:imunikita/widgets/section_header.dart';
import 'package:imunikita/widgets/status_badge.dart';
import 'package:imunikita/widgets/vaccine_card.dart';

/// Test Temuan #49 — smoke test komponen UI global di `lib/widgets/`
/// (sebelumnya hanya `ConfirmDialog` yang punya test).
void main() {
  Widget bungkus(Widget child) => MaterialApp(home: Scaffold(body: child));

  VaccineScheduleEntity jadwal({String status = VaccineStatus.belum}) =>
      VaccineScheduleEntity(
        scheduleId: 's-1',
        babyId: 'baby-1',
        namaVaksin: 'BCG',
        deskripsi: 'Melindungi dari TBC berat.',
        usiaBulanTarget: 1,
        tanggalTarget: DateTime(2026, 3, 10),
        status: status,
      );

  group('StatusBadge', () {
    testWidgets('menampilkan label', (tester) async {
      await tester.pumpWidget(
        bungkus(const StatusBadge(label: 'SELESAI', color: Colors.green)),
      );
      expect(find.text('SELESAI'), findsOneWidget);
    });

    testWidgets('menampilkan ikon bila diberikan', (tester) async {
      await tester.pumpWidget(
        bungkus(
          const StatusBadge(
            label: 'Aktif',
            color: Colors.green,
            icon: Icons.check_circle,
          ),
        ),
      );
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });
  });

  group('EmptyStateWidget', () {
    testWidgets('menampilkan judul, pesan, dan aksi', (tester) async {
      var dipanggil = false;
      await tester.pumpWidget(
        bungkus(
          EmptyStateWidget(
            title: 'Belum ada profil anak',
            message: 'Tambahkan dulu, ya.',
            actionLabel: 'Tambah',
            onAction: () => dipanggil = true,
          ),
        ),
      );

      expect(find.text('Belum ada profil anak'), findsOneWidget);
      expect(find.text('Tambahkan dulu, ya.'), findsOneWidget);

      await tester.tap(find.text('Tambah'));
      expect(dipanggil, isTrue);
    });

    testWidgets('tanpa aksi tidak menampilkan tombol', (tester) async {
      await tester.pumpWidget(bungkus(const EmptyStateWidget(title: 'Kosong')));
      expect(find.byType(ElevatedButton), findsNothing);
    });
  });

  group('ErrorStateWidget', () {
    testWidgets('menampilkan pesan dan tombol coba lagi', (tester) async {
      var retry = 0;
      await tester.pumpWidget(
        bungkus(
          ErrorStateWidget(
            message: 'Gagal memuat data',
            onRetry: () => retry++,
          ),
        ),
      );

      expect(find.text('Terjadi Kesalahan'), findsOneWidget);
      expect(find.text('Gagal memuat data'), findsOneWidget);

      await tester.tap(find.text('Coba Lagi'));
      expect(retry, 1);
    });

    testWidgets('varian compact tetap menampilkan pesan', (tester) async {
      await tester.pumpWidget(
        bungkus(
          const ErrorStateWidget(message: 'error ringkas', compact: true),
        ),
      );
      expect(find.text('error ringkas'), findsOneWidget);
    });
  });

  group('SectionHeader', () {
    testWidgets('menampilkan judul tanpa aksi', (tester) async {
      await tester.pumpWidget(
        bungkus(const SectionHeader(title: 'Menu Utama')),
      );
      expect(find.text('Menu Utama'), findsOneWidget);
      expect(find.byType(TextButton), findsNothing);
    });

    testWidgets('menampilkan dan memicu aksi', (tester) async {
      var diklik = false;
      await tester.pumpWidget(
        bungkus(
          SectionHeader(
            title: 'Jadwal Terdekat',
            actionLabel: 'Buka',
            actionIcon: Icons.calendar_month,
            onAction: () => diklik = true,
          ),
        ),
      );

      await tester.tap(find.text('Buka'));
      expect(diklik, isTrue);
    });
  });

  group('CustomTextField', () {
    testWidgets('menampilkan label dan meneruskan input', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        bungkus(
          CustomTextField(
            label: 'Nama Lengkap',
            controller: controller,
            hint: 'Nama',
          ),
        ),
      );

      expect(find.text('Nama Lengkap'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), 'Aira');
      expect(controller.text, 'Aira');
    });

    testWidgets('menjalankan validator saat disubmit', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        bungkus(
          Form(
            child: CustomTextField(
              label: 'Nama',
              controller: controller,
              validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
            ),
          ),
        ),
      );

      final state = tester.state<FormState>(find.byType(Form));
      expect(state.validate(), isFalse);
      await tester.pump();
      expect(find.text('Wajib diisi'), findsOneWidget);
    });
  });

  group('BabyAvatar', () {
    testWidgets('menampilkan inisial nama bila tanpa foto', (tester) async {
      await tester.pumpWidget(bungkus(const BabyAvatar(name: 'aira')));
      expect(find.text('A'), findsOneWidget);
    });

    testWidgets('nama kosong memakai "?"', (tester) async {
      await tester.pumpWidget(bungkus(const BabyAvatar(name: '   ')));
      expect(find.text('?'), findsOneWidget);
    });
  });

  group('LoadingOverlay & AppLoadingIndicator', () {
    testWidgets('menampilkan indikator saat loading', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoadingOverlay(isLoading: true, child: Text('konten')),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('menyembunyikan indikator saat tidak loading', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoadingOverlay(isLoading: false, child: Text('konten')),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('konten'), findsOneWidget);
    });

    testWidgets('AppLoadingIndicator menampilkan pesan opsional', (
      tester,
    ) async {
      await tester.pumpWidget(
        bungkus(const AppLoadingIndicator(message: 'Menyimpan…')),
      );
      expect(find.text('Menyimpan…'), findsOneWidget);
    });
  });

  group('VaccineCard', () {
    testWidgets('menampilkan nama vaksin, tanggal, dan menerima tap', (
      tester,
    ) async {
      var ditap = false;
      await tester.pumpWidget(
        bungkus(
          VaccineCard(
            schedule: jadwal(),
            onTap: () => ditap = true,
            trailing: const StatusBadge(label: 'BELUM', color: Colors.teal),
          ),
        ),
      );

      expect(find.text('BCG'), findsOneWidget);
      expect(find.text('BELUM'), findsOneWidget);
      expect(find.textContaining('10 Maret 2026'), findsOneWidget);

      await tester.tap(find.text('BCG'));
      expect(ditap, isTrue);
    });

    testWidgets('menampilkan tanggal realisasi saat sudah selesai', (
      tester,
    ) async {
      final selesai = jadwal(status: VaccineStatus.selesai);
      await tester.pumpWidget(
        bungkus(
          VaccineCard(
            schedule: VaccineScheduleEntity(
              scheduleId: selesai.scheduleId,
              babyId: selesai.babyId,
              namaVaksin: selesai.namaVaksin,
              deskripsi: selesai.deskripsi,
              usiaBulanTarget: selesai.usiaBulanTarget,
              tanggalTarget: selesai.tanggalTarget,
              status: VaccineStatus.selesai,
              tanggalRealisasi: DateTime(2026, 3, 12),
            ),
          ),
        ),
      );

      expect(find.textContaining('Diberikan: 12 Maret 2026'), findsOneWidget);
    });
  });

  group('AppBottomNavBar', () {
    testWidgets('menampilkan 5 tab utama', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: AppBottomNavBar(currentIndex: 0)),
      );

      for (final label in [
        'Home',
        'Kalender',
        'Faskes',
        'ImuniBot',
        'Profil',
      ]) {
        expect(find.text(label), findsOneWidget);
      }
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('menandai tab aktif sesuai currentIndex', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: AppBottomNavBar(currentIndex: 3)),
      );
      final nav = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(nav.currentIndex, 3);
    });
  });

  group('Konstanta gejala bersama (#47)', () {
    test('berisi 6 gejala dan tidak duplikat', () {
      expect(HealthGejala.daftar, hasLength(6));
      expect(HealthGejala.daftar.toSet().length, HealthGejala.daftar.length);
    });

    test('id notifikasi H-7 dan H-1 berbeda untuk jadwal sama', () {
      expect(
        NotificationHelper.notificationId('s-1', 7),
        isNot(NotificationHelper.notificationId('s-1', 1)),
      );
    });
  });
}
