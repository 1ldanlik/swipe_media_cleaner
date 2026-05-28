import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:share_plus/share_plus.dart';
import '../models/photo_item.dart';
import 'deleted_photos_provider.dart';
import 'viewed_photos_provider.dart';

/// Состояние для PhotoSwipeScreen
class PhotoSwipeState {
  final List<PhotoItem> bufferedPhotos;
  final bool isLoading;
  final String? error;
  final int totalPhotosInMonth;
  final int alreadyViewedCount;
  final bool currentPhotoIsFavorite;
  final bool isFullPictureShow;
  final bool isFinished;
  final bool canUndoLastAction;

  const PhotoSwipeState({
    this.bufferedPhotos = const [],
    this.isLoading = true,
    this.error,
    this.totalPhotosInMonth = 0,
    this.alreadyViewedCount = 0,
    this.currentPhotoIsFavorite = false,
    this.isFullPictureShow = false,
    this.isFinished = false,
    this.canUndoLastAction = false,
  });

  PhotoSwipeState copyWith({
    List<PhotoItem>? bufferedPhotos,
    bool? isLoading,
    String? error,
    int? totalPhotosInMonth,
    int? alreadyViewedCount,
    bool? currentPhotoIsFavorite,
    bool? isFullPictureShow,
    bool? isFinished,
    bool? canUndoLastAction,
  }) {
    return PhotoSwipeState(
      bufferedPhotos: bufferedPhotos ?? this.bufferedPhotos,
      isLoading: isLoading ?? this.isLoading,
      // Специально так оставил, чтобы не хранить предыдущие ошибки.
      error: error,
      totalPhotosInMonth: totalPhotosInMonth ?? this.totalPhotosInMonth,
      alreadyViewedCount: alreadyViewedCount ?? this.alreadyViewedCount,
      currentPhotoIsFavorite: currentPhotoIsFavorite ?? this.currentPhotoIsFavorite,
      isFullPictureShow: isFullPictureShow ?? this.isFullPictureShow,
      isFinished: isFinished ?? this.isFinished,
      canUndoLastAction: canUndoLastAction ?? this.canUndoLastAction,
    );
  }
}

/// StateNotifier для управления состоянием просмотра фото
class PhotoSwipeNotifier extends StateNotifier<PhotoSwipeState> {
  final Ref ref;

  final int currentYear;
  final int currentMonth;

  PhotoSwipeNotifier(
    this.ref, {
    required this.currentYear,
    required this.currentMonth,
  }) : super(const PhotoSwipeState());

  /// Готовые PhotoItem, которые сейчас можно показывать в UI.
  ///
  /// [0] — текущая карточка.
  /// [1] — следующая карточка под ней.
  /// [2] — запасная карточка.
  final List<PhotoItem> _photoBuffer = [];

  /// Найденные AssetEntity нужного месяца,
  /// которые ещё не превращены в PhotoItem.
  final List<AssetEntity> _matchedAssetQueue = [];

  /// С какого места продолжаем сканировать галерею.
  int _photoScanOffset = 0;

  /// Защита от параллельной загрузки.
  bool _isLoadingPhotos = false;

  /// Есть ли ещё непросканированные фото в галерее.
  bool _hasMorePhotos = true;

  /// false — показываем только непросмотренные.
  /// true — показываем все фото, если непросмотренных уже нет.
  bool _showViewedPhotos = false;

  /// Сколько фото держим готовыми для свайпа.
  static const int _targetBufferSize = 3;

  /// Сколько AssetEntity проверяем за один батч.
  static const int _scanBatchSize = 80;

  List<PhotoItem> _listToUndoPhotos = [];

