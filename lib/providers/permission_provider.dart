import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';

/// Провайдер для проверки статуса разрешения на фото
final photoPermissionProvider = FutureProvider<PermissionState>((ref) async {
  debugPrint('🔐 Проверяем разрешения на доступ к фото...');
  final state = await PhotoManager.requestPermissionExtend();
  debugPrint('🔐 Статус разрешения: $state');
  debugPrint('🔐 isAuth: ${state.isAuth}');
  debugPrint('🔐 hasAccess: ${state.hasAccess}');
  return state;
});

/// Провайдер для запроса разрешения
final requestPermissionProvider = FutureProvider.family<bool, void>((ref, _) async {
  debugPrint('📱 Запрашиваем разрешение на доступ к фото...');
  final state = await PhotoManager.requestPermissionExtend();

  debugPrint('📱 Результат запроса: $state');

  if (state.isAuth) {
    debugPrint('✅ Полный доступ получен');
    return true;
  } else if (state.hasAccess) {
    debugPrint('⚠️ Ограниченный доступ');
    return true;
  } else {
    debugPrint('❌ Доступ запрещен, открываем настройки');
    // Открываем настройки если разрешение было отклонено
    await PhotoManager.openSetting();
    return false;
  }
});
