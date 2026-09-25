import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imunikita/features/faskes/data/datasources/faskes_mock_datasource.dart';
import 'package:imunikita/features/faskes/presentation/screens/faskes_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const datasource = FaskesMockDatasource();

  group('FaskesMockDatasource — data keseluruhan', () {
    test('memuat 14 faskes mock', () {
      expect(datasource.getAll().length, 14);
    });

    test('mencakup 3 kota: Jakarta, Bandung, dan Surabaya', () {
      final semua = datasource.getAll();

      for (final kota in ['Jakarta', 'Bandung', 'Surabaya']) {
        expect(
          semua.any((f) => f.kota.startsWith(kota)),
          isTrue,
          reason: 'tidak ada faskes di $kota',
        );
      }
    });

    test('setiap id unik', () {
      final semua = datasource.getAll();
      final id = semua.map((f) => f.id).toSet();
      expect(id.length, semua.length);
    });

    test('setiap faskes punya tipe yang dikenal', () {
      final tipeDikenal = FaskesTipe.filter.toSet();
      for (final f in datasource.getAll()) {
        expect(tipeDikenal, contains(f.tipe));
      }
    });
  });

  group('FaskesMockDatasource — filter tipe', () {
    test('filter RS mengembalikan 4 rumah sakit', () {
      final rs = datasource.getByTipe(FaskesTipe.rs);
      expect(rs.length, 4);
      expect(rs.every((f) => f.tipe == FaskesTipe.rs), isTrue);
    });

    test('filter Puskesmas mengembalikan 4 puskesmas', () {
      final pkm = datasource.getByTipe(FaskesTipe.puskesmas);
      expect(pkm.length, 4);
      expect(pkm.every((f) => f.tipe == FaskesTipe.puskesmas), isTrue);
    });

    test('filter Klinik mengembalikan 3 klinik', () {
      final klinik = datasource.getByTipe(FaskesTipe.klinik);
      expect(klinik.length, 3);
      expect(klinik.every((f) => f.tipe == FaskesTipe.klinik), isTrue);
    });

    test('filter Apotek mengembalikan 3 apotek', () {
      final apotek = datasource.getByTipe(FaskesTipe.apotek);
      expect(apotek.length, 3);
      expect(apotek.every((f) => f.tipe == FaskesTipe.apotek), isTrue);
    });

    test('filter Semua mengembalikan seluruh faskes', () {
      expect(datasource.getByTipe(FaskesTipe.semua).length, 14);
    });

    test('filter tipe tak dikenal mengembalikan daftar kosong', () {
      expect(datasource.getByTipe('Tipe Tidak Ada'), isEmpty);
    });
  });

  group('FaskesModel — validitas data', () {
    test('setiap faskes punya koordinat valid di wilayah Indonesia', () {
      for (final f in datasource.getAll()) {
        expect(f.lat, inInclusiveRange(-11, 6), reason: '${f.nama} lat');
        expect(f.lng, inInclusiveRange(95, 141), reason: '${f.nama} lng');
      }
    });

    test('setiap faskes punya telepon dan jam operasional', () {
      for (final f in datasource.getAll()) {
        expect(f.telepon, startsWith('+'), reason: f.nama);
        expect(f.telepon, matches(RegExp(r'^\+\d+$')), reason: f.nama);
        expect(f.jamOperasional.trim(), isNotEmpty, reason: f.nama);
        expect(f.nama.trim(), isNotEmpty);
        expect(f.alamat.trim(), isNotEmpty);
      }
    });
  });

  group('FaskesTipe', () {
    test('filter berisi 5 tipe sesuai urutan tampil', () {
      expect(FaskesTipe.filter, [
        FaskesTipe.semua,
        FaskesTipe.rs,
        FaskesTipe.puskesmas,
        FaskesTipe.klinik,
        FaskesTipe.apotek,
      ]);
      expect(FaskesTipe.filter.length, 5);
    });
  });

  group('FaskesScreen — widget', () {
    testWidgets('menampilkan faskes pertama pada daftar', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: FaskesScreen())),
      );
      await tester.pump();

      expect(find.text('RSUPN Dr. Cipto Mangunkusumo'), findsOneWidget);
    });

    testWidgets('pencarian teks menyaring daftar berdasarkan kota', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: FaskesScreen())),
      );
      await tester.pump();

      expect(find.text('RSUPN Dr. Cipto Mangunkusumo'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'bandung');
      await tester.pump();

      expect(find.text('RSUP Dr. Hasan Sadikin'), findsOneWidget);
      expect(find.text('RSUPN Dr. Cipto Mangunkusumo'), findsNothing);
    });

    testWidgets('chip filter Apotek hanya menampilkan apotek', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: FaskesScreen())),
      );
      await tester.pump();

      await tester.tap(find.widgetWithText(FilterChip, FaskesTipe.apotek));
      await tester.pump();

      expect(find.text('Apotek Kimia Farma Salemba'), findsOneWidget);
      expect(find.text('RSUPN Dr. Cipto Mangunkusumo'), findsNothing);
    });
  });
}
