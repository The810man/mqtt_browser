import 'package:flutter/material.dart';

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
