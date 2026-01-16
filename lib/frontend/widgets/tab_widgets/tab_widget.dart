import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class Tabwidget extends ConsumerWidget {
  const Tabwidget({
    super.key,
    required this.unSelectedIcon,
    required this.selectedWidget,
    required this.text,
  });
  final Icon unSelectedIcon;
  final Widget selectedWidget;
  final String text;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Tab(child: Text(text, style: theme.textTheme.bodyMedium));
  }
}
