import 'package:flutter/material.dart';
import 'neumorphic_container.dart';

class CustomTextField extends StatefulWidget {
  final String labelText;
  final String hintText;
  final TextEditingController controller;
  final IconData prefixIcon;
  final bool isPassword;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final int maxLines;

  const CustomTextField({
    super.key,
    required this.labelText,
    required this.hintText,
    required this.controller,
    required this.prefixIcon,
    this.isPassword = false,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.labelText.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4.0, bottom: 6.0),
            child: Text(
              widget.labelText,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14.0,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
        NeumorphicContainer(
          isInset: true,
          borderRadius: 18.0,
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: TextFormField(
            controller: widget.controller,
            obscureText: widget.isPassword ? _obscureText : false,
            keyboardType: widget.keyboardType,
            maxLines: widget.maxLines,
            style: TextStyle(color: theme.colorScheme.onSurface),
            validator: widget.validator,
            decoration: InputDecoration(
              hintText: widget.hintText,
              prefixIcon: Icon(widget.prefixIcon, color: theme.colorScheme.primary),
              suffixIcon: widget.isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                        color: theme.colorScheme.secondary,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    )
                  : null,
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 14.0),
              hintStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
            ),
          ),
        ),
      ],
    );
  }
}