  /// Загрузить стартовый буфер фото месяца.
  ///
  /// Важно:
  /// метод НЕ загружает все фото месяца сразу.
  /// Он только подготавливает первые 2–3 фото для свайпа.
  Future<void> loadPhotosForMonth({
    int? viewedCount,
    int? totalMonthCount,
  }) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      bufferedPhotos: [],
      totalPhotosInMonth: totalMonthCount,
      alreadyViewedCount: viewedCount ?? 0,
      currentPhotoIsFavorite: false,
      isFinished: false,
    );

    try {
      // Очищаем готовые карточки для свайпа.
      _photoBuffer.clear();

      // Очищаем очередь уже найденных AssetEntity.
      _matchedAssetQueue.clear();

      // Начинаем сканирование галереи с самого начала.
      _photoScanOffset = 0;

      // Снова разрешаем поиск по галерее.
      _hasMorePhotos = true;

      // По умолчанию показываем только непросмотренные фото.
      _showViewedPhotos = false;

      // Заполняем стартовый буфер.
      await _fillPhotoBufferForMonth(currentYear, currentMonth);

      // Если непросмотренных фото не нашли вообще,
      // тогда включаем режим пересмотра и показываем уже просмотренные.
      //
      // Это аналог старой логики:
      // если unviewedPhotos.isEmpty — показываем все monthPhotos.
      if (_photoBuffer.isEmpty && !_hasMorePhotos) {
        _showViewedPhotos = true;

        _matchedAssetQueue.clear();
        _photoScanOffset = 0;
        _hasMorePhotos = true;

        await _fillPhotoBufferForMonth(currentYear, currentMonth);
      }

      final isFinished = _photoBuffer.isEmpty && _matchedAssetQueue.isEmpty && !_hasMorePhotos;

      state = state.copyWith(
        isLoading: false,
        bufferedPhotos: List<PhotoItem>.from(_photoBuffer),
        totalPhotosInMonth: totalMonthCount,
        alreadyViewedCount: _showViewedPhotos ? 0 : viewedCount,
        currentPhotoIsFavorite: _photoBuffer.isNotEmpty ? _photoBuffer.first.isFavorite : false,
        isFinished: isFinished,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Актуализация списка фоток, для которых можно отменить действие.
  ///
  /// Метод используется для актуализации списка после перехода из другого таба.
  /// Т.к. мы могли удалить фотки на экране корзины и перейти обратно на экран свайпа.
  Future<void> removeDeletedPhotos() async {
    final existingPhotos = <PhotoItem>[];

    for (final element in _listToUndoPhotos) {
      final exists = await element.asset.exists;

      if (exists) {
        existingPhotos.add(element);
      }
    }

    final deletePhotosQty = _listToUndoPhotos.length - existingPhotos.length;
    _listToUndoPhotos = existingPhotos;

    state = state.copyWith(
      alreadyViewedCount: state.alreadyViewedCount - deletePhotosQty,
      totalPhotosInMonth: state.totalPhotosInMonth - deletePhotosQty,
      canUndoLastAction: _listToUndoPhotos.isNotEmpty,
      currentPhotoIsFavorite: _photoBuffer.isNotEmpty ? _photoBuffer.first.isFavorite : false,
    );
  }

  /// Удалить текущее фото
  Future<void> deleteCurrentPhoto() async {
    if (_photoBuffer.isEmpty) {
      return;
    }

    final photo = _photoBuffer.first;

    // Отмечаем фото как просмотренное
    await _markPhotoAsViewed(photo);

    // Сохраняем в кэш удалённых
    final deletedService = ref.read(deletedPhotosServiceProvider);
    await deletedService.markForDeletion(photo);

    // Удаляем текущую карточку из буфера и догружаем следующую
    await _moveToNextPhoto();
  }

  /// Сохранить текущее фото и перейти к следующему
  Future<void> keepCurrentPhoto() async {
    if (_photoBuffer.isEmpty) {
      return;
    }

    final photo = _photoBuffer.first;

    // Отмечаем фото как просмотренное
    await _markPhotoAsViewed(photo);

    // Удаляем текущую карточку из буфера и догружаем следующую
    await _moveToNextPhoto();
  }

  /// Отменить последнее действие.
  Future<void> undoLastAction() async {
    if (_listToUndoPhotos.isEmpty) return;

    final lastPhoto = _listToUndoPhotos.last;
    final deletedService = ref.read(deletedPhotosServiceProvider);
    final isMarkedForDeletion = deletedService.isMarkedForDeletion(lastPhoto.id);

    // Была ли картинка добавлена в корзину.
    if (isMarkedForDeletion) {
      // Убираем фотку из корзины.
      await deletedService.restore(lastPhoto.id);
    }

    // Убираем картинку из просмотренных.
    final viewedService = ref.read(viewedPhotosServiceProvider);
    await viewedService.cleanupPhotos([lastPhoto.id]);

    // логика локального обновления, без исползования лишних сложных методов.
    final photo = _listToUndoPhotos.removeLast();
    _photoBuffer.insert(0, photo);
    if (_photoBuffer.length > _targetBufferSize) {
      _matchedAssetQueue.insert(0, _photoBuffer.last.asset);
    }

    // обновление состояния с уменьшением счетчика просмотренных, т.к. отменяем последнее действие.
    state = state.copyWith(
      bufferedPhotos: _photoBuffer,
      alreadyViewedCount: state.alreadyViewedCount - 1,
      canUndoLastAction: _listToUndoPhotos.isNotEmpty,
      currentPhotoIsFavorite: _photoBuffer.isNotEmpty ? _photoBuffer.first.isFavorite : false,
    );
  }

  /// Переключить статус избранного для текущего фото
  Future<void> toggleFavorite() async {
    if (_photoBuffer.isEmpty) {
      return;
    }

    final photo = _photoBuffer.first;
    final newValue = !photo.asset.isFavorite;

    final success = await PhotoManager.plugin.favoriteAsset(
      photo.asset.id,
      newValue,
    );

    if (!success) {
      return;
    }

    final updatedAsset = await photo.asset.obtainForNewProperties();

    final updatedPhoto = photo.copyWith(
      asset: updatedAsset,
    );

    // Обновляем внутренний буфер,
    // чтобы при следующем обновлении state избранное не откатилось.
    _photoBuffer[0] = updatedPhoto;

    state = state.copyWith(
      currentPhotoIsFavorite: newValue,
      bufferedPhotos: List<PhotoItem>.from(_photoBuffer),
    );
  }

  /// Переключить статус отображения картинок.
  Future<void> toggleFullPicture() async {
    final newValue = !state.isFullPictureShow;

    state = state.copyWith(isFullPictureShow: newValue);
  }

  Future<void> shareAssetPhoto() async {
    final file = await _photoBuffer.first.asset.originFile;

    if (file == null) {
      return;
    }

    await Share.shareXFiles(
      [XFile(file.path)],
    );
  }

  Future<void> _moveToNextPhoto() async {
    if (_photoBuffer.isNotEmpty) {
      _listToUndoPhotos.add(_photoBuffer[0]);
      _photoBuffer.removeAt(0);
    }

    await _fillPhotoBufferForMonth(currentYear, currentMonth);

    final isFinished = _photoBuffer.isEmpty && _matchedAssetQueue.isEmpty && !_hasMorePhotos;

    state = state.copyWith(
      bufferedPhotos: List<PhotoItem>.from(_photoBuffer),
      currentPhotoIsFavorite: _photoBuffer.isNotEmpty ? _photoBuffer.first.isFavorite : false,
      isFinished: isFinished,
      canUndoLastAction: _listToUndoPhotos.isNotEmpty,
    );
  }

  /// Отметить фото как просмотренное
  Future<void> _markPhotoAsViewed(PhotoItem photo) async {
    final viewedService = ref.read(viewedPhotosServiceProvider);

    // Проверяем, было ли фото уже просмотрено раньше.
    final wasAlreadyViewed = viewedService.isViewed(photo.id);

    // Отмечаем фото как просмотренное.
    await viewedService.markAsViewed(
      photo.id,
      photo.createdDate.year,
      photo.createdDate.month,
    );

    // Если фото раньше не было просмотрено,
    // увеличиваем общий счётчик проверенных фото.
    if (!wasAlreadyViewed) {
      final service = ref.read(deletedPhotosServiceProvider);
      service.incrementCheckedPhotos();
    }

    // Обновляем локальный счётчик просмотренных фото месяца.
    state = state.copyWith(alreadyViewedCount: state.alreadyViewedCount + 1);
  }

  /// Добрать фото нужного месяца в буфер.
  ///
  /// Метод:
  /// - не грузит весь месяц сразу;
  /// - получает из PhotoManager только фото нужного месяца;
  /// - сканирует фото батчами;
  /// - не теряет подходящие фото из батча;
  /// - пропускает уже просмотренные фото, если мы не в режиме пересмотра.
  Future<void> _fillPhotoBufferForMonth(int year, int month) async {
    if (_isLoadingPhotos) {
      return;
    }

    if (_photoBuffer.length >= _targetBufferSize) {
      return;
    }

    _isLoadingPhotos = true;

    try {
      final viewedService = ref.read(viewedPhotosServiceProvider);

      // Начало нужного месяца.
      final startDate = DateTime(year, month);

      // Начало следующего месяца.
      final nextMonthDate = month == 12 ? DateTime(year + 1, 1) : DateTime(year, month + 1);

      // Конец нужного месяца.
      // Делаем так, чтобы не захватить первое число следующего месяца.
      final endDate = nextMonthDate.subtract(
        const Duration(milliseconds: 1),
      );

      // Получаем общий альбом, но сразу с фильтром по дате создания.
      // В результате recentAlbum будет содержать только фото нужного месяца.
      final albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        onlyAll: true,
        filterOption: FilterOptionGroup(
          createTimeCond: DateTimeCond(
            min: startDate,
            max: endDate,
          ),
        ),
      );

      if (albums.isEmpty) {
        _hasMorePhotos = false;
        return;
      }

      final recentAlbum = albums.first;
      final totalCount = await recentAlbum.assetCountAsync;

      if (totalCount == 0) {
        _hasMorePhotos = false;
        return;
      }

      while (_photoBuffer.length < _targetBufferSize) {
        // Сначала используем уже найденные AssetEntity из очереди.
        if (_matchedAssetQueue.isNotEmpty) {
          final asset = _matchedAssetQueue.removeAt(0);

          final photoItem = await _assetToPhotoItem(asset);

          if (photoItem != null) {
            _photoBuffer.add(photoItem);
          }

          continue;
        }

        // Если очередь пустая и все фото месяца уже просмотрены/просканированы —
        // новых фото больше нет.
        if (!_hasMorePhotos || _photoScanOffset >= totalCount) {
          _hasMorePhotos = false;
          break;
        }

        final end = (_photoScanOffset + _scanBatchSize > totalCount)
            ? totalCount
            : _photoScanOffset + _scanBatchSize;

        // Берём небольшой батч уже отфильтрованных фото месяца.
        final assets = await recentAlbum.getAssetListRange(
          start: _photoScanOffset,
          end: end,
        );

        // Сдвигаем offset, чтобы следующий батч начался дальше.
        _photoScanOffset = end;

        for (final asset in assets) {
          final isViewed = viewedService.isViewed(asset.id);

          // Если фото уже просмотрено и мы НЕ в режиме пересмотра —
          // не добавляем его в очередь показа.
          if (isViewed && !_showViewedPhotos) {
            continue;
          }

          // Фото уже точно из нужного месяца,
          // поэтому просто кладём его в очередь.
          _matchedAssetQueue.add(asset);
        }

        if (_photoScanOffset >= totalCount) {
          _hasMorePhotos = false;
        }
      }
    } finally {
      _isLoadingPhotos = false;
    }
  }

  /// Превращает AssetEntity в PhotoItem только тогда,
  /// когда фото реально нужно показать в свайпе.
  Future<PhotoItem?> _assetToPhotoItem(AssetEntity asset) async {
    try {
      final file = await asset.originFile;

      if (file == null) {
        return null;
      }

      return await PhotoItem.fromAsset(asset, file.path);
    } catch (_) {
      return null;
    }
  }
}

/// Провайдер для состояния просмотра фото (семейный по году и месяцу)
final photoSwipeProvider = StateNotifierProvider.autoDispose
    .family<PhotoSwipeNotifier, PhotoSwipeState, (int year, int month)>(
  (ref, params) {
    return PhotoSwipeNotifier(
      ref,
      currentYear: params.$1,
      currentMonth: params.$2,
    );
  },
);
