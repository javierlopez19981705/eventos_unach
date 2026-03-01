// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StudentAdapter extends TypeAdapter<Student> {
  @override
  final int typeId = 2;

  @override
  Student read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Student(
      id: fields[0] as String,
      name: fields[1] as String,
      lastNameP: fields[2] as String,
      lastNameM: fields[3] as String,
      matriculation: fields[4] as String,
      career: fields[5] as String,
      turno: fields[6] as String,
      qr: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Student obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.lastNameP)
      ..writeByte(3)
      ..write(obj.lastNameM)
      ..writeByte(4)
      ..write(obj.matriculation)
      ..writeByte(5)
      ..write(obj.career)
      ..writeByte(6)
      ..write(obj.turno)
      ..writeByte(7)
      ..write(obj.qr);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
