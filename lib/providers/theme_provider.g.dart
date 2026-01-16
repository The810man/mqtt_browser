// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ThemeService)
final themeServiceProvider = ThemeServiceProvider._();

final class ThemeServiceProvider
    extends $AsyncNotifierProvider<ThemeService, ThemeSettings> {
  ThemeServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeServiceHash();

  @$internal
  @override
  ThemeService create() => ThemeService();
}

String _$themeServiceHash() => r'c074a66cea648fb67d045c358e50b3945d19865d';

abstract class _$ThemeService extends $AsyncNotifier<ThemeSettings> {
  FutureOr<ThemeSettings> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<ThemeSettings>, ThemeSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ThemeSettings>, ThemeSettings>,
              AsyncValue<ThemeSettings>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(theme)
final themeProvider = ThemeProvider._();

final class ThemeProvider
    extends $FunctionalProvider<ThemeData, ThemeData, ThemeData>
    with $Provider<ThemeData> {
  ThemeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeHash();

  @$internal
  @override
  $ProviderElement<ThemeData> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ThemeData create(Ref ref) {
    return theme(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThemeData value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThemeData>(value),
    );
  }
}

String _$themeHash() => r'64bb54f18a76d6d2127862f21e5e5d2f2535d705';
