import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imunikita/features/chatbot/data/datasources/chatbot_mock_datasource.dart';
import 'package:imunikita/features/chatbot/data/models/chat_message_model.dart';
import 'package:imunikita/features/chatbot/presentation/screens/chatbot_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final datasource = ChatbotMockDatasource();

  group('ChatbotMockDatasource — keyword vaksin', () {
    test('keyword BCG mengembalikan info vaksin BCG/TBC', () async {
      final respons = await datasource.getResponse('apa itu vaksin BCG');
      expect(respons.toLowerCase(), contains('bcg'));
      expect(respons.toLowerCase(), contains('tuberkulosis'));
      expect(respons, isNot(contains('Maaf, saya belum bisa')));
    });

    test('keyword MR mengembalikan info campak/rubela', () async {
      final respons = await datasource.getResponse('jelaskan vaksin MR');
      expect(respons.toLowerCase(), contains('campak'));
      expect(respons.toLowerCase(), contains('rubela'));
    });

    test('keyword DPT mengembalikan info difteri/pertusis/tetanus', () async {
      final respons = await datasource.getResponse('vaksin DPT untuk bayi');
      expect(respons.toLowerCase(), contains('difteri'));
      expect(respons.toLowerCase(), contains('tetanus'));
    });

    test('keyword booster mengembalikan info dosis penguat', () async {
      final respons = await datasource.getResponse(
        'apakah perlu vaksin booster',
      );
      expect(respons.toLowerCase(), contains('booster'));
      expect(respons, isNot(contains('Maaf, saya belum bisa')));
    });
  });

  group('ChatbotMockDatasource — keyword parenting', () {
    test('keyword MPASI mengembalikan info makanan pendamping ASI', () async {
      final respons = await datasource.getResponse('makanan pendamping bayi');
      expect(respons.toLowerCase(), contains('mpasi'));
      expect(respons.toLowerCase(), contains('6 bulan'));
    });

    test('keyword stunting mengembalikan info pencegahan gizi', () async {
      final respons = await datasource.getResponse(
        'bagaimana mencegah stunting',
      );
      expect(respons.toLowerCase(), contains('stunting'));
      expect(respons.toLowerCase(), contains('gizi'));
    });

    test('keyword posyandu mengembalikan info layanan posyandu', () async {
      final respons = await datasource.getResponse('apa itu posyandu');
      expect(respons.toLowerCase(), contains('posyandu'));
    });

    test('keyword alergi mengembalikan info kontraindikasi', () async {
      final respons = await datasource.getResponse('bayi alergi boleh vaksin?');
      expect(respons.toLowerCase(), contains('alergi'));
      expect(respons.toLowerCase(), contains('kontraindikasi'));
    });
  });

  group('ChatbotMockDatasource — perilaku pencocokan', () {
    test('pertanyaan tak dikenal mengembalikan respons fallback', () async {
      final respons = await datasource.getResponse('zzz qqq xyzzy');
      expect(respons, contains('Maaf, saya belum bisa menjawab'));
      expect(respons, contains('Direktori Faskes'));
    });

    test('pencocokan keyword tidak case-sensitive', () async {
      final hurufKecil = await datasource.getResponse('vaksin bcg');
      final hurufBesar = await datasource.getResponse('VAKSIN BCG');
      final campuran = await datasource.getResponse('VaKsIn BcG');
      expect(hurufBesar, hurufKecil);
      expect(campuran, hurufKecil);
    });

    test('semua respons keyword tidak pernah kosong', () async {
      const keyword = [
        'bcg',
        'hepatitis b',
        'polio',
        'dpt',
        'hib',
        'pcv',
        'rotavirus',
        'mr',
        'je',
        'varisela',
        'hpv',
        'tifoid',
        'jadwal',
        'efek samping',
        'demam',
        'asi',
        'berat badan',
        'tinggi badan',
        'stunting',
        'vitamin',
        'posyandu',
        'dokter',
        'faskes',
        'mpasi',
        'tumbuh kembang',
        'booster',
        'imunisasi',
        'aman',
        'gratis',
        'alergi',
      ];

      for (final kw in keyword) {
        final respons = await datasource.getResponse(kw);
        expect(respons.trim(), isNotEmpty, reason: 'keyword "$kw" kosong');
      }
    });
  });

  group('ChatMessage', () {
    test('menyimpan field sesuai konstruktor', () {
      final waktu = DateTime(2026, 9, 25, 10, 30);
      final pesan = ChatMessage(
        id: 'msg-01',
        text: 'Halo ImuniBot',
        isUser: true,
        timestamp: waktu,
      );

      expect(pesan.id, 'msg-01');
      expect(pesan.text, 'Halo ImuniBot');
      expect(pesan.isUser, isTrue);
      expect(pesan.timestamp, waktu);
    });

    test('flag isUser membedakan pesan user dan bot', () {
      final dariUser = ChatMessage(
        id: 'u-1',
        text: 'pertanyaan',
        isUser: true,
        timestamp: DateTime(2026, 1, 1),
      );
      final dariBot = ChatMessage(
        id: 'b-1',
        text: 'jawaban',
        isUser: false,
        timestamp: DateTime(2026, 1, 1),
      );

      expect(dariUser.isUser, isTrue);
      expect(dariBot.isUser, isFalse);
    });
  });

  group('ChatbotScreen — welcome state', () {
    testWidgets('menampilkan 5 chip pertanyaan cepat', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: ChatbotScreen())),
      );
      await tester.pump();

      expect(find.text('Halo! Saya ImuniBot 👋'), findsOneWidget);
      expect(find.byType(ActionChip), findsNWidgets(5));
    });
  });
}
