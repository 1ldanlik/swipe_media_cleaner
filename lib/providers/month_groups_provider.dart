import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';
import '../models/photo_item.dart';
import '../models/month_group.dart';

/// Провайдер для загрузки всех фотографий и группировки по месяцам
final monthGroupsProvider = FutureProvider<List<MonthGroup>>((ref) async {
  try {
    debugPrint('🔍 Начинаем загрузку фотографий...');

    // Получаем альбомы (используем альбом "Recent" для всех фото)
    final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      onlyAll: true,
    );

    debugPrint('📁 Найдено альбомов: ${albums.length}');

    if (albums.isEmpty) {
      debugPrint('⚠️ Альбомы не найдены');
      return [];
    }

    // Получаем все фото из первого альбома (обычно это все фото)
    final AssetPathEntity recentAlbum = albums.first;
    final int totalCount = await recentAlbum.assetCountAsync;

    debugPrint('📸 Всего фотографий в альбоме: $totalCount');

    if (totalCount == 0) {
      debugPrint('⚠️ В альбоме нет фотографий');
      return [];
    }

    // Загружаем все фото
    final List<AssetEntity> assets = await recentAlbum.getAssetListRange(
      start: 0,
      end: totalCount,
    );

    debugPrint('✅ Загружено AssetEntity: ${assets.length}');

    // Группируем фото по месяцам
    final Map<String, List<PhotoItem>> groupedPhotos = {};

    for (int i = 0; i < assets.length; i++) {
      final asset = assets[i];

      if (i % 100 == 0) {
        debugPrint('⏳ Обработано фото: $i из ${assets.length}');
      }

      try {
        // Используем originFile вместо file для iOS
        final file = await asset.originFile;
        if (file == null) {
          debugPrint('⚠️ Файл не найден для фото: ${asset.id}');
          continue;
        }

        final photoItem = await PhotoItem.fromAsset(asset, file.path);
        if (photoItem == null) {
          debugPrint('⚠️ Не удалось создать PhotoItem для: ${asset.id}');
          continue;
        }

        final date = photoItem.createdDate;
        final key = '${date.year}-${date.month}';

        if (!groupedPhotos.containsKey(key)) {
          groupedPhotos[key] = [];
        }
        groupedPhotos[key]!.add(photoItem);
      } catch (e) {
        debugPrint('❌ Ошибка обработки фото ${asset.id}: $e');
        continue;
      }
    }

    debugPrint('📊 Создано групп месяцев: ${groupedPhotos.length}');

    // Преобразуем в список MonthGroup и сортируем
    final List<MonthGroup> monthGroups = groupedPhotos.entries.map((entry) {
      final parts = entry.key.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);

      return MonthGroup(
        year: year,
        month: month,
        photos: entry.value,
      );
    }).toList();

    // Сортируем по году и месяцу (новые сверху)
    monthGroups.sort((a, b) {
      if (a.year != b.year) {
        return b.year.compareTo(a.year);
      }
      return b.month.compareTo(a.month);
    });

    debugPrint('✅ Загрузка завершена! Групп: ${monthGroups.length}');

    return monthGroups;
  } catch (e, stackTrace) {
    debugPrint('❌ Критическая ошибка при загрузке фотографий: $e');
    debugPrint('Stack trace: $stackTrace');
    rethrow;
  }
});
