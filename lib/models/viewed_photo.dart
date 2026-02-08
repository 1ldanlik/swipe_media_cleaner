import 'package:hive/hive.dart';

part 'viewed_photo.g.dart';

@HiveType(typeId: 2)
class ViewedPhoto extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final int year;

  @HiveField(2)
  final int month;

  @HiveField(3)
  final DateTime viewedAt;

  ViewedPhoto({
    required this.id,
    required this.year,
    required this.month,
    required this.viewedAt,
  });

  String get monthKey => '$year-$month';
}
