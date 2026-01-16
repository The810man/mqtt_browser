import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TiledBackground extends StatelessWidget {
  final Widget tile;
  final double spacing;
  final double opacity;

  const TiledBackground({
    super.key,
    required this.tile,
    this.spacing = 48.0,
    this.opacity = 0.08,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cols = (size.width / spacing).ceil();
    final rows = (size.height / spacing).ceil();
    return IgnorePointer(
      child: Opacity(
        opacity: opacity,
        child: Stack(
          children: [
            for (int row = 0; row < rows; row++)
              for (int col = 0; col < cols; col++)
                Positioned(
                  left: col * spacing,
                  top: row * spacing,
                  child: tile,
                ),
          ],
        ),
      ),
    );
  }
}

class InfiniteGridBackground extends ConsumerWidget {
  final double gridSize;
  final double lineWidth;
  final double lineOpacity;

  const InfiniteGridBackground({
    super.key,
    this.gridSize = 40.0,
    this.lineWidth = 1.0,
    this.lineOpacity = 0.3,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        CustomPaint(
          size: Size.infinite,
          painter: InfiniteGridPainter(
            gridSize: gridSize,
            lineWidth: lineWidth,
            lineColor: theme.colorScheme.primary.withValues(alpha: lineOpacity),
          ),
        ),
        // Subtle gradient overlay based on theme
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                colors: [
                  theme.colorScheme.surface.withValues(alpha: 0.9),
                  theme.colorScheme.surface.withValues(alpha: 0.8),
                  theme.colorScheme.surface.withValues(alpha: 0.5),
                  theme.colorScheme.surface.withValues(alpha: 0.3),
                  theme.colorScheme.surface.withValues(alpha: 0),
                ],
                // stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class InfiniteGridPainter extends CustomPainter {
  final double gridSize;
  final double lineWidth;
  final Color lineColor;

  const InfiniteGridPainter({
    required this.gridSize,
    required this.lineWidth,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = lineWidth
      ..style = PaintingStyle.stroke;

    final startX = (0 / gridSize).floor() * gridSize;
    final endX = ((size.width + gridSize) / gridSize).ceil() * gridSize;
    final startY = (0 / gridSize).floor() * gridSize;
    final endY = ((size.height + gridSize) / gridSize).ceil() * gridSize;

    // Vertical lines
    for (double x = startX; x <= endX; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Horizontal lines
    for (double y = startY; y <= endY; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant InfiniteGridPainter oldDelegate) =>
      oldDelegate.gridSize != gridSize ||
      oldDelegate.lineWidth != lineWidth ||
      oldDelegate.lineColor != lineColor;
}
