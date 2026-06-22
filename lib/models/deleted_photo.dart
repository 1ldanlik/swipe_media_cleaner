/// Доменная модель удалённого фото для использования в мапперах и UI.
class DeletedPhoto {
  final String id;
  final String path;
  final int size;
  final DateTime deletedAt;
  final int year;
  final int month;

  const DeletedPhoto({
    required this.id,
    required this.path,
    required this.size,
    required this.deletedAt,
    required this.year,
    required this.month,
  });

  DeletedPhoto copyWith({
    String? id,
    String? path,
    int? size,
    DateTime? deletedAt,
    int? year,
    int? month,
  }) {
    return DeletedPhoto(
      id: id ?? this.id,
      path: path ?? this.path,
      size: size ?? this.size,
      deletedAt: deletedAt ?? this.deletedAt,
      year: year ?? this.year,
      month: month ?? this.month,
    );
  }

  @override
  int get hashCode => Object.hash(id, path, size, deletedAt, year, month);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is DeletedPhoto &&
        other.id == id &&
        other.path == path &&
        other.size == size &&
        other.deletedAt == deletedAt &&
        other.year == year &&
        other.month == month;
  }
}
