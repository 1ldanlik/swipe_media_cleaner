// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_screen_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Notifier для управления состоянием главного экрана

@ProviderFor(HomeScreenNotifier)
final homeScreenProvider = HomeScreenNotifierProvider._();

/// Notifier для управления состоянием главного экрана
final class HomeScreenNotifierProvider
    extends $NotifierProvider<HomeScreenNotifier, HomeScreenState> {
  /// Notifier для управления состоянием главного экрана
  HomeScreenNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeScreenProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeScreenNotifierHash();

  @$internal
  @override
  HomeScreenNotifier create() => HomeScreenNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HomeScreenState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HomeScreenState>(value),
    );
  }
}

String _$homeScreenNotifierHash() => r'754100c14e74cf4cfe9178374a3f25047d7bb7d8';

/// Notifier для управления состоянием главного экрана

abstract class _$HomeScreenNotifier extends $Notifier<HomeScreenState> {
  HomeScreenState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<HomeScreenState, HomeScreenState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<HomeScreenState, HomeScreenState>,
              HomeScreenState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
