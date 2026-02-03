import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/deleted_photos_provider.dart';
import 'widgets/empty_statistics_widget.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statisticsProvider);
    final deletedPhotosAsync = ref.watch(deletedPhotosProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Статистика'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: statsAsync.when(
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
                    const Text(
                      'Ваш прогресс',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Отслеживайте свои достижения',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 32),

                    _buildStatCard(
                      context,
                      icon: Icons.photo_library,
                      iconColor: Colors.blue,
                      title: 'Проверено фотографий',
                      value: stats.checkedPhotos.toString(),
                      subtitle: 'Всего просмотрено',
                    ),
                    const SizedBox(height: 16),

                    _buildStatCard(
                      context,
                      icon: Icons.delete,
                      iconColor: Colors.red,
                      title: 'Удалено фотографий',
                      value: stats.deletedPhotos.toString(),
                      subtitle: 'Удалено навсегда',
                    ),
                    const SizedBox(height: 16),

                    _buildStatCard(
                      context,
                      icon: Icons.storage,
                      iconColor: Colors.green,
                      title: 'Освобождено памяти',
                      value: stats.formattedFreedSpace,
                      subtitle: 'Реально освобождено',
                    ),
                    
                    if (stats.checkedPhotos == 0 && trashCount == 0) ...[
                      const SizedBox(height: 32),
                      const EmptyStatisticsWidget(),
                    ],

                    const SizedBox(height: 32),

                    if (trashCount > 0) ...[
                      Card(
                        elevation: 2,
                        color: Colors.orange[50],
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.delete_outline,
                                    color: Colors.orange[700],
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
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
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    if (stats.deletedPhotos > 0) ...[
                      const SizedBox(height: 16),
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.celebration,
                                    color: Colors.amber[700],
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
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
                                'Вы уже удалили ${stats.deletedPhotos} фото и '
                                'освободили ${stats.formattedFreedSpace} памяти! '
                                'Продолжайте в том же духе! 🎉',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
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
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
  }) {
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
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
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
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
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
}
