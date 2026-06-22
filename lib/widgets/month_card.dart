import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swipe_media_cleaner/providers/month_groups_by_year_provider.dart';
import 'package:swipe_media_cleaner/screens/home/home_screen_notifier.dart';
import 'package:swipe_media_cleaner/screens/home/widgets/month_photo_size_text.dart';

import '../models/month_group.dart';
import '../models/photo_item.dart';
import '../screens/photo_swipe/photo_swipe_screen.dart';
import '../providers/viewed_photos_provider.dart';
import '../theme/app_colors.dart';
import 'month_preview_photos.dart';
import 'circular_progress_indicator_widget.dart';

final viewedCountByMonthProvider =
    FutureProvider.autoDispose.family<int, (int year, int month)>((ref, params) {
  final viewedPhotosController = ref.watch(viewedPhotosControllerProvider);

  return viewedPhotosController.getViewedCountByMonth(
    params.$1,
    params.$2,
  );
});

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
    final viewedCountAsync = ref.watch(
      viewedCountByMonthProvider((monthGroup.year, monthGroup.month)),
    );

    return viewedCountAsync.when(
      data: (viewedCount) {
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
            onTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PhotoSwipeScreen(
                    monthGroup: monthGroup,
                    viewedCount: viewedCount,
                    totalMonthCount: monthGroup.photoCount,
                  ),
                ),
              );

              final homeState = ref.read(homeScreenProvider);
              ref.invalidate(monthGroupsByYearProvider(homeState.selectedYear));
              ref.invalidate(
                viewedCountByMonthProvider(
                  (monthGroup.year, monthGroup.month),
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
                      if (monthGroup.photoCount > 0) ...[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${monthGroup.photoCount} фото • ',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.greyMedium,
                                  ),
                                ),
                                MonthPhotoSizeText(
                                  year: monthGroup.year,
                                  month: monthGroup.month,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            MonthPreviewPhotos(previewPhotos: previewPhotos),
                          ],
                        ),
                      ],
                    ],
                  ),
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
      },
      loading: () {
        return const Card(
          elevation: 0,
          margin: EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      },
      error: (error, stackTrace) {
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text('Ошибка: $error'),
          ),
        );
      },
    );
  }
}
