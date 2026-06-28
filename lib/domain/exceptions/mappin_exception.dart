/// Исключение, возникающее при маппинге данных из API.
class MappingException implements Exception {
  /// Тип исключения маппинга.
  final MappingExceptionType type;

  /// Название поля, которое пытались смаппить.
  final String fieldName;

  /// Значение, которое пытались смаппить.
  final String? actualValue;

  /// Создаёт [MappingException].
  const MappingException({required this.fieldName, required this.type, this.actualValue});

  /// Конструктор для исключения заглушки, которое не подходит под остальные типы ошибок.
  factory MappingException.stub() =>
      const MappingException(fieldName: 'NOT_HANDLED', type: MappingExceptionType.unknown);

  @override
  String toString() =>
      'Ошибка маппинга поля "$fieldName", значение, которое пытались смаппить: $actualValue. $type';
}

/// Типы ошибок при маппинге.
enum MappingExceptionType {
  /// Ошибка связанная с маппингом дат.
  dateMapping('date format'),

  /// Ошибка связанная с nullability-ошибками, пришёл null где не ожидается.
  nullability('nullability'),

  /// Неизвестная ошибка.
  unknown('unknown');

  /// Тег для происка в логе.
  final String description;

  /// Конструктор [MappingExceptionType].
  const MappingExceptionType(this.description);

  @override
  String toString() => '[$description]';
}
