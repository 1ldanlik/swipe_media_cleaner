import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';
import '../models/photo_item.dart';
import '../models/month_group.dart';

/// Провайдер для загрузки всех фотографий и группировки по месяцам
final monthGroupsProvider = FutureProvider<List<MonthGroup>>((ref) async {
  // Получаем альбомы (используем альбом "Recent" для всех фото)
  final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
    type: RequestType.image,
    onlyAll: true,
  );

  if (albums.isEmpty) {
    return [];
  }

  // Получаем все фото из первого альбома (обычно это все фото)
  final AssetPathEntity recentAlbum = albums.first;
  final int totalCount = await recentAlbum.assetCountAsync;

  // Загружаем все фото
  final List<AssetEntity> assets = await recentAlbum.getAssetListRange(
    start: 0,
    end: totalCount,
  );

  // Группируем фото по месяцам
  final Map<String, List<PhotoItem>> groupedPhotos = {};

  for (final asset in assets) {
    final file = await asset.file;
    if (file == null) continue;

    final photoItem = await PhotoItem.fromAsset(asset, file.path);
    if (photoItem == null) continue;
    
    final date = photoItem.createdDate;
    final key = '${date.year}-${date.month}';

    if (!groupedPhotos.containsKey(key)) {
      groupedPhotos[key] = [];
    }
    groupedPhotos[key]!.add(photoItem);
  }

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

  return monthGroups;
});
