import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:swipe_media_cleaner/models/deleted_photo.dart';
import 'package:swipe_media_cleaner/providers/deleted_photos_provider.dart';
import 'package:swipe_media_cleaner/providers/month_groups_by_year_provider.dart';
import 'package:swipe_media_cleaner/providers/viewed_photos_provider.dart';
import 'package:swipe_media_cleaner/screens/deleted_photos/widgets/delete_confirmation_dialog.dart';
import 'package:swipe_media_cleaner/screens/deleted_photos/widgets/restore_confirmation_dialog.dart';
import 'package:swipe_media_cleaner/theme/app_colors.dart';

part 'deleted_photos_notifier.g.dart';

/// Состояние UI экрана корзины
class DeletedPhotosScreenState {
  final Set<String> selectedPhotoIds;
  final bool isProcessing;

  const DeletedPhotosScreenState({required this.selectedPhotoIds, required this.isProcessing});

  DeletedPhotosScreenState copyWith({Set<String>? selectedPhotoIds, bool? isProcessing}) {
    return DeletedPhotosScreenState(
      selectedPhotoIds: selectedPhotoIds ?? this.selectedPhotoIds,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }

  bool get hasSelection => selectedPhotoIds.isNotEmpty;

  int get selectedCount => selectedPhotoIds.length;
}

/// Controller для управления состоянием экрана корзины.
///
/// Важно:
/// класс не должен называться DeletedPhotosNotifier,
/// потому что Riverpod сгенерирует deletedPhotosProvider,
/// и он будет конфликтовать с provider'ом списка удалённых фото.
@riverpod
class DeletedPhotosScreenController extends _$DeletedPhotosScreenController {
  @override
  DeletedPhotosScreenState build() {
    return const DeletedPhotosScreenState(selectedPhotoIds: {}, isProcessing: false);
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
    state = state.copyWith(selectedPhotoIds: Set<String>.from(photoIds));
  }

  /// Отменить выбор всех фотографий
  void clearSelection() {
    state = state.copyWith(selectedPhotoIds: {});
  }

  /// Обработать удаление с подтверждением
  Future<void> handleDelete(BuildContext context, List<DeletedPhoto> photos) async {
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
          SnackBar(content: Text('Ошибка при удалении: $e'), backgroundColor: AppColors.deleteRed),
        );
      }
    }
  }

  /// Обработать восстановление с подтверждением
  Future<void> handleRestore(BuildContext context, List<DeletedPhoto> photos) async {
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

  /// Окончательно удалить выбранные фотографии
  Future<void> deleteSelected(List<DeletedPhoto> photos) async {
    if (photos.isEmpty) return;

    state = state.copyWith(isProcessing: true);

    try {
      final ids = photos.map((photo) => photo.id).toList();

      // Удаляем фото из галереи устройства
      await PhotoManager.editor.deleteWithIds(ids);

      // Удаляем из таблицы удалённых фото + обновляем статистику
      final deletedPhotosController = ref.read(deletedPhotosControllerProvider);
      await deletedPhotosController.deleteSelected(ids);

      // Удаляем эти фото из просмотренных
      final viewedPhotosController = ref.read(viewedPhotosControllerProvider);
      await viewedPhotosController.cleanupPhotos(ids);

      // Обновляем главный экран
      ref.invalidate(availableYearsProvider);
      ref.invalidate(monthGroupsByYearProvider);

      state = state.copyWith(isProcessing: false, selectedPhotoIds: {});
    } catch (e) {
      state = state.copyWith(isProcessing: false);
      rethrow;
    }
  }

  /// Восстановить выбранные фотографии из корзины
  Future<void> restoreSelected(List<DeletedPhoto> photos) async {
    if (photos.isEmpty) return;

    state = state.copyWith(isProcessing: true);

    try {
      final ids = photos.map((photo) => photo.id).toList();

      final deletedPhotosController = ref.read(deletedPhotosControllerProvider);

      for (final id in ids) {
        await deletedPhotosController.restore(id);
      }

      state = state.copyWith(isProcessing: false, selectedPhotoIds: {});
    } catch (e) {
      state = state.copyWith(isProcessing: false);
      rethrow;
    }
  }
}
