import 'package:expandable_widgets/expandable_widgets.dart';
import 'package:flutter/material.dart';

class CustomExpandable extends StatefulWidget {
  /// • The widget that is placed at the non-collapsing part of the expandable.
  final Widget firstChild;

  /// • The widget that size transition affects.
  final Widget secondChild;

  /// •
  final Widget? subChild;

  /// • Animation starts BEFORE and ends AFTER this function.
  ///
  /// • Notice that this function can not be triggered more than once while animating Expandable.
  final Function? onPressed;

  /// • Background color of the expandable.
  final Color backgroundColor;

  /// • Duration for expand & rotate animations.
  final Duration animationDuration;

  /// • Background image of the expandable.
  final DecorationImage? backgroundImage;

  /// • Whether [arrowWidget] will be shown or not.
  final bool? showArrowWidget;

  /// • Whether expandable will be expanded or collapsed at first.
  final bool? initiallyExpanded;

  /// • Provides better alignment for [firstChild].
  final bool centralizeFirstChild;

  /// • Custom widget that changes its direction with respect to expand animation.
  final Widget? arrowWidget;

  /// • Place of the arrow widget.
  final ArrowLocation? arrowLocation;

  final Function? onLongPress;

  /// • Custom animation for size & rotation animations.
  ///
  /// • Notice that there is no separate support for size & rotation animations.
  final Animation<double>? animation;

  /// • Controller for [animation].
  ///
  /// • Useful when one want to interact with the expandable with an external button etc.
  final AnimationController? animationController;

  final void Function(bool)? onHover;

  final List<BoxShadow>? boxShadow;

  /// • [BorderRadius] of [Expandable].
  ///
  /// • shape property removed from the version 1.0.2 (no need) and [borderRadius] added.
  final BorderRadius? borderRadius;

  /// • Decide click behaviour of the Expandable.
  ///
  /// • See [Clickable] for possible options.
  final Clickable clickable;

  /// • Expandable widget for general use.
  ///
  /// • [backgroundColor], [animationDuration], [centralizeFirstChild] & [clickable] arguments must not be null.
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
    this.animation,
    this.animationController,
    this.onHover,
    this.boxShadow,
  });

  @override
  _CustomExpandableState createState() => _CustomExpandableState();
}

class _CustomExpandableState extends State<CustomExpandable>
    with TickerProviderStateMixin {
  final Animatable<double> _sizeTween = Tween<double>(begin: 0.0, end: 1.0);
  late AnimationController _controller;
  late Animation<double> _animation;
  bool? _initiallyExpanded = false;

  @override
  void initState() {
    _initiallyExpanded = widget.initiallyExpanded ?? false;
    _controller = widget.animationController ??
        AnimationController(vsync: this, duration: widget.animationDuration);
    _animation = widget.animation ??
        _sizeTween.animate(
            CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn));
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_initiallyExpanded == true) _toggleExpand();
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        image: widget.backgroundImage,
        borderRadius: widget.borderRadius ?? BorderRadius.circular(5.0),
        boxShadow: widget.boxShadow ??
            [
              const BoxShadow(
                  color: Colors.grey, offset: Offset(1, 1), blurRadius: 2)
            ],
      ),
      child: _buildVerticalExpandable(),
    );
  }

  RotationTransition _buildRotation() {
    return RotationTransition(
      turns: Tween(begin: 0.5, end: 0.0).animate(_animation),
      child: widget.arrowWidget ??
          const Icon(Icons.keyboard_arrow_up_rounded,
              color: Colors.black, size: 25.0),
    );
  }

  Column _buildVerticalExpandable() => Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          InkWell(
            hoverColor: Colors.transparent,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onHover: widget.onHover != null ? _onHover() : null,
            onTap: widget.clickable != Clickable.none ? _onPressed : null,
            onLongPress:
                widget.clickable != Clickable.none ? _onLongPress : null,
            child: widget.showArrowWidget ?? true == true
                ? _buildBodyWithArrow()
                : widget.subChild != null
                    ? Column(
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [widget.firstChild]),
                          widget.subChild!,
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [widget.firstChild]),
          ),
          _inkWellContainer(_buildSecondChild()),
        ],
      );

  Widget _buildBodyWithArrow() {
    return widget.subChild != null
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              widget.firstChild,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                textDirection: widget.arrowLocation == ArrowLocation.right
                    ? TextDirection.ltr
                    : TextDirection.rtl,
                children: [
                  if (widget.centralizeFirstChild)
                    Visibility(visible: false, child: _buildRotation()),
                  widget.subChild!,
                  _buildRotation(),
                ],
              ),
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            textDirection: widget.arrowLocation == ArrowLocation.right
                ? TextDirection.ltr
                : TextDirection.rtl,
            children: [
              if (widget.centralizeFirstChild)
                Visibility(visible: false, child: _buildRotation()),
              widget.firstChild,
              _buildRotation(),
            ],
          );
  }

  SizeTransition _buildSecondChild() => SizeTransition(
        axisAlignment: 1,
        axis: Axis.vertical,
        sizeFactor: _animation,
        child: widget.secondChild,
      );

  void _toggleExpand() {
    if (_initiallyExpanded == true) _initiallyExpanded = false;
    switch (_animation.status) {
      case AnimationStatus.completed:
        _controller.reverse();
        break;
      case AnimationStatus.dismissed:
        _controller.forward();
        break;
      case AnimationStatus.reverse:
      case AnimationStatus.forward:
        break;
    }
  }

  Future<void> _onPressed() async {
    if (widget.onPressed != null && !_controller.isAnimating) {
      await widget.onPressed!();
    }
    _toggleExpand();
  }

  Future<void> _onLongPress() async {
    if (widget.onLongPress != null && !_controller.isAnimating) {
      await widget.onLongPress!();
    }
  }

  Function(bool) _onHover() {
    return (value) {
      widget.onHover!;
      if (value == true) {
        _toggleExpand();
      } else if (value == false) {
        if (_initiallyExpanded != true) _controller.reverse();
      }
    };
  }

  InkWell _inkWellContainer(Widget child) {
    return InkWell(
      hoverColor: Colors.transparent,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onHover: widget.onHover != null ? _onHover() : null,
      onTap: widget.clickable == Clickable.everywhere ? _onPressed : null,
      onLongPress:
          widget.clickable == Clickable.everywhere ? _onLongPress : null,
      child: child,
    );
  }
}
