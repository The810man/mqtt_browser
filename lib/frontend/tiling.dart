import 'package:flutter/cupertino.dart';

class Tiling extends StatelessWidget {
  const Tiling({
    super.key,
    required this.leftWidget,
    required this.rightWidget,
  });
  final Widget leftWidget;
  final Widget rightWidget;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth / 2;
      return SizedBox(
        width: constraints.maxWidth,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(
              width: width,
              height: constraints.maxHeight,
              child: leftWidget,
            ),
            SizedBox(
              width: width,
              height: constraints.maxHeight,
              child: rightWidget,
            )
          ],
        ),
      );
    });
  }
}
