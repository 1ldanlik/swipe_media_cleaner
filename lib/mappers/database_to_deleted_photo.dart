import 'package:swipe_media_cleaner/database/app_database.dart';
import 'package:swipe_media_cleaner/mappers/base/i_data_mapper.dart';
import 'package:swipe_media_cleaner/models/deleted_photo.dart';

/// Маппер модели в DTO базы данных.
class DatabaseToDeletedPhotoMapper extends IDataMapper<DeletedPhotoDB, DeletedPhoto> {
  /// Конструктор.
  DatabaseToDeletedPhotoMapper(super.input);

  @override
  DeletedPhoto map() => DeletedPhoto(
        id: input.id,
        path: input.path,
        size: input.size,
        deletedAt: input.deletedAt,
        year: input.year,
        month: input.month,
      );
}
