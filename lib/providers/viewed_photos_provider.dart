import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swipe_media_cleaner/models/viewed_photo.dart';
import 'package:swipe_media_cleaner/services/viewed_photo_service.dart';

import '../database/app_database.dart';
import 'deleted_photos_provider.dart';

final viewedPhotosServiceProvider = Provider<ViewedPhotosService>((ref) {
  final db = ref.watch(appDatabaseProvider);

  return ViewedPhotosService(db);
});

final viewedPhotosControllerProvider = Provider<ViewedPhotosController>((ref) {
  final viewedPhotosService = ref.watch(viewedPhotosServiceProvider);

  return ViewedPhotosController(viewedPhotosService);
});

/// Провайдер для получения всех просмотренных фото
final viewedPhotosProvider = StreamProvider.autoDispose<List<ViewedPhoto>>((ref) {
  final service = ref.watch(viewedPhotosServiceProvider);

  return service.watchViewedPhotos();
});

/// Провайдер для получения просмотренных фото по месяцу
final viewedPhotosByMonthProvider =
    Provider.autoDispose.family<List<ViewedPhoto>, String>((ref, monthKey) {
  final viewedPhotosAsync = ref.watch(viewedPhotosProvider);
  final viewedPhotos = viewedPhotosAsync.maybeWhen(
    data: (photos) => photos,
    orElse: () => const <ViewedPhoto>[],
  );

  final parsedMonth = _parseMonthKey(monthKey);

  if (parsedMonth == null) {
    return const [];
  }

  final year = parsedMonth.$1;
  final month = parsedMonth.$2;

  return viewedPhotos.where((photo) => photo.year == year && photo.month == month).toList();
});

/// Провайдер для подсчета процента просмотренных фото по месяцу
final monthProgressProvider =
    Provider.autoDispose.family<double, MapEntry<String, int>>((ref, data) {
  final monthKey = data.key;
  final totalPhotos = data.value;

  if (totalPhotos == 0) return 0.0;

  final viewedPhotos = ref.watch(viewedPhotosByMonthProvider(monthKey));
  final viewedCount = viewedPhotos.length;

  return (viewedCount / totalPhotos).clamp(0.0, 1.0);
});

class ViewedPhotosController {
  final ViewedPhotosService _viewedPhotosService;

  ViewedPhotosController(this._viewedPhotosService);

  /// Отметить фото как просмотренное
  Future<void> markAsViewed(String photoId, int year, int month) async {
    final existing = await _viewedPhotosService.getViewedPhotoById(photoId);

    if (existing != null) {
      return;
    }

    final viewedPhoto = ViewedPhotosCompanion.insert(
      id: photoId,
      year: year,
      month: month,
      viewedAt: DateTime.now(),
    );

    await _viewedPhotosService.insertViewedPhoto(viewedPhoto);
  }

  /// Проверить, было ли фото просмотрено
  Future<bool> isViewed(String photoId) async {
    final existing = await _viewedPhotosService.getViewedPhotoById(photoId);

    return existing != null;
  }

  /// Удалить фото из просмотренных по id.
  ///
  /// Оставил старое название cleanupPhotos, чтобы меньше менять код.
  Future<void> cleanupPhotos(List<String> photoIds) {
    return _viewedPhotosService.deleteViewedPhotosByIds(photoIds);
  }

  /// Получить количество просмотренных фото по месяцу
  Future<int> getViewedCountByMonth(int year, int month) {
    return _viewedPhotosService.getViewedCountByMonth(
      year: year,
      month: month,
    );
  }

  /// Очистить все просмотренные фото по месяцу
  Future<void> clearMonth(int year, int month) {
    return _viewedPhotosService.deleteViewedPhotosByMonth(
      year: year,
      month: month,
    );
  }
}

(int year, int month)? _parseMonthKey(String monthKey) {
  final parts = monthKey.split('-');

  if (parts.length != 2) {
    return null;
  }

  final year = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);

  if (year == null || month == null) {
    return null;
  }

  return (year, month);
}
