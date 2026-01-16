// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mqtt_client_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MqttClientNotifier)
final mqttClientProvider = MqttClientNotifierProvider._();

final class MqttClientNotifierProvider
    extends $NotifierProvider<MqttClientNotifier, MqttConnectionState> {
  MqttClientNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mqttClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mqttClientNotifierHash();

  @$internal
  @override
  MqttClientNotifier create() => MqttClientNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MqttConnectionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MqttConnectionState>(value),
    );
  }
}

String _$mqttClientNotifierHash() =>
    r'6a053ae877c6890293530c7d7df87dd2168155cb';

abstract class _$MqttClientNotifier extends $Notifier<MqttConnectionState> {
  MqttConnectionState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<MqttConnectionState, MqttConnectionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MqttConnectionState, MqttConnectionState>,
              MqttConnectionState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
