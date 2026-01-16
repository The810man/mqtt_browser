import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_browser/frontend/tree_node.dart';
import 'package:mqtt_browser/providers/providers.dart';

class mainAppBar extends ConsumerWidget {
  const mainAppBar({
    super.key,
    required this.textController,
    required this.root,
  });
  final TextEditingController textController;
  final TreeNode root;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(
      tabDataProvider,
    )["${root.label}"]?['controller'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Row(
            children: [
              const Text(
                'TreeView Page ',
                style: TextStyle(color: Colors.black),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    iconSize: 20,
                    onPressed: () {
                      controller?.expandAll();
                    },
                    icon: const Icon(
                      Icons.open_in_full_rounded,
                      color: Colors.black,
                    ),
                  ),
                  IconButton(
                    iconSize: 20,
                    onPressed: () {
                      controller?.collapseAll();
                    },
                    icon: const Icon(
                      Icons.close_fullscreen_rounded,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
