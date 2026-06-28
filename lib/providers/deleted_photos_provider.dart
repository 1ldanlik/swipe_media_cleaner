import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:swipe_media_cleaner/database/app_database.dart';
import 'package:swipe_media_cleaner/models/app_statistics.dart';
import 'package:swipe_media_cleaner/models/deleted_photo.dart';
import 'package:swipe_media_cleaner/models/photo_item.dart';
import 'package:swipe_media_cleaner/screens/deleted_photos/services/deleted_photos_service.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();

  ref.onDispose(() {
    db.close();
  });

  return db;
});

final deletedPhotosServiceProvider = Provider<DeletedPhotosService>((ref) {
  final db = ref.watch(appDatabaseProvider);

  return DeletedPhotosService(db);
});

final deletedPhotosControllerProvider = Provider<DeletedPhotosController>((ref) {
  final deletedPhotosService = ref.watch(deletedPhotosServiceProvider);

  return DeletedPhotosController(deletedPhotosService);
});

/// Список фото, которые находятся в корзине
final deletedPhotosProvider = StreamProvider.autoDispose<List<DeletedPhoto>>((ref) {
  final deletedPhotosService = ref.watch(deletedPhotosServiceProvider);

  return deletedPhotosService.watchDeletedPhotos();
});

/// Статистика приложения
final statisticsProvider = StreamProvider.autoDispose<AppStatistic>((ref) async* {
  final controller = ref.watch(deletedPhotosControllerProvider);
  final deletedPhotosService = ref.watch(deletedPhotosServiceProvider);

  await controller.ensureStatisticsExists();

  yield* deletedPhotosService.watchStatistics();
});

/// Версия приложения
final appVersionProvider = FutureProvider<String>((ref) async {
  final packageInfo = await PackageInfo.fromPlatform();

  return packageInfo.version;
});

/// Контроллер бизнес-логики для удалённых фото.
///
/// Важно:
/// deletedPhotosProvider выше — это только Stream со списком фото.
/// deletedPhotosControllerProvider — это действия: удалить, восстановить,
/// пометить на удаление, обновить статистику.
class DeletedPhotosController {
  final DeletedPhotosService _deletedPhotosService;

  DeletedPhotosController(this._deletedPhotosService);

  Future<void> ensureStatisticsExists() {
    return _deletedPhotosService.insertStatisticsIfMissing();
  }

  /// Добавить фото в корзину.
  ///
  /// Статистику deleted_photos / freed_space здесь не увеличиваем,
  /// потому что фото ещё не удалено окончательно.
  Future<void> markForDeletion(PhotoItem photo) async {
    final deletedPhoto = DeletedPhotosCompanion.insert(
      id: photo.id,
      path: photo.path,
      size: photo.size,
      deletedAt: DateTime.now(),
      year: photo.createdDate.year,
      month: photo.createdDate.month,
    );

    await _deletedPhotosService.insertDeletedPhoto(deletedPhoto);
  }

  /// Увеличить счётчик просмотренных фото
  Future<void> incrementCheckedPhotos() async {
    await ensureStatisticsExists();

    await _deletedPhotosService.incrementCheckedPhotos();
  }

  /// Убрать фото из корзины, то есть восстановить
  Future<void> restore(String id) async {
    await _deletedPhotosService.deleteDeletedPhotoById(id);
  }

  /// Окончательно удалить все фото из корзины
  Future<void> deleteAll() async {
    await _deletedPhotosService.transaction(() async {
      await ensureStatisticsExists();

      final photos = await _deletedPhotosService.getAllDeletedPhotos();

      final totalCount = photos.length;
      final totalSize = photos.fold<int>(0, (sum, photo) => sum + photo.size);

      if (totalCount == 0) {
        return;
      }

      await _deletedPhotosService.deleteAllDeletedPhotos();

      await _deletedPhotosService.addDeletedStatistics(count: totalCount, freedSpace: totalSize);
    });
  }

  /// Окончательно удалить выбранные фото из корзины
  Future<void> deleteSelected(List<String> ids) async {
    if (ids.isEmpty) {
      return;
    }

    await _deletedPhotosService.transaction(() async {
      await ensureStatisticsExists();

      final photosToDelete = await _deletedPhotosService.getDeletedPhotosByIds(ids);

      final totalCount = photosToDelete.length;
      final totalSize = photosToDelete.fold<int>(0, (sum, photo) => sum + photo.size);

      if (totalCount == 0) {
        return;
      }

      await _deletedPhotosService.deleteDeletedPhotosByIds(ids);

      await _deletedPhotosService.addDeletedStatistics(count: totalCount, freedSpace: totalSize);
    });
  }

  /// Получить все фото из корзины
  Future<List<DeletedPhoto>> getAll() {
    return _deletedPhotosService.getAllDeletedPhotos();
  }

  /// Проверить, находится ли фото в корзине
  Future<bool> isMarkedForDeletion(String id) async {
    final photo = await _deletedPhotosService.getDeletedPhotoById(id);

    return photo != null;
  }
}

extension AppStatisticX on AppStatistic {
  String get formattedFreedSpace {
    if (freedSpace < 1024) return '$freedSpace B';

    if (freedSpace < 1024 * 1024) {
      return '${(freedSpace / 1024).toStringAsFixed(1)} KB';
    }

    if (freedSpace < 1024 * 1024 * 1024) {
      return '${(freedSpace / (1024 * 1024)).toStringAsFixed(1)} MB';
    }

    return '${(freedSpace / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}
