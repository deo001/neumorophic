import 'package:flutter/material.dart';

import 'colors.dart';


class NeumorphicTokens {
  NeumorphicTokens._();


  static const Color baseColor = CustomColors.backgroundColor;

  /// Shadow cast away from the light source.
  static const Color darkShadow = Color(0xFFBEBEBE);

  /// Highlight bounced back toward the light source.
  static const Color lightShadow = Color(0xFFFFFFFF);

  /// Direction the light comes from, top-left by convention.
  static const Alignment lightSource = Alignment.topLeft;


  /// Radius scale for large containers such as cards and sheets.
  static const double radiusLarge = 40;

  /// Radius scale for inputs and buttons.
  static const double radiusMedium = 20;

  /// Radius scale for small chips and dots.
  static const double radiusSmall = 12;

  /// Returns the two outer shadows for a raised (convex) surface.
  static List<BoxShadow> raisedShadows(double depth) => <BoxShadow>[
    BoxShadow(
      color: darkShadow,
      offset: Offset(depth, depth),
      blurRadius: depth * 2,
    ),
    BoxShadow(
      color: lightShadow,
      offset: Offset(-depth, -depth),
      blurRadius: depth * 2,
    ),
  ];

  static const LinearGradient pressedGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[Color(0xFFC8C8C8), Color(0xFFF2F2F2)],
  );
}

/// How a neumorphic surface sits relative to the background.
enum NeumorphicVariant {
  /// Extruded toward the viewer, lit from the top-left.
  raised,

  /// Recessed into the background.
  pressed,

  /// Same plane as the background, separated only by a border.
  flat,
}


class NeumorphicBox extends StatelessWidget {
  const NeumorphicBox({
    super.key,
    required this.child,
    this.variant = NeumorphicVariant.raised,
    this.depth = 6,
    this.radius = NeumorphicTokens.radiusMedium,
    this.borderRadius,
    this.padding = EdgeInsets.zero,
    this.margin = EdgeInsets.zero,
    this.color,
    this.shape = BoxShape.rectangle,
    this.width,
    this.height,
    this.alignment,
    this.gradient,
  });

  final Widget child;
  final NeumorphicVariant variant;
  final double depth;
  final double radius;

  /// Overrides [radius] when corners need to differ, such as a bottom bar that
  /// is rounded only at the top.
  final BorderRadius? borderRadius;

  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Color? color;
  final BoxShape shape;
  final double? width;
  final double? height;
  final AlignmentGeometry? alignment;
  final Gradient? gradient;

  List<BoxShadow> get _shadows => switch (variant) {
    NeumorphicVariant.raised => NeumorphicTokens.raisedShadows(depth),
    NeumorphicVariant.pressed => const <BoxShadow>[],
    NeumorphicVariant.flat => const <BoxShadow>[],
  };

  @override
  Widget build(BuildContext context) {
    final surfaceColor = color ?? NeumorphicTokens.baseColor;

    final decoration = BoxDecoration(
      color: variant == NeumorphicVariant.pressed ? null : surfaceColor,
      gradient: variant == NeumorphicVariant.pressed
          ? (gradient ?? NeumorphicTokens.pressedGradient)
          : gradient,
      borderRadius: shape == BoxShape.circle
          ? null
          : (borderRadius ?? BorderRadius.circular(radius)),
      shape: shape == BoxShape.circle ? BoxShape.circle : BoxShape.rectangle,
      boxShadow: _shadows,
      border: variant == NeumorphicVariant.flat
          ? Border.all(
              color: lightBorderOn(surfaceColor),
              width: 1.5,
            )
          : null,
    );

    return Container(
      width: width,
      height: height,
      alignment: alignment,
      margin: margin,
      padding: padding,
      decoration: decoration,
      child: child,
    );
  }

  /// A white border is invisible on a light base, so tint it just enough to read
  /// as an edge without reintroducing the hard outline neumorphism avoids.
  static Color lightBorderOn(Color surface) =>
      surface.computeLuminance() > 0.5 ? Colors.white : Colors.white24;
}

/// A neumorphic button that presses *into* the surface while held.
///
/// A neumorphic control has to physically react to touch, otherwise the raised
/// styling reads as decoration rather than something pressable.
class NeumorphicButton extends StatefulWidget {
  const NeumorphicButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.depth = 6,
    this.radius = NeumorphicTokens.radiusMedium,
    this.shape = BoxShape.rectangle,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.color,
    this.enabled = true,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final double depth;
  final double radius;
  final BoxShape shape;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Color? color;
  final bool enabled;

  @override
  State<NeumorphicButton> createState() => _NeumorphicButtonState();
}

class _NeumorphicButtonState extends State<NeumorphicButton> {
  bool _isPressed = false;

  bool get _isActive => widget.enabled && widget.onPressed != null;

  void _setPressed(bool value) {
    if (!_isActive || _isPressed == value) return;
    setState(() => _isPressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final surfaceColor = widget.color ?? NeumorphicTokens.baseColor;

    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: _isActive ? widget.onPressed : null,
      child: AnimatedScale(
        // A slight scale-down sells the press even for circular keys.
        scale: _isPressed ? 0.96 : 1,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          margin: widget.margin,
          decoration: BoxDecoration(
            color: _isPressed ? surfaceColor : surfaceColor,
            gradient: _isPressed ? NeumorphicTokens.pressedGradient : null,
            borderRadius: widget.shape == BoxShape.circle
                ? null
                : BorderRadius.circular(widget.radius),
            shape: widget.shape == BoxShape.circle
                ? BoxShape.circle
                : BoxShape.rectangle,
            boxShadow: _isPressed
                ? const <BoxShadow>[]
                : NeumorphicTokens.raisedShadows(widget.depth),
          ),
          child: Padding(padding: widget.padding, child: widget.child),
        ),
      ),
    );
  }
}

/// A row of dots showing how many PIN digits have been entered.
///
/// Rendered recessed so it reads as a slot the digits drop into, with filled
/// dots in the accent color and empty slots left as hollow rings.
class NeumorphicDots extends StatelessWidget {
  const NeumorphicDots({
    super.key,
    required this.total,
    required this.filled,
    this.dotSize = 18,
    this.spacing = 20,
  });

  final int total;
  final int filled;
  final double dotSize;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$filled of $total digits entered',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (int i = 0; i < total; i++) ...<Widget>[
            if (i > 0) SizedBox(width: spacing),
            _PinDot(isFilled: i < filled, size: dotSize),
          ],
        ],
      ),
    );
  }
}

class _PinDot extends StatelessWidget {
  const _PinDot({required this.isFilled, required this.size});

  final bool isFilled;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (isFilled) {
      return Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: CustomColors.primaryColor,
          shape: BoxShape.circle,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: NeumorphicTokens.darkShadow,
              offset: Offset(2, 2),
              blurRadius: 4,
            ),
            BoxShadow(
              color: NeumorphicTokens.lightShadow,
              offset: Offset(-2, -2),
              blurRadius: 4,
            ),
          ],
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: NeumorphicTokens.pressedGradient,
      ),
    );
  }
}
