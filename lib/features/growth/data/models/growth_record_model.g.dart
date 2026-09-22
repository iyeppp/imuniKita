// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'growth_record_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GrowthRecordModelAdapter extends TypeAdapter<GrowthRecordModel> {
  @override
  final typeId = 3;

  @override
  GrowthRecordModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GrowthRecordModel(
      recordId: fields[0] as String,
      babyId: fields[1] as String,
      tanggalPengukuran: fields[2] as DateTime,
      beratBadan: (fields[3] as num).toDouble(),
      tinggiBadan: (fields[4] as num).toDouble(),
      lingkarKepala: (fields[5] as num?)?.toDouble(),
    );
  }

  @override
  void write(BinaryWriter writer, GrowthRecordModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.recordId)
      ..writeByte(1)
      ..write(obj.babyId)
      ..writeByte(2)
      ..write(obj.tanggalPengukuran)
      ..writeByte(3)
      ..write(obj.beratBadan)
      ..writeByte(4)
      ..write(obj.tinggiBadan)
      ..writeByte(5)
      ..write(obj.lingkarKepala);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GrowthRecordModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
