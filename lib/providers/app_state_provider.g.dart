// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_state_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AppState)
final appStateProvider = AppStateProvider._();

final class AppStateProvider extends $NotifierProvider<AppState, AppStateData> {
  AppStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appStateHash();

  @$internal
  @override
  AppState create() => AppState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppStateData value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppStateData>(value),
    );
  }
}

String _$appStateHash() => r'd5ccf21be41affee004b4a83ea2bd9d6a9ec7f19';

abstract class _$AppState extends $Notifier<AppStateData> {
  AppStateData build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AppStateData, AppStateData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AppStateData, AppStateData>,
              AppStateData,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
