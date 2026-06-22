/// Доменная модель просмотренного фото.
class ViewedPhoto {
  final String id;
  final int year;
  final int month;
  final DateTime viewedAt;

  const ViewedPhoto({
    required this.id,
    required this.year,
    required this.month,
    required this.viewedAt,
  });

  ViewedPhoto copyWith({
    String? id,
    int? year,
    int? month,
    DateTime? viewedAt,
  }) {
    return ViewedPhoto(
      id: id ?? this.id,
      year: year ?? this.year,
      month: month ?? this.month,
      viewedAt: viewedAt ?? this.viewedAt,
    );
  }

  @override
  int get hashCode => Object.hash(id, year, month, viewedAt);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is ViewedPhoto &&
        other.id == id &&
        other.year == year &&
        other.month == month &&
        other.viewedAt == viewedAt;
  }
}
