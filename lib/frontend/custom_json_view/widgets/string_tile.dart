import 'package:flutter/material.dart';
import 'package:json_view/src/widgets/simple_tiles.dart';

import 'package:json_view/json_view.dart';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter/material.dart';

import 'package:json_view/json_view.dart';
import 'package:json_view/src/widgets/simple_tiles.dart';

class StringTile extends HookWidget {
  final String keyName;
  final String value;

  const StringTile({super.key, required this.keyName, required this.value});

  String getParsedKeyName(BuildContext context) {
    final quotation =
        JsonConfig.of(context).style?.quotation ?? const JsonQuotation();
    if (quotation.isEmpty) return keyName;
    return '${quotation.leftQuote}$keyName${quotation.rightQuote}';
  }

  @override
  Widget build(BuildContext context) {
    final config = JsonConfig.of(context);
    final expanded = useState(false);

    return LayoutBuilder(
      builder: (context, box) {
        /**
         *  [KEY_PREFIX]  [COLON]     [VALUE]
         *  [computed]    [computed]  [computed] 
         */
        double boxWidth = box.maxWidth;

        final text = TextSpan(
          children: [
            KeySpan(
              keyValue: getParsedKeyName(context),
              style: config.style?.keysStyle,
            ),
            const ColonSpan(),
            ValueSpan(value: '"$value"', style: config.style?.valuesStyle),
          ],
        );
        final painter = TextPainter(
          text: text,
          maxLines: 1,
          textDirection: TextDirection.ltr,
        )..layout(minWidth: 0, maxWidth: double.infinity);
        final realRenderWidth = painter.width;

        Widget selectedResult = _StringInnterTile(
          keyName: keyName,
          value: value,
          onTap: () => expanded.value = !expanded.value,
        );

        if (realRenderWidth > boxWidth) {
          Widget result = _StringOnlyDisplayTile(
            keyName: keyName,
            value: value,
            onTap: () => expanded.value = !expanded.value,
          );
          if (expanded.value) {
            result = selectedResult;
          }
          if (config.animation ?? JsonConfigData.kUseAnimation) {
            result = AnimatedSize(
              alignment: Alignment.topCenter,
              duration:
                  JsonConfig.of(context).animationDuration ??
                  const Duration(milliseconds: 300),
              curve: JsonConfig.of(context).animationCurve ?? Curves.ease,
              child: result,
            );
          }

          return result;
        } else {
          return selectedResult;
        }
      },
    );
  }
}

class _StringInnterTile extends KeyValueTile {
  const _StringInnterTile({
    required super.keyName,
    required String value,
    super.maxLines,
    super.onTap,
  }) : super(value: '"$value -beans"');

  @override
  Color valueColor(BuildContext context) =>
      colorScheme(context).stringColor ?? Colors.orange;
}

class _StringOnlyDisplayTile extends _StringInnterTile {
  const _StringOnlyDisplayTile({
    required super.keyName,
    required super.value,
    super.onTap,
  }) : super(maxLines: 1);
  @override
  Widget build(BuildContext context) {
    final cs = colorScheme(context);
    final spans = <InlineSpan>[
      KeySpan(
        keyValue: parsedKeyName(context),
        style: keyStyle(context).copyWith(color: cs.normalColor ?? Colors.grey),
      ),
      ColonSpan(
        style: keyStyle(
          context,
        ).copyWith(color: cs.markColor ?? Colors.white70),
      ),
      buildValue(context),
    ];

    Widget result = Text.rich(
      TextSpan(children: spans),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );

    result = GestureDetector(onTap: onTap, child: result);
    result = MouseRegion(cursor: SystemMouseCursors.click, child: result);

    if (leading == null) {
      result = Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Row(
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.auto_graph_outlined),
            ),
            result,
          ],
        ),
      );
    } else {
      result = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.auto_graph_outlined),
          ),
          SizedBox(child: leading),
          Expanded(child: result),
        ],
      );
    }

    return result;
  }
}
