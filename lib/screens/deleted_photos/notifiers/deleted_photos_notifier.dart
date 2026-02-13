import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../models/deleted_photo.dart';
import '../../../providers/deleted_photos_provider.dart';
import '../../../providers/viewed_photos_provider.dart';
import '../../../providers/month_groups_by_year_provider.dart';
import '../../../theme/app_colors.dart';
import '../widgets/delete_confirmation_dialog.dart';
import '../widgets/restore_confirmation_dialog.dart';

part 'deleted_photos_notifier.g.dart';

/// Состояние UI экрана корзины
class DeletedPhotosScreenState {
  final Set<String> selectedPhotoIds;
  final bool isProcessing;

  DeletedPhotosScreenState({
    required this.selectedPhotoIds,
    required this.isProcessing,
  });

  DeletedPhotosScreenState copyWith({
    Set<String>? selectedPhotoIds,
    bool? isProcessing,
  }) {
    return DeletedPhotosScreenState(
      selectedPhotoIds: selectedPhotoIds ?? this.selectedPhotoIds,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }

  bool get hasSelection => selectedPhotoIds.isNotEmpty;
  int get selectedCount => selectedPhotoIds.length;
}

/// Notifier для управления состоянием экрана корзины
@riverpod
class DeletedPhotosNotifier extends _$DeletedPhotosNotifier {
  @override
  DeletedPhotosScreenState build() {
    return DeletedPhotosScreenState(
      selectedPhotoIds: {},
      isProcessing: false,
    );
  }

  /// Переключить выбор фотографии
  void toggleSelection(String photoId) {
    final newSelected = Set<String>.from(state.selectedPhotoIds);
    if (newSelected.contains(photoId)) {
      newSelected.remove(photoId);
    } else {
      newSelected.add(photoId);
    }
    state = state.copyWith(selectedPhotoIds: newSelected);
  }

  /// Выбрать все фотографии
  void selectAll(List<String> photoIds) {
    state = state.copyWith(
      selectedPhotoIds: Set<String>.from(photoIds),
    );
  }

  /// Отменить выбор всех фотографий
  void clearSelection() {
    state = state.copyWith(selectedPhotoIds: {});
  }

  /// Обработать удаление с подтверждением
  Future<void> handleDelete(BuildContext context, List<DeletedPhoto> photos) async {
    // Показываем диалог подтверждения
    final confirmed = await DeleteConfirmationDialog.show(context, photos.length);

    if (!confirmed) return;

    try {
      await deleteSelected(photos);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Удалено ${photos.length} фото'),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при удалении: $e'),
            backgroundColor: AppColors.deleteRed,
          ),
        );
      }
    }
  }

  /// Обработать восстановление с подтверждением
  Future<void> handleRestore(BuildContext context, List<DeletedPhoto> photos) async {
    // Показываем диалог подтверждения
    final confirmed = await RestoreConfirmationDialog.show(context, photos.length);

    if (!confirmed) return;

    try {
      await restoreSelected(photos);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Восстановлено ${photos.length} фото'),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при восстановлении: $e'),
            backgroundColor: AppColors.deleteRed,
          ),
        );
      }
    }
  }

  /// Удалить выбранные фотографии
  Future<void> deleteSelected(List<DeletedPhoto> photos) async {
    state = state.copyWith(isProcessing: true);

    try {
      final ids = photos.map((p) => p.id).toList();

      // Удаляем фото из галереи устройства
      await PhotoManager.editor.deleteWithIds(ids);

      // Удаляем из нашего кэша удаленных фото
      final service = ref.read(deletedPhotosServiceProvider);
      await service.deleteSelected(ids);

      // Очищаем кэш просмотренных фотографий для удаленных фото
      final viewedBox = ref.read(viewedPhotosBoxProvider);
      final toDelete = <dynamic>[];

      for (var photo in viewedBox.values) {
        if (ids.contains(photo.id)) {
          toDelete.add(photo.key);
        }
      }

      if (toDelete.isNotEmpty) {
        await viewedBox.deleteAll(toDelete);
      }

      // Обновляем главный экран - инвалидируем провайдеры
      ref.invalidate(availableYearsProvider);
      ref.invalidate(monthGroupsByYearProvider);

      // Успешно - сбрасываем состояние
      state = state.copyWith(
        isProcessing: false,
        selectedPhotoIds: {},
      );
    } catch (e) {
      // Ошибка - сбрасываем только флаг обработки
      state = state.copyWith(isProcessing: false);
      rethrow; // Пробрасываем ошибку для показа в UI
    }
  }

  /// Восстановить выбранные фотографии
  Future<void> restoreSelected(List<DeletedPhoto> photos) async {
    state = state.copyWith(isProcessing: true);

    try {
      // Получаем ID фотографий ДО начала восстановления
      final photoIds = photos.map((p) => p.id).toList();

      final service = ref.read(deletedPhotosServiceProvider);

      // Восстанавливаем по ID
      for (final id in photoIds) {
        await service.restore(id);
      }

      // Успешно - сбрасываем состояние
      state = state.copyWith(
        isProcessing: false,
        selectedPhotoIds: {},
      );
    } catch (e) {
      // Ошибка - сбрасываем только флаг обработки
      state = state.copyWith(isProcessing: false);
      rethrow; // Пробрасываем ошибку для показа в UI
    }
  }
}
