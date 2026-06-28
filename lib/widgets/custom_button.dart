import 'package:flutter/material.dart';
import 'neumorphic_container.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? color;
  final Color? textColor;
  final IconData? icon;
  final double borderRadius;
  final double verticalPadding;
  final bool isSecondary;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.color,
    this.textColor,
    this.icon,
    this.borderRadius = 18.0,
    this.verticalPadding = 14.0,
    this.isSecondary = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonColor = color ?? (isSecondary ? theme.colorScheme.secondary : theme.colorScheme.primary);
    final textStyle = TextStyle(
      fontSize: 16.0,
      fontWeight: FontWeight.bold,
      color: textColor ?? Colors.white,
    );

    return NeumorphicContainer(
      borderRadius: borderRadius,
      color: (isLoading || onPressed == null) ? buttonColor.withValues(alpha: 0.6) : buttonColor,
      onTap: (isLoading || onPressed == null) ? null : onPressed,
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: Center(
        child: isLoading
            ? const SizedBox(
                height: 20.0,
                width: 20.0,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20.0, color: textColor ?? Colors.white),
                    const SizedBox(width: 8.0),
                  ],
                  Text(text, style: textStyle),
                ],
              ),
      ),
    );
  }
}
