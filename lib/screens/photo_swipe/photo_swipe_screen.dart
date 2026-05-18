import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/month_group.dart';
import '../../models/photo_item.dart';
import '../../providers/photo_swipe_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/swipeable_photo_card.dart';
import 'widgets/action_button.dart';

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
  (int, int) get _providerParams => (widget.monthGroup.year, widget.monthGroup.month);

  @override
  void initState() {
    super.initState();
    // Загружаем фото при инициализации
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      ref.read(photoSwipeProvider(_providerParams).notifier).loadPhotosForMonth(
            widget.monthGroup.year,
            widget.monthGroup.month,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(photoSwipeProvider(_providerParams));
    final notifier = ref.read(photoSwipeProvider(_providerParams).notifier);

    if (state.isLoading) {
      return _LoadingScaffold(
        monthName: widget.monthGroup.monthName,
        year: widget.monthGroup.year,
      );
    }

    if (state.error != null) {
      return _ErrorScaffold(
        monthName: widget.monthGroup.monthName,
        year: widget.monthGroup.year,
        error: state.error!,
        onRetry: () {
          notifier.loadPhotosForMonth(
            widget.monthGroup.year,
            widget.monthGroup.month,
          );
        },
      );
    }

    return _MainScaffold(
      monthName: widget.monthGroup.monthName,
      year: widget.monthGroup.year,
      currentIndex: state.currentIndex,
      alreadyViewedCount: state.alreadyViewedCount,
      totalPhotosInMonth: state.totalPhotosInMonth,
      remainingPhotos: state.remainingPhotos,
      currentPhotoIsFavorite: state.currentPhotoIsFavorite,
      isFullPictureShow: state.isFullPictureShow,
      onFullPictureShowToggle: () => notifier.toggleFullPicture(),
      onDelete: () => notifier.deleteCurrentPhoto(),
      onKeep: () => notifier.keepCurrentPhoto(),
      onToggleFavorite: () => notifier.toggleFavorite(),
    );
  }
}

class _LoadingScaffold extends StatelessWidget {
  final String monthName;
  final int year;

  const _LoadingScaffold({
    required this.monthName,
    required this.year,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyExtraLight,
      appBar: AppBar(
        backgroundColor: AppColors.greyExtraLight,
        foregroundColor: AppColors.black,
        title: Text(
          '$monthName $year',
          style: const TextStyle(fontSize: 24),
        ),
      ),
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorScaffold extends StatelessWidget {
  final String monthName;
  final int year;
  final String error;
  final VoidCallback onRetry;

  const _ErrorScaffold({
    required this.monthName,
    required this.year,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyExtraLight,
      appBar: AppBar(
        backgroundColor: AppColors.greyExtraLight,
        foregroundColor: AppColors.black,
        title: Text(
          '$monthName $year',
          style: const TextStyle(fontSize: 24),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.deleteRed),
              const SizedBox(height: 12),
              Text('Ошибка загрузки фото: $error', textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Повторить'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MainScaffold extends StatelessWidget {
  final String monthName;
  final int year;
  final int currentIndex;
  final int alreadyViewedCount;
  final int totalPhotosInMonth;
  final List<PhotoItem> remainingPhotos;
  final bool currentPhotoIsFavorite;
  final bool isFullPictureShow;
  final VoidCallback onFullPictureShowToggle;
  final VoidCallback onDelete;
  final VoidCallback onKeep;
  final VoidCallback onToggleFavorite;

  const _MainScaffold({
    required this.monthName,
    required this.year,
    required this.currentIndex,
    required this.alreadyViewedCount,
    required this.totalPhotosInMonth,
    required this.remainingPhotos,
    required this.currentPhotoIsFavorite,
    required this.isFullPictureShow,
    required this.onFullPictureShowToggle,
    required this.onDelete,
    required this.onKeep,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalPhotosInMonth == 0
        ? 0.0
        : ((currentIndex + alreadyViewedCount) / totalPhotosInMonth).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: AppColors.greyExtraLight,
      appBar: AppBar(
        backgroundColor: AppColors.greyExtraLight,
        foregroundColor: AppColors.black,
        title: Text(
          '$monthName $year',
          style: const TextStyle(fontSize: 24),
        ),
        actions: [
          IconButton(
            onPressed: onFullPictureShowToggle,
            icon: Icon(
              isFullPictureShow ? Icons.zoom_out_map_rounded : Icons.zoom_in_map_rounded,
              color: AppColors.black,
              size: 28,
            ),
          ),
          if (currentIndex < remainingPhotos.length)
            IconButton(
              onPressed: onToggleFavorite,
              icon: Icon(
                currentPhotoIsFavorite ? Icons.favorite : Icons.favorite_border,
                color: currentPhotoIsFavorite ? AppColors.favoriteRed : AppColors.greyMedium,
                size: 28,
              ),
            ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '${currentIndex + alreadyViewedCount + 1} / $totalPhotosInMonth',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
            ),
          ),
        ],
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
              key: ValueKey(remainingPhotos[currentIndex].id),
              photo: remainingPhotos[currentIndex],
              onSwipeLeft: onDelete,
              onSwipeRight: onKeep,
              isFullPictureShow: isFullPictureShow,
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
          ? Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ActionButton(
                      color: AppColors.deleteButtonBackground,
                      iconColor: AppColors.deleteButtonIcon,
                      icon: Icons.close,
                      onPressed: onDelete,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: ActionButton(
                      color: AppColors.mainButtonBackground,
                      icon: Icons.check,
                      onPressed: onKeep,
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
