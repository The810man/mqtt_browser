// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'smooth_blink_widget.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BlinkTime)
final blinkTimeProvider = BlinkTimeProvider._();

final class BlinkTimeProvider
    extends $NotifierProvider<BlinkTime, Map<TreeNode?, DateTime?>> {
  BlinkTimeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'blinkTimeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$blinkTimeHash();

  @$internal
  @override
  BlinkTime create() => BlinkTime();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<TreeNode?, DateTime?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<TreeNode?, DateTime?>>(value),
    );
  }
}

String _$blinkTimeHash() => r'9960d37cad75824b68dc5fc161473c2b8dce9da8';

abstract class _$BlinkTime extends $Notifier<Map<TreeNode?, DateTime?>> {
  Map<TreeNode?, DateTime?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<Map<TreeNode?, DateTime?>, Map<TreeNode?, DateTime?>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Map<TreeNode?, DateTime?>, Map<TreeNode?, DateTime?>>,
              Map<TreeNode?, DateTime?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
