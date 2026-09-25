import 'package:flutter_test/flutter_test.dart';
import 'package:imunikita/core/utils/age_calculator.dart';

/// Test Temuan #36 — perhitungan usia harus benar untuk tanggal lahir akhir
/// bulan (29–31) yang sebelumnya menghasilkan `days` negatif.
void main() {
  group('AgeCalculator.breakdown — kasus akhir bulan (#36)', () {
    test('31 Jan → 1 Mar = 1 bulan 1 hari (bukan −2 hari)', () {
      final usia = AgeCalculator.breakdown(
        DateTime(2026, 1, 31),
        now: DateTime(2026, 3, 1),
      );

      expect(usia.years, 0);
      expect(usia.months, 1);
      expect(usia.days, 1);
      expect(usia.days, isNonNegative);
      expect(usia.totalMonths, 1);
      expect(usia.totalDays, 29);
    });

    test('31 Jan → 28 Feb = 1 bulan 0 hari', () {
      final usia = AgeCalculator.breakdown(
        DateTime(2026, 1, 31),
        now: DateTime(2026, 2, 28),
      );

      expect(usia.months, 1);
      expect(usia.days, 0);
    });

    test('31 Jan → 27 Feb = 0 bulan 27 hari', () {
      final usia = AgeCalculator.breakdown(
        DateTime(2026, 1, 31),
        now: DateTime(2026, 2, 27),
      );

      expect(usia.months, 0);
      expect(usia.days, 27);
    });

    test('29 Feb (kabisat) → 1 Mar = 0 bulan 1 hari', () {
      final usia = AgeCalculator.breakdown(
        DateTime(2024, 2, 29),
        now: DateTime(2024, 3, 1),
      );

      expect(usia.months, 0);
      expect(usia.days, 1);
    });

    test('tanggal 30: 30 Apr → 30 Mei = tepat 1 bulan', () {
      final usia = AgeCalculator.breakdown(
        DateTime(2026, 4, 30),
        now: DateTime(2026, 5, 30),
      );

      expect(usia.months, 1);
      expect(usia.days, 0);
    });
  });

  group('AgeCalculator.breakdown — kasus umum', () {
    test('10 Jan → 10 Mar = 2 bulan 0 hari', () {
      final usia = AgeCalculator.breakdown(
        DateTime(2026, 1, 10),
        now: DateTime(2026, 3, 10),
      );

      expect(usia.years, 0);
      expect(usia.months, 2);
      expect(usia.days, 0);
      expect(usia.totalMonths, 2);
    });

    test('10 Jan 2025 → 10 Mar 2026 = 1 tahun 2 bulan', () {
      final usia = AgeCalculator.breakdown(
        DateTime(2025, 1, 10),
        now: DateTime(2026, 3, 10),
      );

      expect(usia.years, 1);
      expect(usia.months, 2);
      expect(usia.days, 0);
      expect(usia.totalMonths, 14);
    });

    test('hari ini == tanggal lahir → 0 bulan 0 hari', () {
      final usia = AgeCalculator.breakdown(
        DateTime(2026, 6, 15),
        now: DateTime(2026, 6, 15),
      );

      expect(usia.totalMonths, 0);
      expect(usia.days, 0);
    });

    test('tanggal lahir di masa depan → semua nol', () {
      final usia = AgeCalculator.breakdown(
        DateTime(2026, 7, 1),
        now: DateTime(2026, 6, 1),
      );

      expect(usia.years, 0);
      expect(usia.months, 0);
      expect(usia.days, 0);
      expect(usia.totalDays, 0);
    });

    test('totalDays = selisih hari sebenarnya', () {
      final lahir = DateTime(2026, 1, 1);
      final sekarang = DateTime(2026, 2, 1);

      final usia = AgeCalculator.breakdown(lahir, now: sekarang);

      expect(usia.totalDays, sekarang.difference(lahir).inDays);
      expect(usia.days, isNonNegative);
    });
  });

  group('AgeCalculator.label', () {
    test('menyusun label tahun/bulan/hari', () {
      expect(
        AgeCalculator.label(DateTime(2025, 1, 10), now: DateTime(2026, 3, 10)),
        '1 tahun 2 bulan',
      );
      expect(
        AgeCalculator.label(DateTime(2026, 1, 1), now: DateTime(2026, 9, 13)),
        '8 bulan 12 hari',
      );
      expect(
        AgeCalculator.label(DateTime(2026, 6, 10), now: DateTime(2026, 6, 15)),
        '5 hari',
      );
    });
  });

  group('AgeCalculator.addMonths', () {
    test('mengamankan akhir bulan', () {
      expect(
        AgeCalculator.addMonths(DateTime(2026, 1, 31), 1),
        DateTime(2026, 2, 28),
      );
      expect(
        AgeCalculator.addMonths(DateTime(2026, 3, 31), 1),
        DateTime(2026, 4, 30),
      );
      expect(
        AgeCalculator.addMonths(DateTime(2024, 1, 31), 1),
        DateTime(2024, 2, 29),
      );
    });
  });
}
