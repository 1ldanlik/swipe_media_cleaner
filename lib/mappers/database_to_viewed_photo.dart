import 'package:swipe_media_cleaner/database/app_database.dart';
import 'package:swipe_media_cleaner/mappers/base/i_data_mapper.dart';
import 'package:swipe_media_cleaner/models/viewed_photo.dart';

/// Маппер модели в DTO базы данных.
class DatabaseToViewedPhotoMapper extends IDataMapper<ViewedPhotoDB, ViewedPhoto> {
  /// Конструктор.
  DatabaseToViewedPhotoMapper(super.input);

  @override
  ViewedPhoto map() =>
      ViewedPhoto(id: input.id, year: input.year, month: input.month, viewedAt: input.viewedAt);
}
