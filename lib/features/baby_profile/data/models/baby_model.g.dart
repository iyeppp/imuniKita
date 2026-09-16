// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'baby_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BabyModelAdapter extends TypeAdapter<BabyModel> {
  @override
  final typeId = 1;

  @override
  BabyModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BabyModel(
      babyId: fields[0] as String,
      userId: fields[1] as String,
      namaAnak: fields[2] as String,
      tanggalLahir: fields[3] as DateTime,
      jenisKelamin: fields[4] as String,
      fotoProfilPath: fields[5] as String?,
      createdAt: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, BabyModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.babyId)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.namaAnak)
      ..writeByte(3)
      ..write(obj.tanggalLahir)
      ..writeByte(4)
      ..write(obj.jenisKelamin)
      ..writeByte(5)
      ..write(obj.fotoProfilPath)
      ..writeByte(6)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BabyModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
