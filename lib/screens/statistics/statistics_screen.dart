import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/deleted_photos_provider.dart';
import '../../theme/app_colors.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statisticsProvider);

    return Scaffold(
      body: SafeArea(
        child: statsAsync.when(
          data: (stats) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  const _StatisticsHeader(),
                  const SizedBox(height: 8),
                  const Text(
                    'Отслеживайте свои достижения',
                    style: TextStyle(fontSize: 16, color: AppColors.greyMedium),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Flexible(
                        child: _StatCard(
                          icon: Icons.photo_library,
                          iconColor: AppColors.statsBlue,
                          title: 'Проверено',
                          value: stats.checkedPhotos.toString(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Flexible(
                        child: _StatCard(
                          icon: Icons.delete,
                          iconColor: AppColors.deleteRed,
                          title: 'Удалено',
                          value: stats.deletedPhotos.toString(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _StatCard(
                    icon: Icons.storage,
                    iconColor: AppColors.successGreen,
                    title: 'Освобождено памяти',
                    value: stats.formattedFreedSpace,
                  ),
                  const Spacer(),
                  const Center(child: _AppVersionText()),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Ошибка: $error')),
        ),
      ),
    );
  }
}

class _AppVersionText extends ConsumerWidget {
  const _AppVersionText();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final versionAsync = ref.watch(appVersionProvider);

    final versionText = versionAsync.when(
      data: (version) => 'Версия $version',
      loading: () => '-',
      error: (_, _) => '-',
    );

    return Text(
      versionText,
      textAlign: TextAlign.end,
      style: const TextStyle(fontSize: 14, color: AppColors.greyMedium),
    );
  }
}

class _StatisticsHeader extends StatelessWidget {
  const _StatisticsHeader();

  @override
  Widget build(BuildContext context) {
    return const Text('Ваш прогресс', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold));
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.cardBorder, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 14, color: AppColors.greyMedium)),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 32, color: iconColor),
                ),
                const SizedBox(width: 16),
                Text(value, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
