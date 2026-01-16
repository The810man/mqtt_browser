// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tree_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(treeService)
final treeServiceProvider = TreeServiceProvider._();

final class TreeServiceProvider
    extends $FunctionalProvider<TreeService, TreeService, TreeService>
    with $Provider<TreeService> {
  TreeServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'treeServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$treeServiceHash();

  @$internal
  @override
  $ProviderElement<TreeService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TreeService create(Ref ref) {
    return treeService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TreeService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TreeService>(value),
    );
  }
}

String _$treeServiceHash() => r'b44c6b0943e08c45dfa858ce2ea693a1b9c072ad';
