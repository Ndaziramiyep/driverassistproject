import 'package:flutter/material.dart';

enum ButtonType { primary, secondary, text }

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final ButtonType type;
  final bool isLoading;
  final IconData? icon;
  final double? width;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.type = ButtonType.primary,
    this.isLoading = false,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
              Text(label),
            ],
          );

    Widget button;
    switch (type) {
      case ButtonType.secondary:
        button = OutlinedButton(onPressed: isLoading ? null : onPressed, child: child);
        break;
      case ButtonType.text:
        button = TextButton(onPressed: isLoading ? null : onPressed, child: child);
        break;
      default:
        button = ElevatedButton(onPressed: isLoading ? null : onPressed, child: child);
    }

    if (width != null) {
      return SizedBox(width: width, child: button);
    }
    return button;
  }
}
