import 'package:drift/drift.dart';

/// Конвертер для преобразования DateTime в timestamp типа int и обратно.
///
/// По умолчанию drift сохраняет DateTime в базе данных в виде timestamp типа int с точностью до
/// секунды.
/// Этот конвертер позволяет сохранять DateTime с точностью до миллисекунды.
class MillisDateConverter extends TypeConverter<DateTime, int> {
  /// Возвращает экземпляр класса [MillisDateConverter].
  const MillisDateConverter();

  @override
  DateTime fromSql(int fromDb) {
    return DateTime.fromMillisecondsSinceEpoch(fromDb);
  }

  @override
  int toSql(DateTime value) => value.millisecondsSinceEpoch;
}
