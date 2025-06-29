import 'dart:math';

import 'package:flutter/material.dart';

class LineWithStreakPainter extends CustomPainter {
  final Animation<double> animation;

  LineWithStreakPainter({required this.animation}) : super(repaint: animation);

  Path _buildInfinityPath(Size size) {
    final Path path = Path();
    final double w = size.width;
    final double h = size.height;
    final double cx = w / 2;
    final double cy = h / 2;

    final double loopOffsetX = w * 0.2;
    final double loopOffsetY = h * 0.3;

    // ✅ Start from far left center
    path.moveTo(0, 0);

    // 🔄 Left loop
    path.cubicTo(
      w * 0.15, cy - loopOffsetY, // Control point 1
      cx - loopOffsetX, cy - loopOffsetY, // Control point 2
      cx - loopOffsetX, cy, // End point
    );

    path.cubicTo(
      cx - loopOffsetX,
      cy + loopOffsetY,
      cx,
      cy + loopOffsetY,
      cx,
      cy,
    );

    // 🔁 Right loop
    path.cubicTo(
      cx,
      cy - loopOffsetY,
      cx + loopOffsetX,
      cy - loopOffsetY,
      cx + loopOffsetX,
      cy,
    );

    path.cubicTo(
      cx + loopOffsetX,
      cy + loopOffsetY,
      w * 0.85,
      cy + loopOffsetY,
      w,
      h,
    );

    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = _buildInfinityPath(size);
    final metric = path.computeMetrics().first;
    final totalLength = metric.length;

    final backgroundPaint = Paint()
      ..color = Colors.transparent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final streakPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = (120 * animation.value)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final progress = animation.value;

    // Draw full static 8 behind
    canvas.drawPath(path, backgroundPaint);

    if (progress <= 0.5) {
      // Phase 1: Draw from both ends inward
      final growingLength = totalLength * (progress / 0.5); // 0 to full

      final leftPath = metric.extractPath(0, growingLength / 2);
      final rightPath =
          metric.extractPath(totalLength - growingLength / 2, totalLength);

      canvas.drawPath(leftPath, streakPaint);
      canvas.drawPath(rightPath, streakPaint);
    }
    if (progress >= 0.5) {
      // Phase 2: Move forward and "erase" tail
      final shrinkingProgress = (progress - 0.5) / 0.937; // 0 → 1
      final headLength = totalLength;
      final tailLength = totalLength * shrinkingProgress;

      final leftPath = metric.extractPath(tailLength / 2, headLength / 2);
      final rightPath =
          metric.extractPath(headLength / 2, totalLength - (tailLength / 2));

      canvas.drawPath(leftPath, streakPaint);
      canvas.drawPath(rightPath, streakPaint);
    }
  }

  @override
  bool shouldRepaint(covariant LineWithStreakPainter oldDelegate) => true;
}
