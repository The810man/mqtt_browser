import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

enum ArrowLocation { left, right }

enum Clickable { none, firstChildOnly, everywhere }

class CustomExpandable extends HookWidget {
  final Widget firstChild;
  final Widget secondChild;
  final Widget? subChild;
  final Function? onPressed;
  final Color backgroundColor;
  final Duration animationDuration;
  final DecorationImage? backgroundImage;
  final bool? showArrowWidget;
  final bool? initiallyExpanded;
  final bool centralizeFirstChild;
  final Widget? arrowWidget;
  final ArrowLocation? arrowLocation;
  final Function? onLongPress;
  final void Function(bool)? onHover;
  final List<BoxShadow>? boxShadow;
  final BorderRadius? borderRadius;
  final Clickable clickable;

  const CustomExpandable({
    super.key,
    required this.firstChild,
    required this.secondChild,
    this.subChild,
    this.onPressed,
    this.backgroundColor = Colors.white,
    this.animationDuration = const Duration(milliseconds: 0),
    this.backgroundImage,
    this.showArrowWidget,
    this.initiallyExpanded,
    this.centralizeFirstChild = true,
    this.arrowWidget,
    this.arrowLocation = ArrowLocation.right,
    this.borderRadius,
    this.clickable = Clickable.firstChildOnly,
    this.onLongPress,
    this.onHover,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final initiallyExpandedState = useState(initiallyExpanded ?? false);
    final controller = useAnimationController(duration: animationDuration);

    Animation<double> animationTween() {
      return Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn),
      );
    }

    final animationValue = animationTween();

    void toggleExpand() {
      if (initiallyExpandedState.value == true)
        initiallyExpandedState.value = false;
      switch (controller.status) {
        case AnimationStatus.completed:
          controller.reverse();
          break;
        case AnimationStatus.dismissed:
          controller.forward();
          break;
        case AnimationStatus.reverse:
        case AnimationStatus.forward:
          break;
      }
    }

    Future<void> onPressedHandler() async {
      if (onPressed != null && !controller.isAnimating) {
        await onPressed!();
      }
      toggleExpand();
    }

    Future<void> onLongPressHandler() async {
      if (onLongPress != null && !controller.isAnimating) {
        await onLongPress!();
      }
    }

    void onHoverHandler(bool value) {
      if (onHover != null) {
        onHover!(value);
      }
    }

    Widget buildRotation() => RotationTransition(
      turns: Tween(begin: 0.5, end: 0.0).animate(animationValue),
      child:
          arrowWidget ??
          const Icon(
            Icons.keyboard_arrow_up_rounded,
            color: Colors.black,
            size: 25.0,
          ),
    );

    Widget buildBodyWithArrow() {
      if (subChild != null) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            firstChild,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              textDirection: arrowLocation == ArrowLocation.right
                  ? TextDirection.ltr
                  : TextDirection.rtl,
              children: [
                if (centralizeFirstChild)
                  Visibility(visible: false, child: buildRotation()),
                subChild!,
                buildRotation(),
              ],
            ),
          ],
        );
      } else {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          textDirection: arrowLocation == ArrowLocation.right
              ? TextDirection.ltr
              : TextDirection.rtl,
          children: [
            if (centralizeFirstChild)
              Visibility(visible: false, child: buildRotation()),
            firstChild,
            buildRotation(),
          ],
        );
      }
    }

    SizeTransition buildSecondChild() => SizeTransition(
      axisAlignment: 1,
      axis: Axis.vertical,
      sizeFactor: animationValue,
      child: secondChild,
    );

    InkWell inkWellContainer(Widget child) => InkWell(
      hoverColor: Colors.transparent,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onHover: this.onHover != null ? onHoverHandler : null,
      onTap: clickable == Clickable.everywhere ? onPressedHandler : null,
      onLongPress: clickable == Clickable.everywhere
          ? onLongPressHandler
          : null,
      child: child,
    );

    if (initiallyExpandedState.value == true) toggleExpand();

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        image: backgroundImage,
        borderRadius: borderRadius ?? BorderRadius.circular(5.0),
        boxShadow:
            boxShadow ??
            [
              const BoxShadow(
                color: Colors.grey,
                offset: Offset(1, 1),
                blurRadius: 2,
              ),
            ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          InkWell(
            hoverColor: Colors.transparent,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onHover: onHover != null ? onHoverHandler : null,
            onTap: clickable != Clickable.none ? onPressedHandler : null,
            onLongPress: clickable != Clickable.none
                ? onLongPressHandler
                : null,
            child: showArrowWidget ?? true
                ? buildBodyWithArrow()
                : subChild != null
                ? Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [firstChild],
                      ),
                      subChild!,
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [firstChild],
                  ),
          ),
          inkWellContainer(buildSecondChild()),
        ],
      ),
    );
  }
}
