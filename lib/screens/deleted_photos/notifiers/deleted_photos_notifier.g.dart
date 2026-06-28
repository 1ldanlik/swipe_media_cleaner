// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deleted_photos_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller для управления состоянием экрана корзины.
///
/// Важно:
/// класс не должен называться DeletedPhotosNotifier,
/// потому что Riverpod сгенерирует deletedPhotosProvider,
/// и он будет конфликтовать с provider'ом списка удалённых фото.

@ProviderFor(DeletedPhotosScreenController)
final deletedPhotosScreenControllerProvider = DeletedPhotosScreenControllerProvider._();

/// Controller для управления состоянием экрана корзины.
///
/// Важно:
/// класс не должен называться DeletedPhotosNotifier,
/// потому что Riverpod сгенерирует deletedPhotosProvider,
/// и он будет конфликтовать с provider'ом списка удалённых фото.
final class DeletedPhotosScreenControllerProvider
    extends $NotifierProvider<DeletedPhotosScreenController, DeletedPhotosScreenState> {
  /// Controller для управления состоянием экрана корзины.
  ///
  /// Важно:
  /// класс не должен называться DeletedPhotosNotifier,
  /// потому что Riverpod сгенерирует deletedPhotosProvider,
  /// и он будет конфликтовать с provider'ом списка удалённых фото.
  DeletedPhotosScreenControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deletedPhotosScreenControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deletedPhotosScreenControllerHash();

  @$internal
  @override
  DeletedPhotosScreenController create() => DeletedPhotosScreenController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeletedPhotosScreenState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeletedPhotosScreenState>(value),
    );
  }
}

String _$deletedPhotosScreenControllerHash() => r'7999ceb88b3350e424139107c40bfed35766103c';

/// Controller для управления состоянием экрана корзины.
///
/// Важно:
/// класс не должен называться DeletedPhotosNotifier,
/// потому что Riverpod сгенерирует deletedPhotosProvider,
/// и он будет конфликтовать с provider'ом списка удалённых фото.

abstract class _$DeletedPhotosScreenController extends $Notifier<DeletedPhotosScreenState> {
  DeletedPhotosScreenState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<DeletedPhotosScreenState, DeletedPhotosScreenState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DeletedPhotosScreenState, DeletedPhotosScreenState>,
              DeletedPhotosScreenState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
