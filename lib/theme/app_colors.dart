import 'package:flutter/material.dart';

/// Цвета приложения для светлой темы
class AppColors {
  AppColors._(); // Приватный конструктор для предотвращения создания экземпляров

  // === Основные цвета ===

  /// Белый цвет
  static const Color white = Colors.white;

  /// Черный цвет
  static const Color black = Colors.black;

  // === Цвета для экрана корзины ===

  /// Светло-красный фон баннера (Colors.red[50])
  static const Color trashBannerBackground = Color(0xFFFFEBEE);

  /// Темно-красный текст (Colors.red[900])
  static const Color trashBannerText = Color(0xFFB71C1C);

  /// Красный для удаления
  static const Color deleteRed = Colors.red;

  /// Синий для восстановления и выбора
  static const Color restoreBlue = Colors.blue;

  /// Зеленый для успеха
  static const Color successGreen = Colors.green;

  /// Красный оверлей для фото в корзине (0.3 opacity)
  static Color trashPhotoOverlay = Colors.red.withOpacity(0.3);

  /// Синий оверлей для выбранного фото (0.5 opacity)
  static Color selectedPhotoOverlay = Colors.blue.withOpacity(0.5);

  // === Серые оттенки ===

  /// Светло-серый для фона элементов (Colors.grey[300])
  static const Color greyLight = Color(0xFFE0E0E0);

  /// Средний серый для текста и разделителей (Colors.grey[600])
  static const Color greyMedium = Color(0xFF757575);

  /// Темный серый для вторичного текста (Colors.grey[500])
  static const Color greyDark = Color(0xFF9E9E9E);

  /// Очень темный серый для основного текста (Colors.grey[700])
  static const Color greyVeryDark = Color(0xFF616161);

  /// Светло-серый 900 для теней и оверлеев (Colors.grey[900])
  static const Color greyExtraDark = Color(0xFF212121);

  // === Цвета для статистики ===

  /// Синий для иконок статистики
  static const Color statsBlue = Colors.blue;

  /// Оранжевый для предупреждений (Colors.orange[50])
  static const Color warningBackground = Color(0xFFFFF3E0);

  /// Темно-оранжевый для иконок предупреждений (Colors.orange[700])
  static const Color warningIcon = Color(0xFFF57C00);

  /// Желтый для иконок достижений (Colors.amber[700])
  static const Color achievementIcon = Color(0xFFFFA000);

  // === Цвета теней ===

  /// Тень с прозрачностью 0.1
  static Color shadowLight = Colors.black.withOpacity(0.1);

  // === Цвета для виджетов ===

  /// Цвет иконки broken_image
  static const Color brokenImageIcon = Colors.grey;

  /// Цвет иконки успеха (check_circle)
  static const Color checkCircleIcon = Colors.white;

  /// Прозрачный цвет
  static const Color transparent = Colors.transparent;

  /// Белый с прозрачностью 54 (Colors.white54)
  static const Color white54 = Colors.white54;

  /// Белый с прозрачностью 70 (Colors.white70)
  static const Color white70 = Colors.white70;
}
