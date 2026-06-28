import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:swipe_media_cleaner/database/converters/millis_date_converter.dart';

part 'app_database.g.dart';

@DriftDatabase(
  include: {
    'schema/deleted_photos.drift',
    'schema/viewed_photos.drift',
    'schema/app_statistics.drift',
  },
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'swipe_media_cleaner'));

  @override
  int get schemaVersion => 1;
}
