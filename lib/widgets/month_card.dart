import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/month_group.dart';
import '../models/photo_item.dart';
import '../screens/photo_swipe_screen.dart';
import '../providers/viewed_photos_provider.dart';
import '../theme/app_colors.dart';
import 'month_preview_photos.dart';

class MonthCard extends ConsumerWidget {
  final MonthGroup monthGroup;
  final List<PhotoItem> previewPhotos;

  const MonthCard({
    super.key,
    required this.monthGroup,
    required this.previewPhotos,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewedPhotosService = ref.watch(viewedPhotosServiceProvider);
    final viewedCount =
        viewedPhotosService.getViewedCountByMonth(monthGroup.year, monthGroup.month);
    final progress = monthGroup.photoCount > 0 ? viewedCount / monthGroup.photoCount : 0.0;
    final isCompleted = viewedCount >= monthGroup.photoCount && monthGroup.photoCount > 0;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PhotoSwipeScreen(monthGroup: monthGroup),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    monthGroup.monthName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Предпросмотр фотографий
                  MonthPreviewPhotos(previewPhotos: previewPhotos),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${monthGroup.year}',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.greyMedium,
                ),
              ),

              const SizedBox(height: 16),

              // Прогресс-бар
              if (monthGroup.photoCount > 0) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Просмотрено',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.greyMedium,
                          ),
                        ),
                        Text(
                          '$viewedCount из ${monthGroup.photoCount}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isCompleted
                                ? AppColors.successGreen
                                : Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: AppColors.greyLight,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isCompleted
                              ? AppColors.successGreen
                              : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              const Divider(),
              const SizedBox(height: 12),

              // Информация о количестве фото и размере
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoItem(
                    icon: Icons.photo_library,
                    label: 'Фотографий',
                    value: '${monthGroup.photoCount}',
                    context: context,
                  ),
                  _buildInfoItem(
                    icon: Icons.storage,
                    label: 'Размер',
                    value: monthGroup.formattedSize,
                    context: context,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required BuildContext context,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.secondary,
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.greyMedium,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
