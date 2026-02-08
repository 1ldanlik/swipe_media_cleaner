import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';

/// Провайдер для проверки статуса разрешения на фото
final photoPermissionProvider = FutureProvider<PermissionState>((ref) async {
  final state = await PhotoManager.requestPermissionExtend();
  return state;
});

/// Провайдер для запроса разрешения
final requestPermissionProvider = FutureProvider.family<bool, void>((ref, _) async {
  final state = await PhotoManager.requestPermissionExtend();

  if (state.isAuth) {
    return true;
  } else if (state.hasAccess) {
    return true;
  } else {
    // Открываем настройки если разрешение было отклонено
    await PhotoManager.openSetting();
    return false;
  }
});
