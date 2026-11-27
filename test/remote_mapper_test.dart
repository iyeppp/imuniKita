import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imunikita/features/baby_profile/data/mappers/baby_mapper.dart';
import 'package:imunikita/features/baby_profile/data/models/baby_model.dart';
import 'package:imunikita/features/baby_profile/domain/entities/baby_entity.dart';
import 'package:imunikita/features/education/data/mappers/quiz_score_mapper.dart';
import 'package:imunikita/features/education/data/models/quiz_score_model.dart';
import 'package:imunikita/features/growth/data/mappers/growth_record_mapper.dart';
import 'package:imunikita/features/growth/data/models/growth_record_model.dart';
import 'package:imunikita/features/health_journal/data/mappers/health_journal_mapper.dart';
import 'package:imunikita/features/health_journal/data/models/health_journal_model.dart';
import 'package:imunikita/features/immunization/data/mappers/vaccine_schedule_mapper.dart';
import 'package:imunikita/features/immunization/data/models/vaccine_schedule_model.dart';

void main() {
  group('BabyMapper (B4-1)', () {
    test('genderToFirestore mengonversi L/P ke Laki-laki/Perempuan', () {
      expect(BabyMapper.genderToFirestore(BabyGender.laki), 'Laki-laki');
      expect(BabyMapper.genderToFirestore('L'), 'Laki-laki');
      expect(BabyMapper.genderToFirestore('Laki-laki'), 'Laki-laki');

      expect(BabyMapper.genderToFirestore(BabyGender.perempuan), 'Perempuan');
      expect(BabyMapper.genderToFirestore('P'), 'Perempuan');
      expect(BabyMapper.genderToFirestore('Perempuan'), 'Perempuan');
    });

    test('genderFromFirestore mengonversi format Firestore kembali ke L/P', () {
      expect(BabyMapper.genderFromFirestore('Laki-laki'), BabyGender.laki);
      expect(BabyMapper.genderFromFirestore('L'), BabyGender.laki);

      expect(BabyMapper.genderFromFirestore('Perempuan'), BabyGender.perempuan);
      expect(BabyMapper.genderFromFirestore('P'), BabyGender.perempuan);
    });

    test('toFirestore menghasilkan Map yang valid dan schemaVersion 1', () {
      final now = DateTime(2026, 1, 15, 10, 30);
      final model = BabyModel(
        babyId: 'baby-001',
        userId: 'user-001',
        namaAnak: 'Ahmad Fauzi',
        tanggalLahir: DateTime(2025, 6, 1),
        jenisKelamin: BabyGender.laki,
        fotoProfilPath: '/data/local/photos/baby.jpg',
        createdAt: now,
      );

      final map = BabyMapper.toFirestore(model);

      expect(map['babyId'], 'baby-001');
      expect(map['userId'], 'user-001');
      expect(map['namaAnak'], 'Ahmad Fauzi');
      expect(map['tanggalLahir'], isA<Timestamp>());
      expect((map['tanggalLahir'] as Timestamp).toDate(), DateTime(2025, 6, 1));
      expect(map['jenisKelamin'], 'Laki-laki');
      expect(map['createdAt'], isA<Timestamp>());
      expect(map['updatedAt'], isA<Timestamp>());
      expect(map['schemaVersion'], 1);
      // Sesuai ADR 0001: fotoProfilPath tidak ada di Map Firestore
      expect(map.containsKey('fotoProfilPath'), isFalse);
    });

    test('fromFirestore dan toFirestore roundtrip konsisten', () {
      final birth = DateTime(2025, 10, 20);
      final created = DateTime(2025, 10, 21);
      final original = BabyModel(
        babyId: 'baby-roundtrip',
        userId: 'user-roundtrip',
        namaAnak: 'Nur Aisyah',
        tanggalLahir: birth,
        jenisKelamin: BabyGender.perempuan,
        createdAt: created,
      );

      final map = BabyMapper.toFirestore(original);
      final restored = BabyMapper.fromFirestore(map, 'baby-roundtrip');

      expect(restored.babyId, original.babyId);
      expect(restored.userId, original.userId);
      expect(restored.namaAnak, original.namaAnak);
      expect(restored.tanggalLahir, original.tanggalLahir);
      expect(restored.jenisKelamin, original.jenisKelamin);
      expect(restored.fotoProfilPath, isNull);
    });
  });

  group('VaccineScheduleMapper (B4-1)', () {
    test('toFirestore serialisasi 13 jadwal lengkap dan aman', () {
      final target = DateTime(2026, 2, 1);
      final realisasi = DateTime(2026, 2, 3);
      final model = VaccineScheduleModel(
        scheduleId: 'sch-001',
        babyId: 'baby-001',
        namaVaksin: 'Hepatitis B (HB-0)',
        deskripsi: 'Diberikan dalam 24 jam setelah lahir',
        usiaBulanTarget: 0,
        tanggalTarget: target,
        status: 'SELESAI',
        tanggalRealisasi: realisasi,
        catatanReaksi: 'Sedikit demam ringan',
        reminderH7Sent: true,
        reminderH1Sent: true,
      );

      final map = VaccineScheduleMapper.toFirestore(model);

      expect(map['scheduleId'], 'sch-001');
      expect(map['babyId'], 'baby-001');
      expect(map['namaVaksin'], 'Hepatitis B (HB-0)');
      expect(map['deskripsi'], 'Diberikan dalam 24 jam setelah lahir');
      expect(map['usiaBulanTarget'], 0);
      expect((map['tanggalTarget'] as Timestamp).toDate(), target);
      expect(map['status'], 'SELESAI');
      expect((map['tanggalRealisasi'] as Timestamp).toDate(), realisasi);
      expect(map['catatanReaksi'], 'Sedikit demam ringan');
      expect(map['schemaVersion'], 1);
      // Reminder flags per perangkat tidak ikut disinkronkan
      expect(map.containsKey('reminderH7Sent'), isFalse);
      expect(map.containsKey('reminderH1Sent'), isFalse);
    });

    test('fromFirestore deserialisasi null tanggalRealisasi dan catatanReaksi', () {
      final target = DateTime(2026, 5, 10);
      final map = <String, dynamic>{
        'scheduleId': 'sch-002',
        'babyId': 'baby-002',
        'namaVaksin': 'BCG',
        'deskripsi': 'Mencegah TBC',
        'usiaBulanTarget': 1,
        'tanggalTarget': Timestamp.fromDate(target),
        'status': 'BELUM',
        'tanggalRealisasi': null,
        'catatanReaksi': null,
        'schemaVersion': 1,
      };

      final restored = VaccineScheduleMapper.fromFirestore(map, 'sch-002');

      expect(restored.scheduleId, 'sch-002');
      expect(restored.babyId, 'baby-002');
      expect(restored.namaVaksin, 'BCG');
      expect(restored.status, 'BELUM');
      expect(restored.tanggalRealisasi, isNull);
      expect(restored.catatanReaksi, isNull);
      expect(restored.reminderH7Sent, isFalse);
    });
  });

  group('GrowthRecordMapper (B4-1)', () {
    test('toFirestore dan fromFirestore roundtrip preserves measurements', () {
      final measureDate = DateTime(2026, 3, 10);
      final model = GrowthRecordModel(
        recordId: 'rec-001',
        babyId: 'baby-001',
        tanggalPengukuran: measureDate,
        beratBadan: 6.85,
        tinggiBadan: 63.5,
        lingkarKepala: 41.2,
      );

      final map = GrowthRecordMapper.toFirestore(model);

      expect(map['recordId'], 'rec-001');
      expect(map['babyId'], 'baby-001');
      expect((map['tanggalPengukuran'] as Timestamp).toDate(), measureDate);
      expect(map['beratBadan'], 6.85);
      expect(map['tinggiBadan'], 63.5);
      expect(map['lingkarKepala'], 41.2);
      expect(map['schemaVersion'], 1);

      final restored = GrowthRecordMapper.fromFirestore(map, 'rec-001');

      expect(restored.recordId, model.recordId);
      expect(restored.babyId, model.babyId);
      expect(restored.tanggalPengukuran, model.tanggalPengukuran);
      expect(restored.beratBadan, model.beratBadan);
      expect(restored.tinggiBadan, model.tinggiBadan);
      expect(restored.lingkarKepala, model.lingkarKepala);
    });

    test('fromFirestore menangani lingkarKepala null dengan aman', () {
      final map = <String, dynamic>{
        'recordId': 'rec-null-head',
        'babyId': 'baby-001',
        'tanggalPengukuran': Timestamp.fromDate(DateTime(2026, 3, 1)),
        'beratBadan': 5.5,
        'tinggiBadan': 58.0,
        'lingkarKepala': null,
      };

      final restored = GrowthRecordMapper.fromFirestore(map, 'rec-null-head');
      expect(restored.lingkarKepala, isNull);
    });
  });

  group('HealthJournalMapper (B4-1)', () {
    test('toFirestore dan fromFirestore mempertahankan array gejala', () {
      final journalDate = DateTime(2026, 4, 1, 14, 0);
      final model = HealthJournalModel(
        journalId: 'jrn-001',
        babyId: 'baby-001',
        vaccineScheduleId: 'sch-dpt-1',
        tanggalCatatan: journalDate,
        isiCatatan: 'Anak sedikit rewel setelah suntik DPT-HB-Hib 1',
        suhuTubuh: 37.8,
        gejala: ['Demam ringan', 'Rewel', 'Nyeri bekas suntikan'],
      );

      final map = HealthJournalMapper.toFirestore(model);

      expect(map['journalId'], 'jrn-001');
      expect(map['babyId'], 'baby-001');
      expect(map['vaccineScheduleId'], 'sch-dpt-1');
      expect(map['isiCatatan'], contains('rewel'));
      expect(map['suhuTubuh'], 37.8);
      expect(map['gejala'], hasLength(3));
      expect(map['gejala'], contains('Demam ringan'));
      expect(map['schemaVersion'], 1);

      final restored = HealthJournalMapper.fromFirestore(map, 'jrn-001');

      expect(restored.journalId, model.journalId);
      expect(restored.babyId, model.babyId);
      expect(restored.vaccineScheduleId, model.vaccineScheduleId);
      expect(restored.suhuTubuh, model.suhuTubuh);
      expect(restored.gejala, ['Demam ringan', 'Rewel', 'Nyeri bekas suntikan']);
    });
  });

  group('QuizScoreMapper (B4-1)', () {
    test('toFirestore dan fromFirestore mempertahankan array riwayatSkor', () {
      final quizDate = DateTime(2026, 2, 20);
      final model = QuizScoreModel(
        quizId: 'quiz-imunisasi-dasar',
        skor: 4,
        totalSoal: 5,
        tanggalPengerjaan: quizDate,
        attemptCount: 2,
        riwayatSkor: [3, 4],
      );

      final map = QuizScoreMapper.toFirestore(model);

      expect(map['quizId'], 'quiz-imunisasi-dasar');
      expect(map['skor'], 4);
      expect(map['totalSoal'], 5);
      expect(map['attemptCount'], 2);
      expect(map['riwayatSkor'], [3, 4]);
      expect(map['schemaVersion'], 1);

      final restored = QuizScoreMapper.fromFirestore(map, 'quiz-imunisasi-dasar');

      expect(restored.quizId, model.quizId);
      expect(restored.skor, 4);
      expect(restored.totalSoal, 5);
      expect(restored.attemptCount, 2);
      expect(restored.riwayatSkor, [3, 4]);
      expect(restored.persentase, 80);
      expect(restored.skorTerbaik, 4);
    });
  });
}

