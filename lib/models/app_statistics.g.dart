// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_statistics.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppStatisticsAdapter extends TypeAdapter<AppStatistics> {
  @override
  final int typeId = 1;

  @override
  AppStatistics read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppStatistics(
      checkedPhotos: fields[0] as int,
      deletedPhotos: fields[1] as int,
      freedSpace: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, AppStatistics obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.checkedPhotos)
      ..writeByte(1)
      ..write(obj.deletedPhotos)
      ..writeByte(2)
      ..write(obj.freedSpace);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppStatisticsAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}
