import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swipe_media_cleaner/screens/photo_swipe/widgets/options_menu.dart';
import 'package:swipe_media_cleaner/utils/file_size_formatter.dart';
import '../../models/month_group.dart';
import '../../models/photo_item.dart';
import '../../providers/photo_swipe_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/swipeable_photo_card.dart';
import 'widgets/action_button.dart';

class PhotoSwipeScreen extends ConsumerStatefulWidget {
  final MonthGroup monthGroup;
  final int viewedCount;
  final int totalMonthCount;

  const PhotoSwipeScreen({
    super.key,
    required this.monthGroup,
    required this.viewedCount,
    required this.totalMonthCount,
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
            viewedCount: widget.viewedCount,
            totalMonthCount: widget.totalMonthCount,
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
          notifier.loadPhotosForMonth();
        },
      );
    }

    return _MainScaffold(
      monthName: widget.monthGroup.monthName,
      year: widget.monthGroup.year,
      alreadyViewedCount: state.alreadyViewedCount,
      totalPhotosInMonth: state.totalPhotosInMonth,
      bufferedPhotos: state.bufferedPhotos,
      currentPhotoIsFavorite: state.currentPhotoIsFavorite,
      isFullPictureShow: state.isFullPictureShow,
      isFinished: state.isFinished,
      onFullPictureShowToggle: () => notifier.toggleFullPicture(),
      onDelete: () => notifier.deleteCurrentPhoto(),
      onKeep: () => notifier.keepCurrentPhoto(),
      onToggleFavorite: () => notifier.toggleFavorite(),
      onShareTap: () => notifier.shareAssetPhoto(),
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
  final int alreadyViewedCount;
  final int totalPhotosInMonth;
  final List<PhotoItem> bufferedPhotos;
  final bool currentPhotoIsFavorite;
  final bool isFullPictureShow;
  final bool isFinished;
  final VoidCallback onFullPictureShowToggle;
  final VoidCallback onDelete;
  final VoidCallback onKeep;
  final VoidCallback onToggleFavorite;
  final VoidCallback onShareTap;

  const _MainScaffold({
    required this.monthName,
    required this.year,
    required this.alreadyViewedCount,
    required this.totalPhotosInMonth,
    required this.bufferedPhotos,
    required this.currentPhotoIsFavorite,
    required this.isFullPictureShow,
    required this.isFinished,
    required this.onFullPictureShowToggle,
    required this.onDelete,
    required this.onKeep,
    required this.onToggleFavorite,
    required this.onShareTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalPhotosInMonth == 0
        ? 0.0
        : ((alreadyViewedCount + 1) / totalPhotosInMonth).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: AppColors.greyExtraLight,
      appBar: AppBar(
        backgroundColor: AppColors.greyExtraLight,
        foregroundColor: AppColors.black,
        title: Text(
          '$monthName $year',
          style: const TextStyle(fontSize: 24),
        ),
        actions: isFinished
            ? null
            : [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Text(
                    '${alreadyViewedCount + 1} / $totalPhotosInMonth',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
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
      body: !isFinished
          ? Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      if (bufferedPhotos.length > 1)
                        SwipeablePhotoCard(
                          key: ValueKey(bufferedPhotos[1].id),
                          photo: bufferedPhotos[1],
                          onSwipeLeft: onDelete,
                          onSwipeRight: onKeep,
                          isFullPictureShow: isFullPictureShow,
                        ),
                      SwipeablePhotoCard(
                        key: ValueKey(bufferedPhotos.first.id),
                        photo: bufferedPhotos.first,
                        onSwipeLeft: onDelete,
                        onSwipeRight: onKeep,
                        isFullPictureShow: isFullPictureShow,
                      ),
                      Positioned(
                        right: 8,
                        bottom: MediaQuery.of(context).size.height * 0.1,
                        child: OptionsMenu(
                          onFullPictureShowToggle: onFullPictureShowToggle,
                          isFullPictureShow: isFullPictureShow,
                          isFinished: isFinished,
                          currentPhotoIsFavorite: currentPhotoIsFavorite,
                          onToggleFavorite: onToggleFavorite,
                          onShareTap: onShareTap,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    FileSizeFormatter.formatBytes(bufferedPhotos.first.size),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.greyMedium,
                    ),
                  ),
                ),
              ],
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
      bottomNavigationBar: !isFinished
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
