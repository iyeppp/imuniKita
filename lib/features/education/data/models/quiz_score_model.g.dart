// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_score_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QuizScoreModelAdapter extends TypeAdapter<QuizScoreModel> {
  @override
  final typeId = 5;

  @override
  QuizScoreModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuizScoreModel(
      quizId: fields[0] as String,
      skor: (fields[1] as num).toInt(),
      totalSoal: (fields[2] as num).toInt(),
      tanggalPengerjaan: fields[3] as DateTime,
      // Temuan #15: field baru — aman untuk data lama (null bila belum ada).
      attemptCount: (fields[4] as num?)?.toInt(),
      riwayatSkor: (fields[5] as List?)?.cast<int>(),
    );
  }

  @override
  void write(BinaryWriter writer, QuizScoreModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.quizId)
      ..writeByte(1)
      ..write(obj.skor)
      ..writeByte(2)
      ..write(obj.totalSoal)
      ..writeByte(3)
      ..write(obj.tanggalPengerjaan)
      ..writeByte(4)
      ..write(obj.attemptCount)
      ..writeByte(5)
      ..write(obj.riwayatSkor);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuizScoreModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
