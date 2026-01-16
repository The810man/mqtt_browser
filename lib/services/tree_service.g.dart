// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tree_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TreeService)
final treeServiceProvider = TreeServiceProvider._();

final class TreeServiceProvider
    extends $NotifierProvider<TreeService, Map<String, List<TreeNode>>> {
  TreeServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'treeServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$treeServiceHash();

  @$internal
  @override
  TreeService create() => TreeService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, List<TreeNode>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, List<TreeNode>>>(value),
    );
  }
}

String _$treeServiceHash() => r'8d19b2c0753424f617d155f09f0cdf56e5d7e2e8';

abstract class _$TreeService extends $Notifier<Map<String, List<TreeNode>>> {
  Map<String, List<TreeNode>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<Map<String, List<TreeNode>>, Map<String, List<TreeNode>>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                Map<String, List<TreeNode>>,
                Map<String, List<TreeNode>>
              >,
              Map<String, List<TreeNode>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
