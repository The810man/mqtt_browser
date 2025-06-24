import 'package:flutter/cupertino.dart';
import 'package:resizable_widget/resizable_widget.dart';

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
      return SizedBox(
        width: constraints.maxWidth,
        height: constraints.maxHeight,
        child: ResizableWidget(
          children: [leftWidget, Container(child: rightWidget)],
        ),
      );
    });
  }
}
