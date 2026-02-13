import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/month_group.dart';
import '../models/photo_item.dart';
import '../screens/photo_swipe/photo_swipe_screen.dart';
import '../providers/viewed_photos_provider.dart';
import '../theme/app_colors.dart';
import 'month_preview_photos.dart';
import 'circular_progress_indicator_widget.dart';

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

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(
          color: AppColors.cardBorder,
          width: 2,
        ),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        monthGroup.monthName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${monthGroup.year}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.greyMedium,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Прогресс-бар
                  if (monthGroup.photoCount > 0) ...[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${monthGroup.photoCount} фото • ${monthGroup.formattedSize}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.greyMedium,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Превью фотографий
                        MonthPreviewPhotos(previewPhotos: previewPhotos),
                      ],
                    ),
                  ],
                ],
              ),
              // Круговой индикатор прогресса справа
              CircularProgressIndicatorWidget(
                progress: progress,
                size: 110,
                strokeWidth: 12,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
