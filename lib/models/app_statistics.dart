/// Доменная модель статистики приложения.
class AppStatistic {
  final int id;
  final int checkedPhotos;
  final int deletedPhotos;
  final int freedSpace;

  const AppStatistic({
    required this.id,
    required this.checkedPhotos,
    required this.deletedPhotos,
    required this.freedSpace,
  });

  AppStatistic copyWith({
    int? id,
    int? checkedPhotos,
    int? deletedPhotos,
    int? freedSpace,
  }) {
    return AppStatistic(
      id: id ?? this.id,
      checkedPhotos: checkedPhotos ?? this.checkedPhotos,
      deletedPhotos: deletedPhotos ?? this.deletedPhotos,
      freedSpace: freedSpace ?? this.freedSpace,
    );
  }

  @override
  int get hashCode => Object.hash(id, checkedPhotos, deletedPhotos, freedSpace);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is AppStatistic &&
        other.id == id &&
        other.checkedPhotos == checkedPhotos &&
        other.deletedPhotos == deletedPhotos &&
        other.freedSpace == freedSpace;
  }
}
