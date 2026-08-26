// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ui_state_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Host)
final hostProvider = HostProvider._();

final class HostProvider extends $NotifierProvider<Host, String> {
  HostProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hostProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hostHash();

  @$internal
  @override
  Host create() => Host();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$hostHash() => r'c3c117adf72e73668229d6d32d4d9e7402cc925b';

abstract class _$Host extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(Port)
final portProvider = PortProvider._();

final class PortProvider extends $NotifierProvider<Port, String> {
  PortProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'portProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$portHash();

  @$internal
  @override
  Port create() => Port();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$portHash() => r'4820f722ac1b86ba00d326d4e54c17e25c7c8066';

abstract class _$Port extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(UseWebSocket)
final useWebSocketProvider = UseWebSocketProvider._();

final class UseWebSocketProvider extends $NotifierProvider<UseWebSocket, bool> {
  UseWebSocketProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'useWebSocketProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$useWebSocketHash();

  @$internal
  @override
  UseWebSocket create() => UseWebSocket();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$useWebSocketHash() => r'166dd29afdd5fc82ee6809277d6fb5f5d4ab4d8b';

abstract class _$UseWebSocket extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(mqttSettings)
final mqttSettingsProvider = MqttSettingsProvider._();

final class MqttSettingsProvider
    extends $FunctionalProvider<MqttSettings, MqttSettings, MqttSettings>
    with $Provider<MqttSettings> {
  MqttSettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mqttSettingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mqttSettingsHash();

  @$internal
  @override
  $ProviderElement<MqttSettings> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MqttSettings create(Ref ref) {
    return mqttSettings(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MqttSettings value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MqttSettings>(value),
    );
  }
}

String _$mqttSettingsHash() => r'93a838ed82cf65d576d7248dbac0f16ed9d0f906';

@ProviderFor(TabList)
final tabListProvider = TabListProvider._();

final class TabListProvider extends $NotifierProvider<TabList, List<TreeNode>> {
  TabListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tabListProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tabListHash();

  @$internal
  @override
  TabList create() => TabList();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<TreeNode> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<TreeNode>>(value),
    );
  }
}

String _$tabListHash() => r'337ced35313e60d996605713c999c1086f83f715';

abstract class _$TabList extends $Notifier<List<TreeNode>> {
  List<TreeNode> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<TreeNode>, List<TreeNode>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<TreeNode>, List<TreeNode>>,
              List<TreeNode>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(TabLength)
final tabLengthProvider = TabLengthProvider._();

final class TabLengthProvider extends $NotifierProvider<TabLength, int> {
  TabLengthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tabLengthProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tabLengthHash();

  @$internal
  @override
  TabLength create() => TabLength();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$tabLengthHash() => r'486d14699da738ea1fa9a16c2609761a2439f1aa';

abstract class _$TabLength extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(TabIndex)
final tabIndexProvider = TabIndexProvider._();

final class TabIndexProvider extends $NotifierProvider<TabIndex, int> {
  TabIndexProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tabIndexProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tabIndexHash();

  @$internal
  @override
  TabIndex create() => TabIndex();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$tabIndexHash() => r'67646db64320b23ac35c4290a889b25cd750866f';

abstract class _$TabIndex extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(Root)
final rootProvider = RootProvider._();

final class RootProvider extends $NotifierProvider<Root, TreeNode> {
  RootProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rootProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rootHash();

  @$internal
  @override
  Root create() => Root();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TreeNode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TreeNode>(value),
    );
  }
}

String _$rootHash() => r'f830fb7aabf546534daa3c16b31089a0a76f897f';

abstract class _$Root extends $Notifier<TreeNode> {
  TreeNode build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<TreeNode, TreeNode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TreeNode, TreeNode>,
              TreeNode,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(CurrentRoot)
final currentRootProvider = CurrentRootProvider._();

final class CurrentRootProvider
    extends $NotifierProvider<CurrentRoot, TreeNode> {
  CurrentRootProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentRootProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentRootHash();

  @$internal
  @override
  CurrentRoot create() => CurrentRoot();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TreeNode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TreeNode>(value),
    );
  }
}

String _$currentRootHash() => r'629267df9f07dbeb65feb2f24952a79976c19741';

abstract class _$CurrentRoot extends $Notifier<TreeNode> {
  TreeNode build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<TreeNode, TreeNode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TreeNode, TreeNode>,
              TreeNode,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(TabData)
final tabDataProvider = TabDataProvider._();

final class TabDataProvider
    extends $NotifierProvider<TabData, Map<String, Map<String, dynamic>>> {
  TabDataProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tabDataProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tabDataHash();

  @$internal
  @override
  TabData create() => TabData();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, Map<String, dynamic>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, Map<String, dynamic>>>(
        value,
      ),
    );
  }
}

