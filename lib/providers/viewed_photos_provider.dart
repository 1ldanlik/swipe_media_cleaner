import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/viewed_photo.dart';

/// Провайдер для бокса с просмотренными фото
final viewedPhotosBoxProvider = Provider<Box<ViewedPhoto>>((ref) {
  return Hive.box<ViewedPhoto>('viewedPhotos');
});

/// Провайдер для получения всех просмотренных фото
final viewedPhotosProvider = Provider.autoDispose<List<ViewedPhoto>>((ref) {
  final box = ref.watch(viewedPhotosBoxProvider);
  return Stream.value(box.values.toList()).asyncExpand((initial) async* {
    yield initial;
    await for (final _ in box.watch()) {
      yield box.values.toList();
    }
  }).first as List<ViewedPhoto>;
});

/// Провайдер для получения просмотренных фото по месяцу
final viewedPhotosByMonthProvider =
    Provider.autoDispose.family<List<ViewedPhoto>, String>((ref, monthKey) {
  final allViewed = ref.watch(viewedPhotosProvider);
  return allViewed.where((photo) => photo.monthKey == monthKey).toList();
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

/// Сервис для работы с просмотренными фото
class ViewedPhotosService {
  final Box<ViewedPhoto> _box;

  ViewedPhotosService(this._box);

  /// Отметить фото как просмотренное
  Future<void> markAsViewed(String photoId, int year, int month) async {
    // Проверяем, не было ли уже добавлено
    final existing = _box.values.firstWhere(
      (photo) => photo.id == photoId,
      orElse: () => ViewedPhoto(
        id: '',
        year: 0,
        month: 0,
        viewedAt: DateTime.now(),
      ),
    );

    if (existing.id.isEmpty) {
      final viewedPhoto = ViewedPhoto(
        id: photoId,
        year: year,
        month: month,
        viewedAt: DateTime.now(),
      );
      await _box.add(viewedPhoto);
    }
  }

  /// Проверить, было ли фото просмотрено
  bool isViewed(String photoId) {
    return _box.values.any((photo) => photo.id == photoId);
  }

  /// Очистить просмотренные фото, которых больше нет на устройстве
  Future<void> cleanupMissingPhotos(List<String> existingPhotoIds) async {
    final toDelete = <dynamic>[];

    for (var photo in _box.values) {
      if (!existingPhotoIds.contains(photo.id)) {
        toDelete.add(photo.key);
      }
    }

    await _box.deleteAll(toDelete);
  }

  /// Получить количество просмотренных фото по месяцу
  int getViewedCountByMonth(int year, int month) {
    return _box.values.where((photo) => photo.year == year && photo.month == month).length;
  }

  /// Очистить все просмотренные фото по месяцу
  Future<void> clearMonth(int year, int month) async {
    final toDelete = _box.values
        .where((photo) => photo.year == year && photo.month == month)
        .map((photo) => photo.key)
        .toList();

    await _box.deleteAll(toDelete);
  }
}

/// Провайдер для сервиса просмотренных фото
final viewedPhotosServiceProvider = Provider<ViewedPhotosService>((ref) {
  final box = ref.watch(viewedPhotosBoxProvider);
  return ViewedPhotosService(box);
});
