import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/deleted_photos_provider.dart';
import '../../theme/app_colors.dart';
import 'widgets/empty_statistics_widget.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statisticsProvider);
    final deletedPhotosAsync = ref.watch(deletedPhotosProvider);

    return Scaffold(
      body: SafeArea(
        child: statsAsync.when(
          data: (stats) {
            return deletedPhotosAsync.when(
              data: (photosInTrash) {
                final trashCount = photosInTrash.length;
                final trashSize = photosInTrash.fold<int>(
                  0,
                  (sum, photo) => sum + photo.size,
                );

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _StatisticsHeader(),
                      const SizedBox(height: 8),
                      const Text(
                        'Отслеживайте свои достижения',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.greyMedium,
                        ),
                      ),
                      const SizedBox(height: 32),
                      _StatCard(
                        icon: Icons.photo_library,
                        iconColor: AppColors.statsBlue,
                        title: 'Проверено фотографий',
                        value: stats.checkedPhotos.toString(),
                        subtitle: 'Всего просмотрено',
                      ),
                      const SizedBox(height: 16),
                      _StatCard(
                        icon: Icons.delete,
                        iconColor: AppColors.deleteRed,
                        title: 'Удалено фотографий',
                        value: stats.deletedPhotos.toString(),
                        subtitle: 'Удалено навсегда',
                      ),
                      const SizedBox(height: 16),
                      _StatCard(
                        icon: Icons.storage,
                        iconColor: AppColors.successGreen,
                        title: 'Освобождено памяти',
                        value: stats.formattedFreedSpace,
                        subtitle: 'Реально освобождено',
                      ),
                      if (stats.checkedPhotos == 0 && trashCount == 0) ...[
                        const SizedBox(height: 32),
                        const EmptyStatisticsWidget(),
                      ],
                      const SizedBox(height: 32),
                      if (trashCount > 0)
                        _TrashWarningCard(
                          trashCount: trashCount,
                          trashSize: trashSize,
                        ),
                      if (stats.deletedPhotos > 0) ...[
                        const SizedBox(height: 16),
                        _AchievementCard(
                          deletedPhotos: stats.deletedPhotos,
                          freedSpace: stats.formattedFreedSpace,
                        ),
                      ],
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Ошибка: $error'),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('Ошибка: $error'),
          ),
        ),
      ),
    );
  }
}

class _StatisticsHeader extends StatelessWidget {
  const _StatisticsHeader();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Ваш прогресс',
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String subtitle;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 32,
                color: iconColor,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.greyMedium,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.greyDark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrashWarningCard extends StatelessWidget {
  final int trashCount;
  final int trashSize;

  const _TrashWarningCard({
    required this.trashCount,
    required this.trashSize,
  });

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: AppColors.warningBackground,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.delete_outline,
                  color: AppColors.warningIcon,
                ),
                SizedBox(width: 12),
                Text(
                  'В корзине',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'У вас $trashCount фото в корзине (${_formatBytes(trashSize)}). '
              'Они еще не удалены! Перейдите на вкладку "Корзина", '
              'чтобы удалить их окончательно.',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.greyVeryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final int deletedPhotos;
  final String freedSpace;

  const _AchievementCard({
    required this.deletedPhotos,
    required this.freedSpace,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.celebration,
                  color: AppColors.achievementIcon,
                ),
                SizedBox(width: 12),
                Text(
                  'Отличная работа!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Вы уже удалили $deletedPhotos фото и '
              'освободили $freedSpace памяти! '
              'Продолжайте в том же духе! 🎉',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.greyVeryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
