// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connections_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Connections)
final connectionsProvider = ConnectionsProvider._();

final class ConnectionsProvider
    extends $NotifierProvider<Connections, List<Connection>> {
  ConnectionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'connectionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$connectionsHash();

  @$internal
  @override
  Connections create() => Connections();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Connection> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Connection>>(value),
    );
  }
}

String _$connectionsHash() => r'cdb9bbe27fd8826e7091ebb6f47c9106158ce3fa';

abstract class _$Connections extends $Notifier<List<Connection>> {
  List<Connection> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<Connection>, List<Connection>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<Connection>, List<Connection>>,
              List<Connection>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