String _$tabDataHash() => r'cffbe80603302b1edb2168a9be24c6933c471066';

abstract class _$TabData extends $Notifier<Map<String, Map<String, dynamic>>> {
  Map<String, Map<String, dynamic>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              Map<String, Map<String, dynamic>>,
              Map<String, Map<String, dynamic>>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                Map<String, Map<String, dynamic>>,
                Map<String, Map<String, dynamic>>
              >,
              Map<String, Map<String, dynamic>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(TreeNodes)
final treeNodesProvider = TreeNodesProvider._();

final class TreeNodesProvider
    extends $NotifierProvider<TreeNodes, Map<String, List<TreeNode>>> {
  TreeNodesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'treeNodesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$treeNodesHash();

  @$internal
  @override
  TreeNodes create() => TreeNodes();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, List<TreeNode>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, List<TreeNode>>>(value),
    );
  }
}

String _$treeNodesHash() => r'b31551cf6c31760a7255fc0dcd383119aa38d68c';

abstract class _$TreeNodes extends $Notifier<Map<String, List<TreeNode>>> {
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

@ProviderFor(SelectedItem)
final selectedItemProvider = SelectedItemProvider._();

final class SelectedItemProvider
    extends $NotifierProvider<SelectedItem, Map<String, TreeNode>> {
  SelectedItemProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedItemProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedItemHash();

  @$internal
  @override
  SelectedItem create() => SelectedItem();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, TreeNode> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, TreeNode>>(value),
    );
  }
}

String _$selectedItemHash() => r'd064f803e84c3e89cedca8fc868909e528d83264';

abstract class _$SelectedItem extends $Notifier<Map<String, TreeNode>> {
  Map<String, TreeNode> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Map<String, TreeNode>, Map<String, TreeNode>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Map<String, TreeNode>, Map<String, TreeNode>>,
              Map<String, TreeNode>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(ChangeIshappening)
final changeIshappeningProvider = ChangeIshappeningProvider._();

final class ChangeIshappeningProvider
    extends $NotifierProvider<ChangeIshappening, bool> {
  ChangeIshappeningProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'changeIshappeningProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$changeIshappeningHash();

  @$internal
  @override
  ChangeIshappening create() => ChangeIshappening();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$changeIshappeningHash() => r'23942f84c76a1f2f9f5fd57f05290934542b80d8';

abstract class _$ChangeIshappening extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(CurrentMessage)
final currentMessageProvider = CurrentMessageProvider._();

final class CurrentMessageProvider
    extends $NotifierProvider<CurrentMessage, Map<TreeNode, String>> {
  CurrentMessageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentMessageProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentMessageHash();

  @$internal
  @override
  CurrentMessage create() => CurrentMessage();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<TreeNode, String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<TreeNode, String>>(value),
    );
  }
}

String _$currentMessageHash() => r'7c3587cb8bbdf19c9152d1aa661bb2ff15ff5722';

abstract class _$CurrentMessage extends $Notifier<Map<TreeNode, String>> {
  Map<TreeNode, String> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Map<TreeNode, String>, Map<TreeNode, String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Map<TreeNode, String>, Map<TreeNode, String>>,
              Map<TreeNode, String>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(PublishTextController)
final publishTextControllerProvider = PublishTextControllerProvider._();

final class PublishTextControllerProvider
    extends $NotifierProvider<PublishTextController, TextEditingController> {
  PublishTextControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'publishTextControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$publishTextControllerHash();

  @$internal
  @override
  PublishTextController create() => PublishTextController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TextEditingController value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TextEditingController>(value),
    );
  }
}

String _$publishTextControllerHash() =>
    r'45c1aa1f6b7ce33ebf8032ea49d66f10924199b8';

