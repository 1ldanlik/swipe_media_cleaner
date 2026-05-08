import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';
import '../models/photo_item.dart';
import '../models/month_group.dart';

/// Провайдер для загрузки фотографий по выбранному году
final monthGroupsByYearProvider = FutureProvider.family<List<MonthGroup>, int?>((ref, year) async {
  if (year == null) {
    debugPrint('⚠️ Год не выбран, возвращаем пустой список');
    return [];
  }

  try {
    debugPrint('🔍 Загружаем фотографии для года: $year');

    // Получаем альбомы
    final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      onlyAll: true,
    );

    if (albums.isEmpty) {
      debugPrint('⚠️ Альбомы не найдены');
      return [];
    }

    final AssetPathEntity recentAlbum = albums.first;
    final int totalCount = await recentAlbum.assetCountAsync;

    debugPrint('📸 Всего фотографий: $totalCount');

    if (totalCount == 0) {
      debugPrint('⚠️ Фотографий не найдено');
      return [];
    }

    // Загружаем все фото
    final List<AssetEntity> assets = await recentAlbum.getAssetListRange(
      start: 0,
      end: totalCount,
    );

    debugPrint('✅ Загружено AssetEntity: ${assets.length}');

    // Группируем фото по месяцам только для выбранного года (без загрузки файлов)
    final Map<String, List<AssetEntity>> groupedAssets = {};
    int filteredCount = 0;

    for (int i = 0; i < assets.length; i++) {
      final asset = assets[i];

      // Проверяем год до загрузки файла (оптимизация)
      final photoYear = asset.createDateTime.year;
      if (photoYear != year) {
        continue;
      }

      filteredCount++;

      if (filteredCount % 500 == 0 && filteredCount > 0) {
        debugPrint('⏳ Обработано метаданных фото года $year: $filteredCount');
      }

      final date = asset.createDateTime;
      final key = '${date.year}-${date.month}';

      if (!groupedAssets.containsKey(key)) {
        groupedAssets[key] = [];
      }
      groupedAssets[key]!.add(asset);
    }

    debugPrint('📊 Найдено фото для года $year: $filteredCount');
    debugPrint('📊 Создано групп месяцев: ${groupedAssets.length}');

    // Преобразуем в список MonthGroup с легковесными данными Home-экрана
    final List<MonthGroup> monthGroups = [];

    for (final entry in groupedAssets.entries) {
      final parts = entry.key.split('-');
      final monthYear = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final monthAssets = entry.value;

      final previewPhotos = await _buildPreviewPhotos(monthAssets);

      monthGroups.add(MonthGroup(
        year: monthYear,
        month: month,
        photoCount: monthAssets.length,
        previewPhotos: previewPhotos,
      ));
    }

    // Сортируем по месяцу (новые сверху)
    monthGroups.sort((a, b) => b.month.compareTo(a.month));

    debugPrint('✅ Загрузка для года $year завершена! Групп: ${monthGroups.length}');

    return monthGroups;
  } catch (e, stackTrace) {
    debugPrint('❌ Критическая ошибка при загрузке фотографий для года $year: $e');
    debugPrint('Stack trace: $stackTrace');
    rethrow;
  }
});

Future<List<PhotoItem>> _buildPreviewPhotos(List<AssetEntity> assets) async {
  if (assets.isEmpty) {
    return [];
  }

  final Set<int> indices = {0};
  if (assets.length > 1) {
    indices.add(assets.length ~/ 2);
    indices.add(assets.length - 1);
  }

  final List<PhotoItem> result = [];

  for (final index in indices) {
    try {
      final asset = assets[index];
      final file = await asset.originFile;
      if (file == null) {
        continue;
      }

      final photoItem = await PhotoItem.fromAsset(asset, file.path);
      if (photoItem != null) {
        result.add(photoItem);
      }
    } catch (e) {
      debugPrint('❌ Ошибка загрузки превью фото: $e');
    }
  }

  return result;
}

/// Провайдер для получения списка доступных годов
final availableYearsProvider = FutureProvider<List<int>>((ref) async {
  try {
    debugPrint('🔍 Загружаем список доступных годов...');

    final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      onlyAll: true,
    );

    if (albums.isEmpty) {
      debugPrint('⚠️ Альбомы не найдены');
      return [];
    }

    final AssetPathEntity recentAlbum = albums.first;
    final int totalCount = await recentAlbum.assetCountAsync;

    if (totalCount == 0) {
      debugPrint('⚠️ Фотографий не найдено');
      return [];
    }

    // Загружаем все фото (только метаданные, без файлов)
    final List<AssetEntity> assets = await recentAlbum.getAssetListRange(
      start: 0,
      end: totalCount,
    );

    // Собираем уникальные года
    final Set<int> years = {};
    for (final asset in assets) {
      years.add(asset.createDateTime.year);
    }

    final sortedYears = years.toList()..sort((a, b) => b.compareTo(a));

    debugPrint('📅 Найдено годов: ${sortedYears.length} -> $sortedYears');

    return sortedYears;
  } catch (e, stackTrace) {
    debugPrint('❌ Ошибка при загрузке списка годов: $e');
    debugPrint('Stack trace: $stackTrace');
    rethrow;
  }
});
