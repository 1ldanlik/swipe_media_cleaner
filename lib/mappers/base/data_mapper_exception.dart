import 'package:swipe_media_cleaner/domain/exceptions/mappin_exception.dart';
import 'package:swipe_media_cleaner/mappers/base/i_data_mapper.dart';

/// Ошибка преобразования данных.
class DataMapperException<I, O> implements Exception {
  /// Маппер, в котором произошла ошибка.
  final IDataMapper<I, O> dataMapper;

  /// Ошибка маппинга с информацией о ней.
  final MappingException reason;

  /// Создаёт ошибку преобразования данных.
  const DataMapperException(this.dataMapper, this.reason);

  @override
  String toString() => 'Ошибка преобразования $I в $O в ${dataMapper.runtimeType}.\n$reason';
}
