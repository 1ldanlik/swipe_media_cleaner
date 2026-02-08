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

    // Группируем фото по месяцам только для выбранного года
    final Map<String, List<PhotoItem>> groupedPhotos = {};
    int processedCount = 0;
    int filteredCount = 0;

    for (int i = 0; i < assets.length; i++) {
      final asset = assets[i];

      // Проверяем год до загрузки файла (оптимизация)
      final photoYear = asset.createDateTime.year;
      if (photoYear != year) {
        continue;
      }

      filteredCount++;

      if (processedCount % 50 == 0 && processedCount > 0) {
        debugPrint('⏳ Обработано фото года $year: $processedCount');
      }

      try {
        // Используем originFile для iOS
        final file = await asset.originFile;
        if (file == null) {
          continue;
        }

        final photoItem = await PhotoItem.fromAsset(asset, file.path);
        if (photoItem == null) {
          continue;
        }

        final date = photoItem.createdDate;
        final key = '${date.year}-${date.month}';

        if (!groupedPhotos.containsKey(key)) {
          groupedPhotos[key] = [];
        }
        groupedPhotos[key]!.add(photoItem);
        processedCount++;
      } catch (e) {
        debugPrint('❌ Ошибка обработки фото ${asset.id}: $e');
        continue;
      }
    }

    debugPrint('📊 Найдено фото для года $year: $filteredCount');
    debugPrint('📊 Успешно обработано: $processedCount');
    debugPrint('📊 Создано групп месяцев: ${groupedPhotos.length}');

    // Преобразуем в список MonthGroup и сортируем
    final List<MonthGroup> monthGroups = groupedPhotos.entries.map((entry) {
      final parts = entry.key.split('-');
      final monthYear = int.parse(parts[0]);
      final month = int.parse(parts[1]);

      return MonthGroup(
        year: monthYear,
        month: month,
        photos: entry.value,
      );
    }).toList();

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
