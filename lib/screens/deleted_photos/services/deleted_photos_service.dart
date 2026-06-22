import 'package:drift/drift.dart';
import 'package:swipe_media_cleaner/database/app_database.dart';
import 'package:swipe_media_cleaner/mappers/database_to_app_statisctics.dart';
import 'package:swipe_media_cleaner/mappers/database_to_deleted_photo.dart';
import 'package:swipe_media_cleaner/models/app_statistics.dart';
import 'package:swipe_media_cleaner/models/deleted_photo.dart';

class DeletedPhotosService {
  final AppDatabase _db;

  DeletedPhotosService(this._db);

  Stream<List<DeletedPhoto>> watchDeletedPhotos() {
    return (_db.select(_db.deletedPhotos)
          ..orderBy([
            (tbl) => OrderingTerm.desc(tbl.deletedAt),
          ]))
        .watch()
        .map((rows) => rows.map((row) => DatabaseToDeletedPhotoMapper(row).transform()).toList());
  }

  Stream<AppStatistic> watchStatistics() {
    return (_db.select(_db.appStatistics)..where((tbl) => tbl.id.equals(1)))
        .watchSingle()
        .map((row) => DatabaseToAppStatisticMapper(row).transform());
  }

  Future<void> insertStatisticsIfMissing() {
    return _db.into(_db.appStatistics).insert(
          const AppStatisticsCompanion(
            id: Value(1),
            checkedPhotos: Value(0),
            deletedPhotos: Value(0),
            freedSpace: Value(0),
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  Future<void> insertDeletedPhoto(DeletedPhotosCompanion photo) {
    return _db.into(_db.deletedPhotos).insertOnConflictUpdate(photo);
  }

  Future<List<DeletedPhoto>> getAllDeletedPhotos() {
    return _db
        .select(_db.deletedPhotos)
        .get()
        .then((rows) => rows.map((row) => DatabaseToDeletedPhotoMapper(row).transform()).toList());
  }

  Future<List<DeletedPhoto>> getDeletedPhotosByIds(List<String> ids) {
    return (_db.select(_db.deletedPhotos)..where((tbl) => tbl.id.isIn(ids)))
        .get()
        .then((rows) => rows.map((row) => DatabaseToDeletedPhotoMapper(row).transform()).toList());
  }

  Future<DeletedPhoto?> getDeletedPhotoById(String id) {
    return (_db.select(_db.deletedPhotos)..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull()
        .then((row) => row == null ? null : DatabaseToDeletedPhotoMapper(row).transform());
  }

  Future<void> deleteDeletedPhotoById(String id) {
    return (_db.delete(_db.deletedPhotos)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<void> deleteDeletedPhotosByIds(List<String> ids) {
    return (_db.delete(_db.deletedPhotos)..where((tbl) => tbl.id.isIn(ids))).go();
  }

  Future<void> deleteAllDeletedPhotos() {
    return _db.delete(_db.deletedPhotos).go();
  }

  Future<void> incrementCheckedPhotos() {
    return _db.customUpdate(
      '''
      UPDATE app_statistics
      SET checked_photos = checked_photos + 1
      WHERE id = 1
      ''',
      updates: {_db.appStatistics},
    );
  }

  Future<void> addDeletedStatistics({
    required int count,
    required int freedSpace,
  }) {
    return _db.customUpdate(
      '''
      UPDATE app_statistics
      SET
        deleted_photos = deleted_photos + ?,
        freed_space = freed_space + ?
      WHERE id = 1
      ''',
      variables: [
        Variable.withInt(count),
        Variable.withInt(freedSpace),
      ],
      updates: {_db.appStatistics},
    );
  }

  Future<T> transaction<T>(Future<T> Function() action) {
    return _db.transaction(action);
  }
}
