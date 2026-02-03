import 'package:hive/hive.dart';

part 'deleted_photo.g.dart';

@HiveType(typeId: 0)
class DeletedPhoto extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String path;

  @HiveField(2)
  final int size;

  @HiveField(3)
  final DateTime deletedAt;

  @HiveField(4)
  final int year;

  @HiveField(5)
  final int month;

  DeletedPhoto({
    required this.id,
    required this.path,
    required this.size,
    required this.deletedAt,
    required this.year,
    required this.month,
  });
}
