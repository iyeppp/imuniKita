// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vaccine_schedule_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VaccineScheduleModelAdapter extends TypeAdapter<VaccineScheduleModel> {
  @override
  final typeId = 2;

  @override
  VaccineScheduleModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VaccineScheduleModel(
      scheduleId: fields[0] as String,
      babyId: fields[1] as String,
      namaVaksin: fields[2] as String,
      deskripsi: fields[3] as String,
      usiaBulanTarget: (fields[4] as num).toInt(),
      tanggalTarget: fields[5] as DateTime,
      status: fields[6] as String,
      tanggalRealisasi: fields[7] as DateTime?,
      catatanReaksi: fields[8] as String?,
      reminderH7Sent: fields[9] == null ? false : fields[9] as bool,
      reminderH1Sent: fields[10] == null ? false : fields[10] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, VaccineScheduleModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.scheduleId)
      ..writeByte(1)
      ..write(obj.babyId)
      ..writeByte(2)
      ..write(obj.namaVaksin)
      ..writeByte(3)
      ..write(obj.deskripsi)
      ..writeByte(4)
      ..write(obj.usiaBulanTarget)
      ..writeByte(5)
      ..write(obj.tanggalTarget)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.tanggalRealisasi)
      ..writeByte(8)
      ..write(obj.catatanReaksi)
      ..writeByte(9)
      ..write(obj.reminderH7Sent)
      ..writeByte(10)
      ..write(obj.reminderH1Sent);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VaccineScheduleModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
