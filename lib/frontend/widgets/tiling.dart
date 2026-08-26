import 'package:flutter/material.dart';
import 'package:resizable_widget/resizable_widget.dart';
import 'package:mqtt_browser/frontend/responsive.dart';

class Tiling extends StatelessWidget {
  const Tiling({
    super.key,
    required this.leftWidget,
    required this.rightWidget,
    this.leftLabel = 'Tree',
    this.rightLabel = 'Details',
  });

  final Widget leftWidget;
  final Widget rightWidget;
  final String leftLabel;
  final String rightLabel;

  @override
  Widget build(BuildContext context) {
    if (isMobile(context)) {
      return _MobileTiling(
        leftWidget: leftWidget,
        rightWidget: rightWidget,
        leftLabel: leftLabel,
        rightLabel: rightLabel,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) => SizedBox(
        width: constraints.maxWidth,
        height: constraints.maxHeight,
        child: ResizableWidget(
          children: [leftWidget, rightWidget],
        ),
      ),
    );
  }
}

class _MobileTiling extends StatefulWidget {
  const _MobileTiling({
    required this.leftWidget,
    required this.rightWidget,
    required this.leftLabel,
    required this.rightLabel,
  });

  final Widget leftWidget;
  final Widget rightWidget;
  final String leftLabel;
  final String rightLabel;

  @override
  State<_MobileTiling> createState() => _MobileTilingState();
}

class _MobileTilingState extends State<_MobileTiling>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Material(
          color: cs.surfaceContainerHighest,
          child: TabBar(
            controller: _tab,
            tabs: [
              Tab(icon: const Icon(Icons.account_tree_rounded), text: widget.leftLabel),
              Tab(icon: const Icon(Icons.info_outline), text: widget.rightLabel),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tab,
            children: [widget.leftWidget, widget.rightWidget],
          ),
        ),
      ],
    );
  }
}
