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
      body: SafeArea(
        child: deletedPhotosAsync.when(
          data: (deletedPhotos) {
            if (deletedPhotos.isEmpty) {
              return const Column(
                children: [
                  _DeletedPhotosHeader(),
                  Expanded(child: EmptyTrashWidget()),
                ],
              );
            }

            if (screenState.isProcessing) {
              return const Column(
                children: [
                  _DeletedPhotosHeader(),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Обработка...'),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }

            return Column(
              children: [
                const _DeletedPhotosHeader(),
                _InfoBanner(
                  notifier: notifier,
                  state: screenState,
                  photos: deletedPhotos,
                ),
                Expanded(
                  child: _PhotoGrid(
                    notifier: notifier,
                    state: screenState,
                    photos: deletedPhotos,
                  ),
                ),
              ],
            );
          },
          loading: () => const Column(
            children: [
              _DeletedPhotosHeader(),
              Expanded(child: Center(child: CircularProgressIndicator())),
            ],
          ),
          error: (error, stack) => Column(
            children: [
              const _DeletedPhotosHeader(),
              Expanded(
                child: Center(
                  child: Text('Ошибка: $error'),
                ),
              ),
            ],
          ),
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
}

class _DeletedPhotosHeader extends StatelessWidget {
  const _DeletedPhotosHeader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Text(
        'Корзина',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  final DeletedPhotosNotifier notifier;
  final DeletedPhotosScreenState state;
  final List<DeletedPhoto> photos;

  const _InfoBanner({
    required this.notifier,
    required this.state,
    required this.photos,
  });

  @override
  Widget build(BuildContext context) {
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
}

class _PhotoGrid extends StatelessWidget {
  final DeletedPhotosNotifier notifier;
  final DeletedPhotosScreenState state;
  final List<DeletedPhoto> photos;

  const _PhotoGrid({
    required this.notifier,
    required this.state,
    required this.photos,
  });

  @override
  Widget build(BuildContext context) {
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
        return _PhotoCard(
          notifier: notifier,
          photo: photo,
          isSelected: isSelected,
        );
      },
    );
  }
}

class _PhotoCard extends StatelessWidget {
  final DeletedPhotosNotifier notifier;
  final DeletedPhoto photo;
  final bool isSelected;

  const _PhotoCard({
    required this.notifier,
    required this.photo,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => notifier.toggleSelection(photo.id),
      onLongPress: () => notifier.toggleSelection(photo.id),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
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
                color: isSelected ? AppColors.selectedPhotoOverlay : Colors.transparent,
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
      ),
    );
  }
}
