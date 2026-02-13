import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';
import '../../providers/permission_provider.dart';
import '../../providers/month_groups_by_year_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/month_card.dart';
import '../../widgets/permission_request_widget.dart';
import 'home_screen_notifier.dart';
import 'widgets/year_selector.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final permissionState = ref.watch(photoPermissionProvider);
    final homeState = ref.watch(homeScreenNotifierProvider);
    final availableYearsAsync = ref.watch(availableYearsProvider);

    return Scaffold(
      body: SafeArea(
        child: permissionState.when(
          data: (state) {
            // Проверяем статус разрешения
            if (state == PermissionState.denied || state == PermissionState.limited) {
              return const Column(
                children: [
                  _HomeScreenHeader(),
                  Expanded(child: PermissionRequestWidget()),
                ],
              );
            }

            // Загружаем доступные года
            return availableYearsAsync.when(
              data: (years) {
                // Устанавливаем доступные года в notifier (только один раз)
                if (homeState.availableYears.isEmpty && years.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ref.read(homeScreenNotifierProvider.notifier).setAvailableYears(years);
                  });
                }

                if (years.isEmpty) {
                  return const Column(
                    children: [
                      _HomeScreenHeader(),
                      Expanded(
                        child: Center(
                          child: Text(
                            'Фотографии не найдены',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  );
                }

                // Загружаем фото для выбранного года
                final monthGroupsAsync =
                    ref.watch(monthGroupsByYearProvider(homeState.selectedYear));

                return Column(
                  children: [
                    const _HomeScreenHeader(),
                    // Виджет выбора года
                    YearSelector(
                      years: homeState.availableYears,
                      selectedYear: homeState.selectedYear,
                      onYearSelected: (year) {
                        ref.read(homeScreenNotifierProvider.notifier).selectYear(year);
                      },
                    ),

                    // Список карточек месяцев
                    Expanded(
                      child: monthGroupsAsync.when(
                        data: (monthGroups) {
                          if (monthGroups.isEmpty) {
                            return Center(
                              child: Text(
                                'Фотографий за ${homeState.selectedYear} год не найдено',
                                style: const TextStyle(fontSize: 18),
                                textAlign: TextAlign.center,
                              ),
                            );
                          }

                          return RefreshIndicator(
                            onRefresh: () async {
                              ref.invalidate(monthGroupsByYearProvider(homeState.selectedYear));
                            },
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: monthGroups.length,
                              itemBuilder: (context, index) {
                                final monthGroup = monthGroups[index];
                                // Берем первые 3 фото для превью
                                final previewPhotos = monthGroup.photos.take(3).toList();

                                return MonthCard(
                                  monthGroup: monthGroup,
                                  previewPhotos: previewPhotos,
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
                                  ref.invalidate(monthGroupsByYearProvider(homeState.selectedYear));
                                },
                                child: const Text('Попробовать снова'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Column(
                children: [
                  _HomeScreenHeader(),
                  Expanded(child: Center(child: CircularProgressIndicator())),
                ],
              ),
              error: (error, stack) => Column(
                children: [
                  const _HomeScreenHeader(),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 64, color: AppColors.deleteRed),
                          const SizedBox(height: 16),
                          Text(
                            'Ошибка загрузки годов:\n$error',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              ref.invalidate(availableYearsProvider);
                            },
                            child: const Text('Попробовать снова'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const Column(
            children: [
              _HomeScreenHeader(),
              Expanded(child: Center(child: CircularProgressIndicator())),
            ],
          ),
          error: (error, stack) => Column(
            children: [
              const _HomeScreenHeader(),
              Expanded(
                child: Center(
                  child: Text('Ошибка проверки разрешений: $error'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeScreenHeader extends StatelessWidget {
  const _HomeScreenHeader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Text(
        'Swipe Cleaner',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
