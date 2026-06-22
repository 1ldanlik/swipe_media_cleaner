import 'package:swipe_media_cleaner/database/app_database.dart';
import 'package:swipe_media_cleaner/mappers/base/i_data_mapper.dart';
import 'package:swipe_media_cleaner/models/app_statistics.dart';

/// Маппер модели в DTO базы данных.
class DatabaseToAppStatisticMapper extends IDataMapper<AppStatisticsDB, AppStatistic> {
  /// Конструктор.
  DatabaseToAppStatisticMapper(super.input);

  @override
  AppStatistic map() => AppStatistic(
        id: input.id,
        checkedPhotos: input.checkedPhotos,
        deletedPhotos: input.deletedPhotos,
        freedSpace: input.freedSpace,
      );
}
