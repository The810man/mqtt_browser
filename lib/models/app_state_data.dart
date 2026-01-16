import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_state_data.freezed.dart';
part 'app_state_data.g.dart';

@freezed
abstract class AppStateData with _$AppStateData {
  const factory AppStateData({
    @Default('localhost') String host,
    @Default('1883') String port,
    @Default(0) int selectedTabIndex,
    @Default('') String publishMessage,
    @Default('raw') String codeBoxButtonState,
  }) = _AppStateData;

  factory AppStateData.fromJson(Map<String, dynamic> json) =>
      _$AppStateDataFromJson(json);
}
