import 'photo_item.dart';

/// Модель для группы фотографий по месяцу
class MonthGroup {
  final int year;
  final int month;
  final List<PhotoItem> photos;

  MonthGroup({
    required this.year,
    required this.month,
    required this.photos,
  });

  /// Название месяца на русском
  String get monthName {
    const monthNames = [
      'Январь',
      'Февраль',
      'Март',
      'Апрель',
      'Май',
      'Июнь',
      'Июль',
      'Август',
      'Сентябрь',
      'Октябрь',
      'Ноябрь',
      'Декабрь',
    ];
    return monthNames[month - 1];
  }

  /// Общий размер всех фото в группе (в байтах)
  int get totalSize => photos.fold(0, (sum, photo) => sum + photo.size);

  /// Количество фото в группе
  int get photoCount => photos.length;

  /// Форматированный размер (например: "15.3 MB")
  String get formattedSize {
    if (totalSize < 1024) return '$totalSize B';
    if (totalSize < 1024 * 1024) {
      return '${(totalSize / 1024).toStringAsFixed(1)} KB';
    }
    if (totalSize < 1024 * 1024 * 1024) {
      return '${(totalSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(totalSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
