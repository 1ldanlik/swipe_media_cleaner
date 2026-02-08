import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_screen_notifier.g.dart';

/// Состояние главного экрана
class HomeScreenState {
  final int? selectedYear;
  final List<int> availableYears;
  final bool isLoading;

  HomeScreenState({
    this.selectedYear,
    this.availableYears = const [],
    this.isLoading = false,
  });

  HomeScreenState copyWith({
    int? selectedYear,
    List<int>? availableYears,
    bool? isLoading,
  }) {
    return HomeScreenState(
      selectedYear: selectedYear ?? this.selectedYear,
      availableYears: availableYears ?? this.availableYears,
      isLoading: isLoading ?? this.isLoading,
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
      state = HomeScreenState(
        availableYears: [],
        selectedYear: null,
      );
      return;
    }

    // Сортируем года по убыванию (новые сверху)
    final sortedYears = List<int>.from(years)..sort((a, b) => b.compareTo(a));

    // Выбираем последний (самый новый) год по умолчанию
    state = HomeScreenState(
      availableYears: sortedYears,
      selectedYear: sortedYears.first,
    );
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
}
