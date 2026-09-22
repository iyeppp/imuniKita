// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_journal_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HealthJournalModelAdapter extends TypeAdapter<HealthJournalModel> {
  @override
  final typeId = 4;

  @override
  HealthJournalModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HealthJournalModel(
      journalId: fields[0] as String,
      babyId: fields[1] as String,
      vaccineScheduleId: fields[2] as String?,
      tanggalCatatan: fields[3] as DateTime,
      isiCatatan: fields[4] as String,
      suhuTubuh: (fields[5] as num?)?.toDouble(),
      gejala: (fields[6] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, HealthJournalModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.journalId)
      ..writeByte(1)
      ..write(obj.babyId)
      ..writeByte(2)
      ..write(obj.vaccineScheduleId)
      ..writeByte(3)
      ..write(obj.tanggalCatatan)
      ..writeByte(4)
      ..write(obj.isiCatatan)
      ..writeByte(5)
      ..write(obj.suhuTubuh)
      ..writeByte(6)
      ..write(obj.gejala);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthJournalModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
