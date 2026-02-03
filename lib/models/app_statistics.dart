import 'package:hive/hive.dart';

part 'app_statistics.g.dart';

@HiveType(typeId: 1)
class AppStatistics extends HiveObject {
  @HiveField(0)
  int checkedPhotos;

  @HiveField(1)
  int deletedPhotos;

  @HiveField(2)
  int freedSpace; // в байтах

  AppStatistics({
    this.checkedPhotos = 0,
    this.deletedPhotos = 0,
    this.freedSpace = 0,
  });

  /// Увеличить счетчик просмотренных фото
  void incrementChecked() {
    checkedPhotos++;
    save();
  }

  /// Добавить удаленное фото
  void addDeleted(int photoSize) {
    deletedPhotos++;
    freedSpace += photoSize;
    save();
  }

  /// Восстановить фото (уменьшить счетчики)
  void restorePhoto(int photoSize) {
    if (deletedPhotos > 0) {
      deletedPhotos--;
    }
    if (freedSpace >= photoSize) {
      freedSpace -= photoSize;
    }
    save();
  }

  /// Сбросить статистику удаленных (после окончательного удаления)
  void resetDeleted() {
    deletedPhotos = 0;
    freedSpace = 0;
    save();
  }

  /// Форматированный размер освобожденной памяти
  String get formattedFreedSpace {
    if (freedSpace < 1024) return '$freedSpace B';
    if (freedSpace < 1024 * 1024) {
      return '${(freedSpace / 1024).toStringAsFixed(1)} KB';
    }
    if (freedSpace < 1024 * 1024 * 1024) {
      return '${(freedSpace / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(freedSpace / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}
