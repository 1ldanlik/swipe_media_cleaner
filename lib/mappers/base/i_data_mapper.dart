import 'package:meta/meta.dart';
import 'package:swipe_media_cleaner/domain/exceptions/mappin_exception.dart';
import 'package:swipe_media_cleaner/mappers/base/data_mapper_exception.dart';

/// Маппер данных из типа [I] в [O].
abstract class IDataMapper<I, O> {
  /// Данные, которые нужно преобразовать.
  final I input;

  /// Создаёт объект для преобразования данных.
  IDataMapper(this.input);

  /// Преобразование данных из [I] в [O].
  ///
  /// Использовать лишь в рамках переопределения в наследуемом классе.
  /// Для получения результата использовать [transform].
  @protected
  O map();

  /// Преобразование данных для дальнейшего использования.
  ///
  /// Использовать лишь в случае получения итоговых данных.
  @useResult
  O transform() {
    DataMapperException<I, O>? mapperException;
    StackTrace? stack;

    try {
      return map();
    } on MappingException catch (exception, stackTrace) {
      mapperException = DataMapperException<I, O>(this, exception);
      stack = stackTrace;
    } on Exception catch (_, stackTrace) {
      mapperException = DataMapperException<I, O>(this, MappingException.stub());
      stack = stackTrace;
    }

    Error.throwWithStackTrace(mapperException, stack);
  }
}
