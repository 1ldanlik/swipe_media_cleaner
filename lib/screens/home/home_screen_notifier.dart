import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_screen_notifier.g.dart';

/// Состояние главного экрана
class HomeScreenState {
  final int? selectedYear;
  final List<int> availableYears;
  final bool isLoading;

  /// key = номер месяца, value = размер в байтах
  final Map<int, int> monthPhotoSizes;

  /// месяцы, для которых сейчас идет подсчет размера
  final Set<int> loadingSizeMonths;

  HomeScreenState({
    this.selectedYear,
    this.availableYears = const [],
    this.isLoading = false,
    this.monthPhotoSizes = const {},
    this.loadingSizeMonths = const {},
  });

  HomeScreenState copyWith({
    int? selectedYear,
    List<int>? availableYears,
    bool? isLoading,
    Map<int, int>? monthPhotoSizes,
    Set<int>? loadingSizeMonths,
  }) {
    return HomeScreenState(
      selectedYear: selectedYear ?? this.selectedYear,
      availableYears: availableYears ?? this.availableYears,
      isLoading: isLoading ?? this.isLoading,
      monthPhotoSizes: monthPhotoSizes ?? this.monthPhotoSizes,
      loadingSizeMonths: loadingSizeMonths ?? this.loadingSizeMonths,
    );
  }
}

/// Notifier для управления состоянием главного экрана
@riverpod
class HomeScreenNotifier extends _$HomeScreenNotifier {
  @override
  HomeScreenState build() {
    return HomeScreenState();
  }

  /// Установить доступные года из фотографий
  void setAvailableYears(List<int> years) {
    if (years.isEmpty) {
      state = HomeScreenState(availableYears: [], selectedYear: null);
      return;
    }

    // Сортируем года по убыванию (новые сверху)
    final sortedYears = List<int>.from(years)..sort((a, b) => b.compareTo(a));

    // Выбираем последний (самый новый) год по умолчанию
    state = HomeScreenState(availableYears: sortedYears, selectedYear: sortedYears.first);
  }

  /// Изменить выбранный год
  void selectYear(int year) {
    if (state.selectedYear != year) {
      state = state.copyWith(selectedYear: year);
    }
  }

  /// Установить состояние загрузки
  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  Future<void> loadMonthPhotoSize({required int year, required int month}) async {
    // Если уже посчитали — не считаем повторно
    if (state.monthPhotoSizes.containsKey(month)) {
      return;
    }

    // Если уже идет подсчет — не запускаем второй раз
    if (state.loadingSizeMonths.contains(month)) {
      return;
    }

    state = state.copyWith(loadingSizeMonths: {...state.loadingSizeMonths, month});

    try {
      final bytes = await calculatePhotoSizeForMonth(year: year, month: month);

      final updatedSizes = {...state.monthPhotoSizes, month: bytes};

      final updatedLoading = {...state.loadingSizeMonths}..remove(month);

      state = state.copyWith(monthPhotoSizes: updatedSizes, loadingSizeMonths: updatedLoading);
    } catch (e) {
      final updatedLoading = {...state.loadingSizeMonths}..remove(month);

      state = state.copyWith(loadingSizeMonths: updatedLoading);

      rethrow;
    }
  }

  Future<int> calculatePhotoSizeForMonth({required int year, required int month}) async {
    try {
      final startOfMonth = DateTime(year, month, 1);
      final startOfNextMonth = DateTime(year, month + 1, 1);

      final filter = FilterOptionGroup(
        createTimeCond: DateTimeCond(min: startOfMonth, max: startOfNextMonth),
        orders: [const OrderOption(type: OrderOptionType.createDate, asc: true)],
      );

      final int totalCount = await PhotoManager.getAssetCount(
        type: RequestType.image,
        filterOption: filter,
      );

      if (totalCount == 0) {
        return 0;
      }

      int totalBytes = 0;

      const assetPageSize = 100;
      const fileBatchSize = 4;

      for (int start = 0; start < totalCount; start += assetPageSize) {
        final end = min(start + assetPageSize, totalCount);

        final assets = await PhotoManager.getAssetListRange(
          start: start,
          end: end,
          type: RequestType.image,
          filterOption: filter,
        );

        for (int i = 0; i < assets.length; i += fileBatchSize) {
          final batch = assets.skip(i).take(fileBatchSize).toList();

          final sizes = await Future.wait(batch.map(_getAssetSizeBytes));

          totalBytes += sizes.fold<int>(0, (sum, size) => sum + size);
        }

        debugPrint('⏳ Размер фото за $month.$year: обработано $end / $totalCount');
      }

      debugPrint('✅ Размер фото за $month.$year: $totalBytes bytes');

      return totalBytes;
    } catch (e, stackTrace) {
      debugPrint('❌ Ошибка подсчета размера фото за $month.$year: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<int> _getAssetSizeBytes(AssetEntity asset) async {
    try {
      final File? file = await asset.originFile;

      if (file == null) {
        return 0;
      }

      return await file.length();
    } catch (e) {
      debugPrint('❌ Ошибка получения размера фото ${asset.id}: $e');
      return 0;
    }
  }
}