abstract class _$PublishTextController
    extends $Notifier<TextEditingController> {
  TextEditingController build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<TextEditingController, TextEditingController>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TextEditingController, TextEditingController>,
              TextEditingController,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(PublishFormat)
final publishFormatProvider = PublishFormatProvider._();

final class PublishFormatProvider
    extends $NotifierProvider<PublishFormat, String> {
  PublishFormatProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'publishFormatProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$publishFormatHash();

  @$internal
  @override
  PublishFormat create() => PublishFormat();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$publishFormatHash() => r'44651003c715e513fa7d2f2675ff5b1bd9bcf2df';

abstract class _$PublishFormat extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(PublishQos)
final publishQosProvider = PublishQosProvider._();

final class PublishQosProvider extends $NotifierProvider<PublishQos, MqttQos> {
  PublishQosProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'publishQosProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$publishQosHash();

  @$internal
  @override
  PublishQos create() => PublishQos();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MqttQos value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MqttQos>(value),
    );
  }
}

String _$publishQosHash() => r'aabc3c6e31b6983fddb1dd0ff07fdc8a04d11c8e';

abstract class _$PublishQos extends $Notifier<MqttQos> {
  MqttQos build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<MqttQos, MqttQos>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MqttQos, MqttQos>,
              MqttQos,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(PublishRetain)
final publishRetainProvider = PublishRetainProvider._();

final class PublishRetainProvider
    extends $NotifierProvider<PublishRetain, bool> {
  PublishRetainProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'publishRetainProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$publishRetainHash();

  @$internal
  @override
  PublishRetain create() => PublishRetain();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$publishRetainHash() => r'5c808c4a2060e17f6c77f0c840e3803f3e30b8b8';

abstract class _$PublishRetain extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(SpaceSlider)
final spaceSliderProvider = SpaceSliderProvider._();

final class SpaceSliderProvider extends $NotifierProvider<SpaceSlider, double> {
  SpaceSliderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'spaceSliderProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$spaceSliderHash();

  @$internal
  @override
  SpaceSlider create() => SpaceSlider();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$spaceSliderHash() => r'08b90039bf69dad5133b2a32125eb99bf6d5bbc1';

abstract class _$SpaceSlider extends $Notifier<double> {
  double build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<double, double>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<double, double>,
              double,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(ThicknessSlider)
final thicknessSliderProvider = ThicknessSliderProvider._();

final class ThicknessSliderProvider
    extends $NotifierProvider<ThicknessSlider, double> {
  ThicknessSliderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'thicknessSliderProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$thicknessSliderHash();

  @$internal
  @override
  ThicknessSlider create() => ThicknessSlider();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$thicknessSliderHash() => r'd14dc09e0fbc9c73b9cb0f328a12a2866fdd864c';

abstract class _$ThicknessSlider extends $Notifier<double> {
  double build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<double, double>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<double, double>,
              double,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(OriginSlider)
final originSliderProvider = OriginSliderProvider._();

final class OriginSliderProvider
    extends $NotifierProvider<OriginSlider, double> {
  OriginSliderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'originSliderProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$originSliderHash();

  @$internal
  @override
  OriginSlider create() => OriginSlider();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$originSliderHash() => r'8cffa9d7a7bc703bed4e91aa2261ff4fbcbcb3e2';

abstract class _$OriginSlider extends $Notifier<double> {
  double build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<double, double>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<double, double>,
              double,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(NodeHeight)
final nodeHeightProvider = NodeHeightProvider._();

final class NodeHeightProvider extends $NotifierProvider<NodeHeight, double> {
  NodeHeightProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nodeHeightProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nodeHeightHash();

  @$internal
  @override
  NodeHeight create() => NodeHeight();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$nodeHeightHash() => r'da8c93430ee47149e42cb6acad253c443221585b';

abstract class _$NodeHeight extends $Notifier<double> {
  double build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<double, double>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<double, double>,
              double,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(RoundedLineSwitch)
final roundedLineSwitchProvider = RoundedLineSwitchProvider._();

final class RoundedLineSwitchProvider
    extends $NotifierProvider<RoundedLineSwitch, bool> {
  RoundedLineSwitchProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'roundedLineSwitchProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$roundedLineSwitchHash();

  @$internal
  @override
  RoundedLineSwitch create() => RoundedLineSwitch();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$roundedLineSwitchHash() => r'e1e4c3457ca71a804c862aeddbdfeed2ebee06a8';

abstract class _$RoundedLineSwitch extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(ConnectLinesSwitch)
final connectLinesSwitchProvider = ConnectLinesSwitchProvider._();

final class ConnectLinesSwitchProvider
    extends $NotifierProvider<ConnectLinesSwitch, bool> {
  ConnectLinesSwitchProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'connectLinesSwitchProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$connectLinesSwitchHash();

  @$internal
  @override
  ConnectLinesSwitch create() => ConnectLinesSwitch();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$connectLinesSwitchHash() =>
    r'7eab774ede6e1c8542dbaa08c0f743f5ea19e553';

abstract class _$ConnectLinesSwitch extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(ColorMode)
final colorModeProvider = ColorModeProvider._();

final class ColorModeProvider extends $NotifierProvider<ColorMode, bool> {
  ColorModeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'colorModeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$colorModeHash();

  @$internal
  @override
  ColorMode create() => ColorMode();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$colorModeHash() => r'707d1fdf232d84a0ff0e6a25f283187447e37045';

abstract class _$ColorMode extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(BlinkDelay)
final blinkDelayProvider = BlinkDelayProvider._();

final class BlinkDelayProvider extends $NotifierProvider<BlinkDelay, double> {
  BlinkDelayProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'blinkDelayProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$blinkDelayHash();

  @$internal
  @override
  BlinkDelay create() => BlinkDelay();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$blinkDelayHash() => r'2b4b56d67d5e3fbbc72c37fac3fa31bddec5cc99';

abstract class _$BlinkDelay extends $Notifier<double> {
  double build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<double, double>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<double, double>,
              double,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(BlinkDuration)
final blinkDurationProvider = BlinkDurationProvider._();

final class BlinkDurationProvider
    extends $NotifierProvider<BlinkDuration, double> {
  BlinkDurationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'blinkDurationProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$blinkDurationHash();

  @$internal
  @override
  BlinkDuration create() => BlinkDuration();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$blinkDurationHash() => r'1a7868722675c86889168c418fab43a0aefca629';

abstract class _$BlinkDuration extends $Notifier<double> {
  double build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<double, double>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<double, double>,
              double,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(SearchBarButton)
final searchBarButtonProvider = SearchBarButtonProvider._();

final class SearchBarButtonProvider
    extends $NotifierProvider<SearchBarButton, double> {
  SearchBarButtonProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchBarButtonProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchBarButtonHash();

  @$internal
  @override
  SearchBarButton create() => SearchBarButton();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$searchBarButtonHash() => r'5432a5d63e6f57e929799f1acb17321659f301b4';

abstract class _$SearchBarButton extends $Notifier<double> {
  double build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<double, double>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<double, double>,
              double,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(SearchBarWidth)
final searchBarWidthProvider = SearchBarWidthProvider._();

final class SearchBarWidthProvider
    extends $NotifierProvider<SearchBarWidth, double> {
  SearchBarWidthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchBarWidthProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchBarWidthHash();

  @$internal
  @override
  SearchBarWidth create() => SearchBarWidth();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$searchBarWidthHash() => r'f0f3fc264030754b767f38b52ffd11a28c63c0ec';

abstract class _$SearchBarWidth extends $Notifier<double> {
  double build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<double, double>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<double, double>,
              double,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(ConnectionsEntries)
final connectionsEntriesProvider = ConnectionsEntriesProvider._();

final class ConnectionsEntriesProvider
    extends $NotifierProvider<ConnectionsEntries, List<Map<String, dynamic>>> {
  ConnectionsEntriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'connectionsEntriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$connectionsEntriesHash();

  @$internal
  @override
  ConnectionsEntries create() => ConnectionsEntries();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Map<String, dynamic>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Map<String, dynamic>>>(value),
    );
  }
}

String _$connectionsEntriesHash() =>
    r'e1a22143c9c2dbfc286e5afbe8e051f8cfa58168';

abstract class _$ConnectionsEntries
    extends $Notifier<List<Map<String, dynamic>>> {
  List<Map<String, dynamic>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<List<Map<String, dynamic>>, List<Map<String, dynamic>>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                List<Map<String, dynamic>>,
                List<Map<String, dynamic>>
              >,
              List<Map<String, dynamic>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(themeData)
final themeDataProvider = ThemeDataProvider._();

final class ThemeDataProvider
    extends $FunctionalProvider<ThemeData, ThemeData, ThemeData>
    with $Provider<ThemeData> {
  ThemeDataProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeDataProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeDataHash();

  @$internal
  @override
  $ProviderElement<ThemeData> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ThemeData create(Ref ref) {
    return themeData(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThemeData value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThemeData>(value),
    );
  }
}

String _$themeDataHash() => r'0165a58e8af94c67d8a81a00ea98f3bb4452f283';
