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

  final daftarSeriOver24 = <String, WhoSeries>{
    'BB laki-laki (>24 bln)': WhoGrowthReference.bbLakiOver24,
    'BB perempuan (>24 bln)': WhoGrowthReference.bbPerempuanOver24,
    'TB laki-laki (>24 bln)': WhoGrowthReference.tbLakiOver24,
    'TB perempuan (>24 bln)': WhoGrowthReference.tbPerempuanOver24,
    'LK laki-laki (>24 bln)': WhoGrowthReference.lkLakiOver24,
    'LK perempuan (>24 bln)': WhoGrowthReference.lkPerempuanOver24,
  };

  group('WhoGrowthReference — struktur tabel (0–24 bulan)', () {
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

  group('WhoGrowthReference — struktur tabel (>24 bulan)', () {
    test('semua seri >24 bulan berisi 37 titik (24–60 bulan)', () {
      for (final seri in daftarSeriOver24.values) {
        expect(seri.startMonth, 24);
        expect(seri.median, hasLength(37));
        expect(seri.minus2Sd, hasLength(37));
        expect(seri.plus2Sd, hasLength(37));
        expect(seri.maxMonth, 60);
      }
    });

    test('median selalu di antara −2SD dan +2SD pada >24 bulan', () {
      for (final entry in daftarSeriOver24.entries) {
        final seri = entry.value;
        for (var idx = 0; idx < seri.median.length; idx++) {
          final bulan = seri.startMonth + idx;
          expect(
            seri.minus2Sd[idx],
            lessThan(seri.median[idx]),
            reason: '${entry.key} bulan $bulan: −2SD < median',
          );
          expect(
            seri.median[idx],
            lessThan(seri.plus2Sd[idx]),
            reason: '${entry.key} bulan $bulan: median < +2SD',
          );
        }
      }
    });

    test('ketiga kurva >24 bulan naik monoton seiring usia', () {
      for (final entry in daftarSeriOver24.entries) {
        final seri = entry.value;
        for (var idx = 1; idx < seri.median.length; idx++) {
          final bulan = seri.startMonth + idx;
          expect(
            seri.median[idx],
            greaterThanOrEqualTo(seri.median[idx - 1]),
            reason: '${entry.key} median bulan $bulan',
          );
          expect(
            seri.minus2Sd[idx],
            greaterThanOrEqualTo(seri.minus2Sd[idx - 1]),
            reason: '${entry.key} −2SD bulan $bulan',
          );
          expect(
            seri.plus2Sd[idx],
            greaterThanOrEqualTo(seri.plus2Sd[idx - 1]),
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

    test('interpolasi pada seri >24 bulan', () {
      final seri = WhoGrowthReference.tbLakiOver24;
      expect(seri.medianAt(24), 87.8);
      expect(seri.medianAt(60), 111.5);
      final tengah = seri.medianAt(24.5)!;
      expect(tengah, greaterThan(87.8));
      expect(tengah, lessThan(88.8));
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

      final seriOver24 = WhoGrowthReference.lkPerempuanOver24;
      expect(seriOver24.medianAt(23), isNull);
      expect(seriOver24.medianAt(61), isNull);
    });
  });

  group('WhoGrowthReference.forMode', () {
    test('memilih seri sesuai mode & jenis kelamin (0–24 bulan)', () {
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

    test('memilih seri sesuai mode & jenis kelamin (>24 bulan)', () {
      expect(
        WhoGrowthReference.forMode('BB', isLakiLaki: true, over24: true),
        same(WhoGrowthReference.bbLakiOver24),
      );
      expect(
        WhoGrowthReference.forMode('BB', isLakiLaki: false, over24: true),
        same(WhoGrowthReference.bbPerempuanOver24),
      );
      expect(
        WhoGrowthReference.forMode('TB', isLakiLaki: false, over24: true),
        same(WhoGrowthReference.tbPerempuanOver24),
      );
      expect(
        WhoGrowthReference.forMode('LK', isLakiLaki: true, over24: true),
        same(WhoGrowthReference.lkLakiOver24),
      );
    });

    test('mode tak dikenal mengembalikan null', () {
      expect(WhoGrowthReference.forMode('XX', isLakiLaki: true), isNull);
      expect(
        WhoGrowthReference.forMode('XX', isLakiLaki: true, over24: true),
        isNull,
      );
    });
  });
}
