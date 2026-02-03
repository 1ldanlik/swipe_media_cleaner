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

/// Провайдер для списка удалённых фото
final deletedPhotosProvider = StreamProvider<List<DeletedPhoto>>((ref) {
  final box = ref.watch(deletedPhotosBoxProvider);
  return box.watch().map((_) => box.values.toList());
});

/// Провайдер для статистики
final statisticsProvider = StreamProvider<AppStatistics>((ref) {
  final box = ref.watch(statisticsBoxProvider);
  return box.watch().map((_) {
    if (box.isEmpty) {
      final stats = AppStatistics();
      box.put('stats', stats);
      return stats;
    }
    return box.get('stats')!;
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
  
  /// Добавить фото в список на удаление
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
    
    // Обновляем статистику
    _stats.addDeleted(photo.size);
  }
  
  /// Увеличить счетчик просмотренных фото
  void incrementCheckedPhotos() {
    _stats.incrementChecked();
  }
  
  /// Удалить фото из списка (восстановить)
  Future<void> restore(String id) async {
    final photo = _box.get(id);
    if (photo != null) {
      await _box.delete(id);
      // Обновляем статистику
      _stats.restorePhoto(photo.size);
    }
  }
  
  /// Удалить все отмеченные фото окончательно
  Future<void> deleteAll() async {
    await _box.clear();
    // Сбрасываем счетчики удаленных, но оставляем просмотренные
    _stats.resetDeleted();
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
