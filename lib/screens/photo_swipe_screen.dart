import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/month_group.dart';
import '../models/photo_item.dart';
import '../providers/deleted_photos_provider.dart';
import '../providers/viewed_photos_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/swipeable_photo_card.dart';

class PhotoSwipeScreen extends ConsumerStatefulWidget {
  final MonthGroup monthGroup;

  const PhotoSwipeScreen({
    super.key,
    required this.monthGroup,
  });

  @override
  ConsumerState<PhotoSwipeScreen> createState() => _PhotoSwipeScreenState();
}

class _PhotoSwipeScreenState extends ConsumerState<PhotoSwipeScreen> {
  int currentIndex = 0;
  List<PhotoItem> remainingPhotos = [];
  List<PhotoItem> markedForDeletion = [];
  int alreadyViewedCount = 0; // Счетчик уже просмотренных фото

  @override
  void initState() {
    super.initState();
    _initializePhotos();
  }

  void _initializePhotos() {
    final viewedService = ref.read(viewedPhotosServiceProvider);

    // Фильтруем непросмотренные фото
    final unviewedPhotos =
        widget.monthGroup.photos.where((photo) => !viewedService.isViewed(photo.id)).toList();

    // Подсчитываем уже просмотренные фото
    alreadyViewedCount = widget.monthGroup.photos.length - unviewedPhotos.length;

    // Если есть непросмотренные - показываем только их, иначе показываем все
    remainingPhotos =
        unviewedPhotos.isNotEmpty ? unviewedPhotos : List.from(widget.monthGroup.photos);

    // Если показываем все фото (пересмотр), сбрасываем счетчик просмотренных
    if (unviewedPhotos.isEmpty) {
      alreadyViewedCount = 0;
    }
  }

  /// Отмечает фото как просмотренное и увеличивает счетчик, если фото не была просмотрена ранее
  Future<void> _markPhotoAsViewed(PhotoItem photo) async {
    final viewedService = ref.read(viewedPhotosServiceProvider);

    // Проверяем, была ли фото уже просмотрена
    final wasAlreadyViewed = viewedService.isViewed(photo.id);

    // Отмечаем фото как просмотренное
    await viewedService.markAsViewed(photo.id, widget.monthGroup.year, widget.monthGroup.month);

    // Увеличиваем счетчик просмотренных только если фото не была просмотрена ранее
    if (!wasAlreadyViewed) {
      final service = ref.read(deletedPhotosServiceProvider);
      service.incrementCheckedPhotos();
    }
  }

  void _handleKeep() {
    if (currentIndex < remainingPhotos.length) {
      final photo = remainingPhotos[currentIndex];

      // Отмечаем фото как просмотренное
      _markPhotoAsViewed(photo);

      setState(() {
        currentIndex++;
      });
      _checkIfFinished();
    }
  }

  Future<void> _handleDelete() async {
    if (currentIndex < remainingPhotos.length) {
      final photo = remainingPhotos[currentIndex];

      // Отмечаем фото как просмотренное
      await _markPhotoAsViewed(photo);

      // Сохраняем в кэш
      final deletedService = ref.read(deletedPhotosServiceProvider);
      await deletedService.markForDeletion(photo);

      setState(() {
        markedForDeletion.add(photo);
        currentIndex++;
      });
      _checkIfFinished();
    }
  }

  void _checkIfFinished() {
    if (currentIndex >= remainingPhotos.length) {
      // Просто возвращаемся на предыдущий экран
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.monthGroup.photos.isEmpty
        ? 0.0
        : ((currentIndex + alreadyViewedCount) / widget.monthGroup.photos.length).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: AppColors.greyExtraLight,
      appBar: AppBar(
        backgroundColor: AppColors.greyExtraLight,
        foregroundColor: AppColors.black,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.monthGroup.monthName} ${widget.monthGroup.year}',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              '${currentIndex + alreadyViewedCount + 1} / ${widget.monthGroup.photos.length}',
              style: const TextStyle(fontSize: 14, color: AppColors.greyMedium),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.greyLight,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.restoreBlue),
          ),
        ),
      ),
      body: currentIndex < remainingPhotos.length
          ? SwipeablePhotoCard(
              key: ValueKey(remainingPhotos[currentIndex].id), // Добавляем уникальный key
              photo: remainingPhotos[currentIndex],
              onSwipeLeft: _handleDelete,
              onSwipeRight: _handleKeep,
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    size: 100,
                    color: AppColors.successGreen,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Все фотографии просмотрены!',
                    style: TextStyle(
                      fontSize: 24,
                      color: AppColors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Завершить'),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: currentIndex < remainingPhotos.length
          ? Container(
              color: AppColors.greyExtraLight,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FloatingActionButton(
                    heroTag: 'delete',
                    onPressed: _handleDelete,
                    backgroundColor: AppColors.deleteRed,
                    child: const Icon(Icons.close, size: 32),
                  ),
                  FloatingActionButton(
                    heroTag: 'keep',
                    onPressed: _handleKeep,
                    backgroundColor: AppColors.successGreen,
                    child: const Icon(Icons.check, size: 32),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
