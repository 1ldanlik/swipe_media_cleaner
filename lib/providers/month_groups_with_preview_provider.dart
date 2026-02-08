import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/month_group.dart';
import '../models/photo_item.dart';
import 'month_groups_provider.dart';

/// Модель для хранения месяца с превью фотографиями
class MonthGroupWithPreview {
  final MonthGroup monthGroup;
  final List<PhotoItem> previewPhotos;

  MonthGroupWithPreview({
    required this.monthGroup,
    required this.previewPhotos,
  });
}

/// Провайдер для подготовки данных с превью фотографиями
final monthGroupsWithPreviewProvider = FutureProvider<List<MonthGroupWithPreview>>((ref) async {
  // Сначала получаем все группы месяцев
  final monthGroups = await ref.watch(monthGroupsProvider.future);

  // Для каждой группы подготавливаем превью из 3 фотографий
  final List<MonthGroupWithPreview> result = [];

  for (final monthGroup in monthGroups) {
    final previewPhotos = _getPreviewPhotos(monthGroup.photos);
    result.add(MonthGroupWithPreview(
      monthGroup: monthGroup,
      previewPhotos: previewPhotos,
    ));
  }

  return result;
});

/// Получает первую, среднюю и последнюю фотографию из списка
List<PhotoItem> _getPreviewPhotos(List<PhotoItem> photos) {
  if (photos.isEmpty) return [];
  if (photos.length == 1) return [photos[0]];
  if (photos.length == 2) return [photos[0], photos[1]];

  final first = photos[0];
  final middle = photos[photos.length ~/ 2];
  final last = photos[photos.length - 1];

  return [first, middle, last];
}
