import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';
import '../models/deleted_photo.dart';
import '../providers/deleted_photos_provider.dart';

class DeletedPhotosScreen extends ConsumerWidget {
  const DeletedPhotosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deletedPhotosAsync = ref.watch(deletedPhotosProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Корзина'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: deletedPhotosAsync.when(
        data: (deletedPhotos) {
          if (deletedPhotos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.delete_outline,
                    size: 100,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Корзина пуста',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Кнопка удалить все
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.red[50],
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${deletedPhotos.length} фото готово к удалению',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.red[900],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: () => _confirmDeleteAll(context, ref, deletedPhotos),
                      icon: const Icon(Icons.delete_forever),
                      label: const Text('Удалить все'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),

              // Список фото
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: deletedPhotos.length,
                  itemBuilder: (context, index) {
                    final photo = deletedPhotos[index];
                    return _buildPhotoCard(context, ref, photo);
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Ошибка: $error'),
        ),
      ),
    );
  }

  Widget _buildPhotoCard(
    BuildContext context,
    WidgetRef ref,
    DeletedPhoto photo,
  ) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Фото
        Image.file(
          File(photo.path),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[300],
              child: const Icon(Icons.broken_image),
            );
          },
        ),

        // Полупрозрачный красный оверлей
        Container(
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.3),
          ),
        ),

        // Кнопка восстановить
        Positioned(
          top: 4,
          right: 4,
          child: InkWell(
            onTap: () => _restorePhoto(context, ref, photo),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(
                Icons.restore,
                size: 20,
                color: Colors.blue,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _restorePhoto(
    BuildContext context,
    WidgetRef ref,
    DeletedPhoto photo,
  ) async {
    final service = ref.read(deletedPhotosServiceProvider);
    await service.restore(photo.id);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Фото восстановлено'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _confirmDeleteAll(
    BuildContext context,
    WidgetRef ref,
    List<DeletedPhoto> photos,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить все фотографии?'),
        content: Text(
          'Вы действительно хотите удалить ${photos.length} фото навсегда?\n\n'
          'Это действие нельзя отменить!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await _deleteAllPhotos(context, ref, photos);
    }
  }

  Future<void> _deleteAllPhotos(
    BuildContext context,
    WidgetRef ref,
    List<DeletedPhoto> photos,
  ) async {
    // Показываем индикатор прогресса
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final ids = photos.map((p) => p.id).toList();
      await PhotoManager.editor.deleteWithIds(ids);

      final service = ref.read(deletedPhotosServiceProvider);
      await service.deleteAll();

      if (context.mounted) {
        Navigator.of(context).pop(); // Закрываем прогресс
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Удалено ${photos.length} фото'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Закрываем прогресс
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при удалении: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
