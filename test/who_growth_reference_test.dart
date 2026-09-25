import 'package:flutter_test/flutter_test.dart';
import 'package:imunikita/core/constants/who_growth_reference.dart';

/// Test Temuan #8 — tabel referensi WHO (median, −2SD, +2SD) yang dipakai
/// grafik pertumbuhan, plus interpolasi antar bulan.
void main() {
  final daftarSeri = <String, WhoSeries>{
    'BB laki-laki': WhoGrowthReference.bbLaki,
    'BB perempuan': WhoGrowthReference.bbPerempuan,
    'TB laki-laki': WhoGrowthReference.tbLaki,
    'TB perempuan': WhoGrowthReference.tbPerempuan,
    'LK laki-laki': WhoGrowthReference.lkLaki,
    'LK perempuan': WhoGrowthReference.lkPerempuan,
  };

  group('WhoGrowthReference — struktur tabel', () {
    test('semua seri berisi 25 titik (usia 0–24 bulan)', () {
      for (final seri in daftarSeri.values) {
        expect(seri.median, hasLength(25));
        expect(seri.minus2Sd, hasLength(25));
        expect(seri.plus2Sd, hasLength(25));
        expect(seri.maxMonth, 24);
      }
    });

    test('median selalu di antara −2SD dan +2SD', () {
      for (final entry in daftarSeri.entries) {
        final seri = entry.value;
        for (var bulan = 0; bulan <= seri.maxMonth; bulan++) {
          expect(
            seri.minus2Sd[bulan],
            lessThan(seri.median[bulan]),
            reason: '${entry.key} bulan $bulan: −2SD < median',
          );
          expect(
            seri.median[bulan],
            lessThan(seri.plus2Sd[bulan]),
            reason: '${entry.key} bulan $bulan: median < +2SD',
          );
        }
      }
    });

    test('ketiga kurva naik monoton seiring usia', () {
      for (final entry in daftarSeri.entries) {
        final seri = entry.value;
        for (var bulan = 1; bulan <= seri.maxMonth; bulan++) {
          expect(
            seri.median[bulan],
            greaterThanOrEqualTo(seri.median[bulan - 1]),
            reason: '${entry.key} median bulan $bulan',
          );
          expect(
            seri.minus2Sd[bulan],
            greaterThanOrEqualTo(seri.minus2Sd[bulan - 1]),
            reason: '${entry.key} −2SD bulan $bulan',
          );
          expect(
            seri.plus2Sd[bulan],
            greaterThanOrEqualTo(seri.plus2Sd[bulan - 1]),
            reason: '${entry.key} +2SD bulan $bulan',
          );
        }
      }
    });
  });

  group('WhoGrowthReference — interpolasi', () {
    test('tepat pada titik tabel', () {
      final seri = WhoGrowthReference.bbLaki;
      expect(seri.medianAt(0), seri.median.first);
      expect(seri.medianAt(24), seri.median.last);
      expect(seri.medianAt(6), seri.median[6]);
    });

    test('di antara dua bulan memakai interpolasi linear', () {
      final seri = WhoGrowthReference.tbLaki;
      final tengah = seri.medianAt(0.5)!;
      expect(tengah, greaterThan(seri.median[0]));
      expect(tengah, lessThan(seri.median[1]));
    });

    test('di luar rentang tabel mengembalikan null', () {
      final seri = WhoGrowthReference.lkPerempuan;
      expect(seri.medianAt(-1), isNull);
      expect(seri.medianAt(24.5), isNull);
      expect(seri.minus2SdAt(30), isNull);
    });
  });

  group('WhoGrowthReference.forMode', () {
    test('memilih seri sesuai mode & jenis kelamin', () {
      expect(
        WhoGrowthReference.forMode('BB', isLakiLaki: true),
        same(WhoGrowthReference.bbLaki),
      );
      expect(
        WhoGrowthReference.forMode('BB', isLakiLaki: false),
        same(WhoGrowthReference.bbPerempuan),
      );
      expect(
        WhoGrowthReference.forMode('TB', isLakiLaki: false),
        same(WhoGrowthReference.tbPerempuan),
      );
      expect(
        WhoGrowthReference.forMode('LK', isLakiLaki: true),
        same(WhoGrowthReference.lkLaki),
      );
    });

    test('mode tak dikenal mengembalikan null', () {
      expect(WhoGrowthReference.forMode('XX', isLakiLaki: true), isNull);
    });
  });
}
