import 'package:flutter_test/flutter_test.dart';
import 'package:imunikita/features/education/data/datasources/education_mock_datasource.dart';
import 'package:imunikita/features/education/data/models/quiz_score_model.dart';

void main() {
  const datasource = EducationMockDatasource();

  group('EducationMockDatasource — artikel', () {
    test('memuat seluruh artikel tanpa filter', () {
      expect(datasource.getArtikel().length, greaterThanOrEqualTo(6));
    });

    test('filter kategori hanya mengembalikan kategori tersebut', () {
      final mpasi = datasource.getArtikel(kategori: EducationKategori.mpasi);
      expect(mpasi, isNotEmpty);
      expect(mpasi.every((a) => a.kategori == EducationKategori.mpasi), isTrue);
    });

    test('getArtikelById mengembalikan artikel yang cocok', () {
      final artikel = datasource.getArtikelById('art-01');
      expect(artikel, isNotNull);
      expect(artikel!.articleId, 'art-01');
    });

    test('getArtikelById mengembalikan null untuk id tak dikenal', () {
      expect(datasource.getArtikelById('art-tidak-ada'), isNull);
    });

    test('artikel terkait tidak memuat artikel itu sendiri & sesuai limit', () {
      final artikel = datasource.getArtikelById('art-01')!;
      final terkait = datasource.getArtikelTerkait(artikel, limit: 3);

      expect(terkait.length, 3);
      expect(terkait.any((a) => a.articleId == artikel.articleId), isFalse);
    });
  });

  group('EducationMockDatasource — video & kuis', () {
    test('video punya durasi valid dan URL tonton', () {
      final video = datasource.getVideo();
      expect(video, isNotEmpty);
      for (final item in video) {
        expect(item.durasiDetik, greaterThan(0));
        expect(item.tontonUrl, startsWith('https://www.youtube.com/'));
        expect(item.durasiLabel, matches(RegExp(r'^\d+:\d{2}$')));
      }
    });

    test('setiap soal kuis punya 4 pilihan dan index jawaban valid', () {
      final kuis = datasource.getKuis();
      expect(kuis, isNotEmpty);

      for (final item in kuis) {
        expect(item.totalSoal, greaterThan(0));
        for (final soal in item.soal) {
          expect(soal.pilihan.length, 4);
          expect(soal.indexJawabanBenar, inInclusiveRange(0, 3));
          expect(soal.penjelasan, isNotEmpty);
        }
      }
    });

    test('getKuisById mengembalikan kuis yang cocok', () {
      final kuis = datasource.getKuisById('quiz-01');
      expect(kuis?.judul, isNotEmpty);
      expect(datasource.getKuisById('quiz-tidak-ada'), isNull);
    });

    test('filter kategori kuis bekerja', () {
      final kuis = datasource.getKuis(kategori: EducationKategori.nutrisi);
      expect(kuis, isNotEmpty);
      expect(
        kuis.every((q) => q.kategori == EducationKategori.nutrisi),
        isTrue,
      );
    });
  });

  group('QuizScoreModel', () {
    test('persentase dihitung dari skor / total soal', () {
      final skor = QuizScoreModel(
        quizId: 'quiz-01',
        skor: 4,
        totalSoal: 5,
        tanggalPengerjaan: DateTime(2026, 9, 24),
      );
      expect(skor.persentase, 80);
    });

    test('persentase aman saat total soal nol', () {
      final skor = QuizScoreModel(
        quizId: 'quiz-01',
        skor: 0,
        totalSoal: 0,
        tanggalPengerjaan: DateTime(2026, 9, 24),
      );
      expect(skor.persentase, 0);
    });
  });
}
