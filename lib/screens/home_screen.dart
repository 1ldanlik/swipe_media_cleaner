import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';
import '../providers/permission_provider.dart';
import '../providers/month_groups_with_preview_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/month_card.dart';
import '../widgets/permission_request_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissionState = ref.watch(photoPermissionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Swipe Media Cleaner'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: permissionState.when(
        data: (state) {
          // Проверяем статус разрешения
          if (state == PermissionState.denied || state == PermissionState.limited) {
            return const PermissionRequestWidget();
          }

          // Загружаем фото с превью если есть разрешение
          final monthGroupsAsync = ref.watch(monthGroupsWithPreviewProvider);

          return monthGroupsAsync.when(
            data: (monthGroupsWithPreview) {
              if (monthGroupsWithPreview.isEmpty) {
                return const Center(
                  child: Text(
                    'Фотографии не найдены',
                    style: TextStyle(fontSize: 18),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(monthGroupsWithPreviewProvider);
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: monthGroupsWithPreview.length,
                  itemBuilder: (context, index) {
                    final item = monthGroupsWithPreview[index];
                    return MonthCard(
                      monthGroup: item.monthGroup,
                      previewPhotos: item.previewPhotos,
                    );
                  },
                ),
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: AppColors.deleteRed),
                  const SizedBox(height: 16),
                  Text(
                    'Ошибка загрузки фото:\n$error',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ref.invalidate(monthGroupsWithPreviewProvider);
                    },
                    child: const Text('Попробовать снова'),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text('Ошибка проверки разрешений: $error'),
        ),
      ),
    );
  }
}
