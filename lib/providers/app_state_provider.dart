import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/app_state_data.dart';

part 'app_state_provider.g.dart';

@riverpod
class AppState extends _$AppState {
  @override
  AppStateData build() {
    return const AppStateData();
  }

  void setHost(String host) {
    state = state.copyWith(host: host);
  }

  void setPort(String port) {
    state = state.copyWith(port: port);
  }

  void setSelectedTab(int index) {
    state = state.copyWith(selectedTabIndex: index);
  }

  void setPublishMessage(String message) {
    state = state.copyWith(publishMessage: message);
  }

  void setCodeBoxButtonState(String state) {
    this.state = this.state.copyWith(codeBoxButtonState: state);
  }
}
