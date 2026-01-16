import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/tree_service.dart';

part 'tree_provider.g.dart';

@riverpod
TreeService treeService(Ref ref) {
  return TreeService();
}
