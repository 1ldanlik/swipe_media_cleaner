import 'photo_item.dart';

/// Модель для группы фотографий по месяцу
class MonthGroup {
  final int year;
  final int month;
  final List<PhotoItem> previewPhotos;
  final int photoCount;

  MonthGroup({
    required this.year,
    required this.month,
    required this.photoCount,
    List<PhotoItem>? previewPhotos,
  }) : previewPhotos = previewPhotos ?? const [];

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
}
