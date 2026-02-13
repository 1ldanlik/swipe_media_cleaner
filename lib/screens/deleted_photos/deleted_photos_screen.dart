import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/deleted_photo.dart';
import '../../providers/deleted_photos_provider.dart';
import '../../theme/app_colors.dart';
import 'notifiers/deleted_photos_notifier.dart';
import 'widgets/empty_trash_widget.dart';
import 'widgets/bottom_action_buttons.dart';

class DeletedPhotosScreen extends ConsumerWidget {
  const DeletedPhotosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenState = ref.watch(deletedPhotosNotifierProvider);
    final notifier = ref.read(deletedPhotosNotifierProvider.notifier);
    final deletedPhotosAsync = ref.watch(deletedPhotosProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Корзина'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: deletedPhotosAsync.when(
        data: (deletedPhotos) {
          if (deletedPhotos.isEmpty) {
            return const EmptyTrashWidget();
          }

          if (screenState.isProcessing) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Обработка...'),
                ],
              ),
            );
          }

          return Column(
            children: [
              _buildInfoBanner(context, notifier, screenState, deletedPhotos),
              Expanded(
                child: _buildPhotoGrid(context, notifier, screenState, deletedPhotos),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Ошибка: $error'),
        ),
      ),
      bottomNavigationBar: deletedPhotosAsync.whenOrNull(
        data: (deletedPhotos) {
          if (deletedPhotos.isEmpty || !screenState.hasSelection) return null;

          final selectedPhotos = deletedPhotos
              .where((photo) => screenState.selectedPhotoIds.contains(photo.id))
              .toList();

          return BottomActionButtons(
            selectedCount: screenState.selectedCount,
            onDelete: () => notifier.handleDelete(context, selectedPhotos),
            onRestore: () => notifier.handleRestore(context, selectedPhotos),
          );
        },
      ),
    );
  }

  Widget _buildInfoBanner(
    BuildContext context,
    DeletedPhotosNotifier notifier,
    DeletedPhotosScreenState state,
    List<DeletedPhoto> photos,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.trashBannerBackground,
      child: Row(
        children: [
          Expanded(
            child: Text(
              state.hasSelection
                  ? 'Выбрано: ${state.selectedCount} из ${photos.length}'
                  : '${photos.length} фото готово к удалению',
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.trashBannerText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (state.hasSelection)
            TextButton.icon(
              onPressed: () => notifier.clearSelection(),
              icon: const Icon(Icons.close, size: 18),
              label: const Text('Отменить'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.trashBannerText,
              ),
            )
          else
            TextButton.icon(
              onPressed: () => notifier.selectAll(photos.map((p) => p.id).toList()),
              icon: const Icon(Icons.select_all, size: 18),
              label: const Text('Выбрать все'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.trashBannerText,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPhotoGrid(
    BuildContext context,
    DeletedPhotosNotifier notifier,
    DeletedPhotosScreenState state,
    List<DeletedPhoto> photos,
  ) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        final photo = photos[index];
        final isSelected = state.selectedPhotoIds.contains(photo.id);
        return _buildPhotoCard(context, notifier, photo, isSelected);
      },
    );
  }

  Widget _buildPhotoCard(
    BuildContext context,
    DeletedPhotosNotifier notifier,
    DeletedPhoto photo,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () => notifier.toggleSelection(photo.id),
      onLongPress: () => notifier.toggleSelection(photo.id),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.file(
            File(photo.path),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: AppColors.greyLight,
                child: const Icon(Icons.broken_image, color: AppColors.brokenImageIcon),
              );
            },
          ),
          Container(
            decoration: BoxDecoration(
              color: isSelected ? AppColors.selectedPhotoOverlay : null,
              border: isSelected ? Border.all(color: AppColors.restoreBlue, width: 3) : null,
            ),
          ),
          if (isSelected)
            const Positioned(
              top: 8,
              right: 8,
              child: Icon(
                Icons.check_circle,
                color: AppColors.checkCircleIcon,
                size: 32,
              ),
            ),
        ],
      ),
    );
  }
}
