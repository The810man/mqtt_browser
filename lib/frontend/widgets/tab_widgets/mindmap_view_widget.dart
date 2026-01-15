import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_browser/frontend/tree_node.dart';
import 'dart:math';

class MindmapViewWidget extends ConsumerWidget {
  final TreeNode rootNode;

  const MindmapViewWidget({super.key, required this.rootNode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Mindmap View (Radial Layout)',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: CustomPaint(
              painter: MindmapPainter(rootNode: rootNode),
              child: Container(),
            ),
          ),
        ],
      ),
    );
  }
}

class MindmapPainter extends CustomPainter {
  final TreeNode rootNode;

  MindmapPainter({required this.rootNode});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // Simple radial layout - root in center, children around it
    final center = Offset(size.width / 2, size.height / 2);
    const radius = 100.0;

    // Draw root
    canvas.drawCircle(center, 30, paint);
    textPainter.text = TextSpan(
      text: rootNode.label ?? 'Root',
      style: const TextStyle(color: Colors.black, fontSize: 12),
    );
    textPainter.layout();
    textPainter.paint(
        canvas, center - Offset(textPainter.width / 2, textPainter.height / 2));

    // Draw children in a circle
    final children = rootNode.children;
    for (int i = 0; i < children.length; i++) {
      final angle = (i * 2 * pi) / children.length;
      final childCenter =
          center + Offset(radius * cos(angle), radius * sin(angle));

      canvas.drawCircle(childCenter, 20, paint);
      canvas.drawLine(center, childCenter, paint);

      textPainter.text = TextSpan(
        text: children[i].label ?? 'Child',
        style: const TextStyle(color: Colors.black, fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(canvas,
          childCenter - Offset(textPainter.width / 2, textPainter.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
