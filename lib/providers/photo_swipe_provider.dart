import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';
import '../models/photo_item.dart';
import 'deleted_photos_provider.dart';
import 'viewed_photos_provider.dart';

/// Состояние для PhotoSwipeScreen
class PhotoSwipeState {
  final List<PhotoItem> remainingPhotos;
  final int currentIndex;
  final bool isLoading;
  final String? error;
  final int totalPhotosInMonth;
  final int alreadyViewedCount;
  final bool currentPhotoIsFavorite;

  const PhotoSwipeState({
    this.remainingPhotos = const [],
    this.currentIndex = 0,
    this.isLoading = true,
    this.error,
    this.totalPhotosInMonth = 0,
    this.alreadyViewedCount = 0,
    this.currentPhotoIsFavorite = false,
  });

  PhotoSwipeState copyWith({
    List<PhotoItem>? remainingPhotos,
    int? currentIndex,
    bool? isLoading,
    String? error,
    int? totalPhotosInMonth,
    int? alreadyViewedCount,
    bool? currentPhotoIsFavorite,
  }) {
    return PhotoSwipeState(
      remainingPhotos: remainingPhotos ?? this.remainingPhotos,
      currentIndex: currentIndex ?? this.currentIndex,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      totalPhotosInMonth: totalPhotosInMonth ?? this.totalPhotosInMonth,
      alreadyViewedCount: alreadyViewedCount ?? this.alreadyViewedCount,
      currentPhotoIsFavorite: currentPhotoIsFavorite ?? this.currentPhotoIsFavorite,
    );
  }
}

/// StateNotifier для управления состоянием просмотра фото
class PhotoSwipeNotifier extends StateNotifier<PhotoSwipeState> {
  final Ref ref;

  PhotoSwipeNotifier(this.ref) : super(const PhotoSwipeState());

  /// Загрузить фото месяца
  Future<void> loadPhotosForMonth(int year, int month) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      currentIndex: 0,
    );

    try {
      final monthPhotos = await _loadPhotosForMonth(year, month);

      if (monthPhotos.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          remainingPhotos: [],
          currentIndex: 0,
          totalPhotosInMonth: 0,
          alreadyViewedCount: 0,
        );
        return;
      }

      final viewedService = ref.read(viewedPhotosServiceProvider);

      // Фильтруем непросмотренные фото
      final unviewedPhotos =
          monthPhotos.where((photo) => !viewedService.isViewed(photo.id)).toList();

      // Подсчитываем уже просмотренные фото
      final alreadyViewed = monthPhotos.length - unviewedPhotos.length;

      // Если есть непросмотренные - показываем только их, иначе показываем все
      final photosToShow = unviewedPhotos.isNotEmpty
          ? List<PhotoItem>.from(unviewedPhotos)
          : List<PhotoItem>.from(monthPhotos);

      // Если показываем все фото (пересмотр), сбрасываем счетчик просмотренных
      final viewedCount = unviewedPhotos.isEmpty ? 0 : alreadyViewed;

      state = state.copyWith(
        isLoading: false,
        remainingPhotos: photosToShow,
        currentIndex: 0,
        totalPhotosInMonth: monthPhotos.length,
        alreadyViewedCount: viewedCount,
        currentPhotoIsFavorite: photosToShow.isNotEmpty ? photosToShow[0].isFavorite : false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Удалить текущее фото
  Future<void> deleteCurrentPhoto() async {
    if (state.currentIndex >= state.remainingPhotos.length) {
      return;
    }

    final photo = state.remainingPhotos[state.currentIndex];

    // Отмечаем фото как просмотренное
    await _markPhotoAsViewed(photo);

    // Сохраняем в кэш удаленных
    final deletedService = ref.read(deletedPhotosServiceProvider);
    await deletedService.markForDeletion(photo);

    // Переходим к следующему фото
    _nextPhoto();
  }

  /// Сохранить текущее фото и перейти к следующему
  Future<void> keepCurrentPhoto() async {
    if (state.currentIndex >= state.remainingPhotos.length) {
      return;
    }

    final photo = state.remainingPhotos[state.currentIndex];

    // Отмечаем фото как просмотренное
    await _markPhotoAsViewed(photo);

    // Переходим к следующему фото
    _nextPhoto();
  }

  /// Переключить статус избранного для текущего фото
  Future<void> toggleFavorite() async {
    if (state.currentIndex >= state.remainingPhotos.length) {
      return;
    }
    final photo = state.remainingPhotos[state.currentIndex];
    final newValue = !photo.asset.isFavorite;

    final success = await PhotoManager.plugin.favoriteAsset(
      photo.asset.id,
      newValue,
    );

    if (!success) return;

    final updatedList = state.remainingPhotos.toList();
    final updatedAsset = await photo.asset.obtainForNewProperties();
    updatedList[state.currentIndex] =
        state.remainingPhotos[state.currentIndex].copyWith(asset: updatedAsset);

    state = state.copyWith(
      currentPhotoIsFavorite: newValue,
      remainingPhotos: updatedList,
    );
  }

  void _nextPhoto() {
    final newIndex = state.currentIndex + 1;
    final newFavoriteStatus = newIndex < state.remainingPhotos.length
        ? state.remainingPhotos[newIndex].isFavorite
        : false;
    state = state.copyWith(
      currentIndex: newIndex,
      currentPhotoIsFavorite: newFavoriteStatus,
    );
  }

  /// Отметить фото как просмотренное
  Future<void> _markPhotoAsViewed(PhotoItem photo) async {
    final viewedService = ref.read(viewedPhotosServiceProvider);

    // Проверяем, была ли фото уже просмотрена
    final wasAlreadyViewed = viewedService.isViewed(photo.id);

    // Отмечаем фото как просмотренное
    await viewedService.markAsViewed(
      photo.id,
      photo.createdDate.year,
      photo.createdDate.month,
    );

    // Увеличиваем счетчик просмотренных только если фото не была просмотрена ранее
    if (!wasAlreadyViewed) {
      final service = ref.read(deletedPhotosServiceProvider);
      service.incrementCheckedPhotos();
    }
  }

  /// Загрузить фото за конкретный месяц и год
  Future<List<PhotoItem>> _loadPhotosForMonth(int year, int month) async {
    final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      onlyAll: true,
    );

    if (albums.isEmpty) {
      return [];
    }

    final AssetPathEntity recentAlbum = albums.first;
    final int totalCount = await recentAlbum.assetCountAsync;

    if (totalCount == 0) {
      return [];
    }

    final List<AssetEntity> assets = await recentAlbum.getAssetListRange(
      start: 0,
      end: totalCount,
    );

    final List<PhotoItem> result = [];

    for (final asset in assets) {
      final date = asset.createDateTime;
      if (date.year != year || date.month != month) {
        continue;
      }

      try {
        final file = await asset.originFile;
        if (file == null) {
          continue;
        }

        final photoItem = await PhotoItem.fromAsset(asset, file.path);
        if (photoItem != null) {
          result.add(photoItem);
        }
      } catch (_) {
        continue;
      }
    }

    return result;
  }
}

/// Провайдер для состояния просмотра фото (семейный по году и месяцу)
final photoSwipeProvider = StateNotifierProvider.autoDispose
    .family<PhotoSwipeNotifier, PhotoSwipeState, (int year, int month)>(
  (ref, params) {
    return PhotoSwipeNotifier(ref);
  },
);
