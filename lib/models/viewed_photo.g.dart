// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'viewed_photo.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ViewedPhotoAdapter extends TypeAdapter<ViewedPhoto> {
  @override
  final int typeId = 2;

  @override
  ViewedPhoto read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ViewedPhoto(
      id: fields[0] as String,
      year: fields[1] as int,
      month: fields[2] as int,
      viewedAt: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ViewedPhoto obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.year)
      ..writeByte(2)
      ..write(obj.month)
      ..writeByte(3)
      ..write(obj.viewedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ViewedPhotoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
