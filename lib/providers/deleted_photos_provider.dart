import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/deleted_photo.dart';
import '../models/photo_item.dart';
import '../models/app_statistics.dart';

/// Провайдер для бокса Hive с удалёнными фото
final deletedPhotosBoxProvider = Provider<Box<DeletedPhoto>>((ref) {
  return Hive.box<DeletedPhoto>('deleted_photos');
});

/// Провайдер для бокса со статистикой
final statisticsBoxProvider = Provider<Box<AppStatistics>>((ref) {
  return Hive.box<AppStatistics>('statistics');
});

/// Провайдер для списка удалённых фото - ИСПРАВЛЕНО!
final deletedPhotosProvider = StreamProvider.autoDispose<List<DeletedPhoto>>((ref) {
  final box = ref.watch(deletedPhotosBoxProvider);
  
  // Создаем Stream, который сначала эмитит текущие данные, а потом слушает изменения
  return Stream.value(box.values.toList()).asyncExpand((initial) async* {
    yield initial;
    await for (final _ in box.watch()) {
      yield box.values.toList();
    }
  });
});

/// Провайдер для статистики - ИСПРАВЛЕНО!
final statisticsProvider = StreamProvider.autoDispose<AppStatistics>((ref) {
  final box = ref.watch(statisticsBoxProvider);
  
  // Создаем Stream, который сначала эмитит текущие данные, а потом слушает изменения
  AppStatistics getStats() {
    if (box.isEmpty) {
      final stats = AppStatistics();
      box.put('stats', stats);
      return stats;
    }
    return box.get('stats')!;
  }
  
  return Stream.value(getStats()).asyncExpand((initial) async* {
    yield initial;
    await for (final _ in box.watch()) {
      yield getStats();
    }
  });
});

/// Сервис для работы с удалёнными фото
class DeletedPhotosService {
  final Box<DeletedPhoto> _box;
  final Box<AppStatistics> _statsBox;
  
  DeletedPhotosService(this._box, this._statsBox);
  
  AppStatistics get _stats {
    if (_statsBox.isEmpty) {
      final stats = AppStatistics();
      _statsBox.put('stats', stats);
      return stats;
    }
    return _statsBox.get('stats')!;
  }
  
  /// Добавить фото в корзину (НЕ удаляем, просто помечаем)
  Future<void> markForDeletion(PhotoItem photo) async {
    final deletedPhoto = DeletedPhoto(
      id: photo.id,
      path: photo.path,
      size: photo.size,
      deletedAt: DateTime.now(),
      year: photo.createdDate.year,
      month: photo.createdDate.month,
    );
    await _box.put(photo.id, deletedPhoto);
  }
  
  /// Увеличить счетчик просмотренных фото
  void incrementCheckedPhotos() {
    _stats.incrementChecked();
  }
  
  /// Удалить фото из корзины (восстановить)
  Future<void> restore(String id) async {
    final photo = _box.get(id);
    if (photo != null) {
      await _box.delete(id);
    }
  }
  
  /// Окончательно удалить все фото из корзины
  Future<void> deleteAll() async {
    // Получаем все фото из корзины
    final photos = _box.values.toList();
    
    // Считаем статистику ПЕРЕД удалением
    final totalCount = photos.length;
    final totalSize = photos.fold<int>(0, (sum, photo) => sum + photo.size);
    
    // Очищаем корзину
    await _box.clear();
    
    // ВОТ ТЕПЕРЬ обновляем статистику реально удаленных фото!
    final stats = _stats;
    stats.deletedPhotos += totalCount;
    stats.freedSpace += totalSize;
    await stats.save();
  }
  
  /// Получить все удалённые фото
  List<DeletedPhoto> getAll() {
    return _box.values.toList();
  }
  
  /// Проверить, отмечено ли фото на удаление
  bool isMarkedForDeletion(String id) {
    return _box.containsKey(id);
  }
}

/// Провайдер сервиса
final deletedPhotosServiceProvider = Provider<DeletedPhotosService>((ref) {
  final box = ref.watch(deletedPhotosBoxProvider);
  final statsBox = ref.watch(statisticsBoxProvider);
  return DeletedPhotosService(box, statsBox);
});
