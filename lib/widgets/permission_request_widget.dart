import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/permission_provider.dart';
import '../theme/app_colors.dart';

class PermissionRequestWidget extends ConsumerWidget {
  const PermissionRequestWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 120,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 32),
            const Text(
              'Доступ к фотографиям',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Для работы приложения необходим доступ к вашим фотографиям',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.greyMedium,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: () async {
                final _ = await ref.refresh(requestPermissionProvider(null).future);
                ref.invalidate(photoPermissionProvider);
              },
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Предоставить доступ'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
