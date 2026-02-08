import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/month_group.dart';
import '../screens/photo_swipe_screen.dart';
import '../providers/viewed_photos_provider.dart';

class MonthCard extends ConsumerWidget {
  final MonthGroup monthGroup;

  const MonthCard({
    super.key,
    required this.monthGroup,
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
                  // Название месяца и год
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
                          if (isCompleted) ...[
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 24,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${monthGroup.year}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),

                  // Иконка календаря
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? Colors.green.withOpacity(0.2)
                          : Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isCompleted ? Icons.done_all : Icons.calendar_month,
                      size: 32,
                      color: isCompleted ? Colors.green : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
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
                        Text(
                          'Просмотрено',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          '$viewedCount из ${monthGroup.photoCount}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color:
                                isCompleted ? Colors.green : Theme.of(context).colorScheme.primary,
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
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isCompleted ? Colors.green : Theme.of(context).colorScheme.primary,
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
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
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
