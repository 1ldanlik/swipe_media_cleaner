import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swipe_media_cleaner/models/deleted_photo.dart';
import '../../providers/deleted_photos_provider.dart';
import '../../theme/app_colors.dart';
import 'notifiers/deleted_photos_notifier.dart';
import 'widgets/empty_trash_widget.dart';
import 'widgets/bottom_action_buttons.dart';
import 'widgets/photo_card.dart';

class DeletedPhotosScreen extends ConsumerWidget {
  const DeletedPhotosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenState = ref.watch(deletedPhotosScreenControllerProvider);
    final notifier = ref.read(deletedPhotosScreenControllerProvider.notifier);
    final deletedPhotosAsync = ref.watch(deletedPhotosProvider);

    return Scaffold(
      body: SafeArea(
        child: deletedPhotosAsync.when(
          data: (deletedPhotos) {
            if (deletedPhotos.isEmpty) {
              return const EmptyTrashWidget();
            }

            if (screenState.isProcessing) {
              return const Column(
                children: [
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
                _InfoBanner(notifier: notifier, state: screenState, photos: deletedPhotos),
                Expanded(
                  child: _PhotoGrid(notifier: notifier, state: screenState, photos: deletedPhotos),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Column(
            children: [Expanded(child: Center(child: Text('Ошибка: $error')))],
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

class _InfoBanner extends StatelessWidget {
  final DeletedPhotosScreenController notifier;
  final DeletedPhotosScreenState state;
  final List<DeletedPhoto> photos;

  const _InfoBanner({required this.notifier, required this.state, required this.photos});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      color: AppColors.trashBannerBackground,
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${state.selectedCount} / ${photos.length}',
              style: const TextStyle(
                fontSize: 32,
                color: AppColors.trashBannerText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (state.hasSelection)
            IconButton(
              onPressed: () => notifier.clearSelection(),
              icon: const Icon(Icons.close, size: 32),
              color: AppColors.trashBannerText,
            )
          else
            IconButton(
              onPressed: () => notifier.selectAll(photos.map((p) => p.id).toList()),
              icon: const Icon(Icons.library_add_check_outlined, size: 32),
              color: AppColors.trashBannerText,
            ),
        ],
      ),
    );
  }
}

class _PhotoGrid extends StatelessWidget {
  final DeletedPhotosScreenController notifier;
  final DeletedPhotosScreenState state;
  final List<DeletedPhoto> photos;

  const _PhotoGrid({required this.notifier, required this.state, required this.photos});

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
        return PhotoCard(notifier: notifier, photo: photo, isSelected: isSelected);
      },
    );
  }
}
