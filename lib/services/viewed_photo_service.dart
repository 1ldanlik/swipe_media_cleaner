import 'package:drift/drift.dart';
import 'package:swipe_media_cleaner/database/app_database.dart';
import 'package:swipe_media_cleaner/mappers/database_to_viewed_photo.dart';
import 'package:swipe_media_cleaner/models/viewed_photo.dart';

class ViewedPhotosService {
  final AppDatabase _db;

  ViewedPhotosService(this._db);

  Stream<List<ViewedPhoto>> watchViewedPhotos() {
    return _db
        .select(_db.viewedPhotos)
        .watch()
        .map((rows) => rows.map((row) => DatabaseToViewedPhotoMapper(row).transform()).toList());
  }

  Future<void> insertViewedPhoto(ViewedPhotosCompanion photo) {
    return _db.into(_db.viewedPhotos).insert(
          photo,
          mode: InsertMode.insertOrIgnore,
        );
  }

  Future<ViewedPhoto?> getViewedPhotoById(String photoId) {
    return (_db.select(_db.viewedPhotos)..where((tbl) => tbl.id.equals(photoId)))
        .getSingleOrNull()
        .then((row) => row == null ? null : DatabaseToViewedPhotoMapper(row).transform());
  }

  Future<void> deleteViewedPhotosByIds(List<String> ids) {
    return (_db.delete(_db.viewedPhotos)..where((tbl) => tbl.id.isIn(ids))).go();
  }

  Future<int> getViewedCountByMonth({
    required int year,
    required int month,
  }) async {
    final rows = await (_db.select(_db.viewedPhotos)
          ..where((tbl) => tbl.year.equals(year))
          ..where((tbl) => tbl.month.equals(month)))
        .get();

    return rows.length;
  }

  Future<void> deleteViewedPhotosByMonth({
    required int year,
    required int month,
  }) {
    return (_db.delete(_db.viewedPhotos)
          ..where((tbl) => tbl.year.equals(year))
          ..where((tbl) => tbl.month.equals(month)))
        .go();
  }
}
