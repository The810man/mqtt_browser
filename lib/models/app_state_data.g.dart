// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_state_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppStateData _$AppStateDataFromJson(Map<String, dynamic> json) =>
    _AppStateData(
      host: json['host'] as String? ?? 'localhost',
      port: json['port'] as String? ?? '1883',
      selectedTabIndex: (json['selectedTabIndex'] as num?)?.toInt() ?? 0,
      publishMessage: json['publishMessage'] as String? ?? '',
      codeBoxButtonState: json['codeBoxButtonState'] as String? ?? 'raw',
    );

Map<String, dynamic> _$AppStateDataToJson(_AppStateData instance) =>
    <String, dynamic>{
      'host': instance.host,
      'port': instance.port,
      'selectedTabIndex': instance.selectedTabIndex,
      'publishMessage': instance.publishMessage,
      'codeBoxButtonState': instance.codeBoxButtonState,
    };
