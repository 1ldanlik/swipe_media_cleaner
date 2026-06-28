import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

/// Провайдер для проверки статуса разрешения на фото через permission_handler
final photoPermissionProvider = FutureProvider<PermissionStatus>((ref) async {
  debugPrint('🔐 Проверяем разрешения на доступ к фото через permission_handler...');

  final status = await Permission.photos.status;

  debugPrint('🔐 Permission.photos status: $status');
  debugPrint('🔐 isGranted: ${status.isGranted}');
  debugPrint('🔐 isLimited: ${status.isLimited}');
  debugPrint('🔐 isDenied: ${status.isDenied}');
  debugPrint('🔐 isPermanentlyDenied: ${status.isPermanentlyDenied}');

  return status;
});

/// Провайдер для запроса разрешения через permission_handler
final requestPermissionProvider = FutureProvider.family<bool, void>((ref, _) async {
  debugPrint('📱 Запрашиваем разрешение на доступ к фото...');

  final currentStatus = await Permission.photos.status;

  debugPrint('📱 Текущий Permission.photos status: $currentStatus');

  if (currentStatus.isGranted || currentStatus.isLimited) {
    ref.invalidate(photoPermissionProvider);
    return true;
  }

  if (currentStatus.isPermanentlyDenied || currentStatus.isRestricted) {
    debugPrint('❌ Доступ заблокирован, открываем настройки');
    await openAppSettings();
    ref.invalidate(photoPermissionProvider);
    return false;
  }

  final status = await Permission.photos.request();

  debugPrint('📱 Результат запроса Permission.photos: $status');
  debugPrint('📱 isGranted: ${status.isGranted}');
  debugPrint('📱 isLimited: ${status.isLimited}');
  debugPrint('📱 isDenied: ${status.isDenied}');
  debugPrint('📱 isPermanentlyDenied: ${status.isPermanentlyDenied}');

  ref.invalidate(photoPermissionProvider);

  if (status.isGranted || status.isLimited) {
    debugPrint('✅ Доступ к фото получен');
    return true;
  }

  if (status.isPermanentlyDenied || status.isRestricted) {
    debugPrint('❌ Доступ запрещён навсегда, открываем настройки');
    await openAppSettings();
  }

  return false;
});

/// Есть ли хоть какой-то доступ к фото.
/// granted или limited = true.
final hasPhotoAccessProvider = Provider<bool>((ref) {
  final permissionAsync = ref.watch(photoPermissionProvider);

  return permissionAsync.maybeWhen(
    data: (status) => status.isGranted || status.isLimited,
    orElse: () => false,
  );
});

/// Есть ли полный доступ к фото.
final hasFullPhotoAccessProvider = Provider<bool>((ref) {
  final permissionAsync = ref.watch(photoPermissionProvider);

  return permissionAsync.maybeWhen(data: (status) => status.isGranted, orElse: () => false);
});

/// Limited-доступ.
final hasLimitedPhotoAccessProvider = Provider<bool>((ref) {
  final permissionAsync = ref.watch(photoPermissionProvider);

  return permissionAsync.maybeWhen(data: (status) => status.isLimited, orElse: () => false);
});
