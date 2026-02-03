// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deleted_photo.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DeletedPhotoAdapter extends TypeAdapter<DeletedPhoto> {
  @override
  final int typeId = 0;

  @override
  DeletedPhoto read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DeletedPhoto(
      id: fields[0] as String,
      path: fields[1] as String,
      size: fields[2] as int,
      deletedAt: fields[3] as DateTime,
      year: fields[4] as int,
      month: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, DeletedPhoto obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.path)
      ..writeByte(2)
      ..write(obj.size)
      ..writeByte(3)
      ..write(obj.deletedAt)
      ..writeByte(4)
      ..write(obj.year)
      ..writeByte(5)
      ..write(obj.month);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeletedPhotoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
