import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Тема приложения
class AppTheme {
  AppTheme._(); // Приватный конструктор для предотвращения создания экземпляров

  /// Светлая тема приложения
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.backgroundColor,
    );
  }

  // В будущем можно добавить темную тему:
  // static ThemeData get darkTheme {
  //   return ThemeData(
  //     colorScheme: ColorScheme.fromSeed(
  //       seedColor: Colors.deepPurple,
  //       brightness: Brightness.dark,
  //     ),
  //     useMaterial3: true,
  //     scaffoldBackgroundColor: AppColors.backgroundColorDark,
  //   );
  // }
}
