// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mqtt_settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MqttSettingsService)
final mqttSettingsServiceProvider = MqttSettingsServiceProvider._();

final class MqttSettingsServiceProvider
    extends $AsyncNotifierProvider<MqttSettingsService, MqttSettings> {
  MqttSettingsServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mqttSettingsServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mqttSettingsServiceHash();

  @$internal
  @override
  MqttSettingsService create() => MqttSettingsService();
}

String _$mqttSettingsServiceHash() =>
    r'635330a5152671becba718cc54e35cda2798ec9a';

abstract class _$MqttSettingsService extends $AsyncNotifier<MqttSettings> {
  FutureOr<MqttSettings> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<MqttSettings>, MqttSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<MqttSettings>, MqttSettings>,
              AsyncValue<MqttSettings>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
