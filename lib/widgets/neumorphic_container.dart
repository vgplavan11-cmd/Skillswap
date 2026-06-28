import 'package:flutter/material.dart';

class NeumorphicContainer extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final double borderRadius;
  final bool isInset;
  final Color? color;
  final BoxShape shape;
  final VoidCallback? onTap;
  final AlignmentGeometry? alignment;

  const NeumorphicContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.borderRadius = 20.0,
    this.isInset = false,
    this.color,
    this.shape = BoxShape.rectangle,
    this.onTap,
    this.alignment,
  });

  @override
  State<NeumorphicContainer> createState() => _NeumorphicContainerState();
}

class _NeumorphicContainerState extends State<NeumorphicContainer> with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      setState(() {
        _isPressed = true;
        _scale = 0.98;
      });
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onTap != null) {
      setState(() {
        _isPressed = false;
        _scale = 1.0;
      });
      widget.onTap!();
    }
  }

  void _onTapCancel() {
    if (widget.onTap != null) {
      setState(() {
        _isPressed = false;
        _scale = 1.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Core Neomorphic Color Palette Adaptation
    final defaultBgColor = isDark 
        ? const Color(0xFF1E293B) // Dark Surface
        : const Color(0xFFF4F5F7); // Light Surface
        
    final shadowColorLight = isDark 
        ? const Color(0xFF2D3A4F).withAlpha(100)
        : const Color(0xFFFFFFFF);
        
    final shadowColorDark = isDark 
        ? const Color(0xFF090D16).withAlpha(200)
        : const Color(0xFF9CA3AF).withAlpha(90);

    BoxDecoration boxDec;

    if (widget.isInset) {
      // Inset simulation (e.g. for input fields)
      boxDec = BoxDecoration(
        color: widget.color ?? defaultBgColor,
        shape: widget.shape,
        borderRadius: widget.shape == BoxShape.rectangle ? BorderRadius.circular(widget.borderRadius) : null,
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFD6D8DB), 
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColorLight,
            offset: const Offset(-2, -2),
            blurRadius: 4,
          ),
          BoxShadow(
            color: shadowColorDark,
            offset: const Offset(2, 2),
            blurRadius: 4,
          ),
        ],
      );
    } else {
      // Raised Neomorphic card with dynamic scale / compression on press
      boxDec = BoxDecoration(
        color: widget.color ?? defaultBgColor,
        shape: widget.shape,
        borderRadius: widget.shape == BoxShape.rectangle ? BorderRadius.circular(widget.borderRadius) : null,
        boxShadow: _isPressed
            ? [
                BoxShadow(
                  color: shadowColorLight,
                  offset: const Offset(-2, -2),
                  blurRadius: 4,
                ),
                BoxShadow(
                  color: shadowColorDark,
                  offset: const Offset(2, 2),
                  blurRadius: 4,
                ),
              ]
            : [
                BoxShadow(
                  color: shadowColorLight,
                  offset: const Offset(-5, -5),
                  blurRadius: 10,
                ),
                BoxShadow(
                  color: shadowColorDark,
                  offset: const Offset(5, 5),
                  blurRadius: 10,
                ),
              ],
      );
    }

    Widget content = Container(
      width: widget.width,
      height: widget.height,
      padding: widget.padding,
      alignment: widget.alignment,
      decoration: boxDec,
      child: widget.child,
    );

    if (widget.onTap != null) {
      content = GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeInOut,
          child: content,
        ),
      );
    }

    if (widget.margin != null) {
      content = Padding(
        padding: widget.margin!,
        child: content,
      );
    }

    return content;
  }
}
