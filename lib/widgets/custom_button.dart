import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final IconData? iconData;
  final String? text;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color textColor;
  final Color borderColor;
  final bool isFilled;
  final double? height;
  final TextDecoration? decoration;
  final bool iconAtEnd;

  const CustomButton({
    super.key,
    this.iconData,
    this.text,
    required this.onTap,
    this.backgroundColor,
    this.textColor = Colors.black,
    this.borderColor = Colors.transparent,
    this.isFilled = true,
    this.height,
    this.decoration,
    this.iconAtEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null;

    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Opacity(
        opacity: isDisabled ? 0.5 : 1.0,
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isFilled ? backgroundColor : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 2.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (text?.isEmpty == true && isDisabled) ...[
                // 🔹 Show spinner instead of text
                const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              ] else ...[
                if (iconData != null && !iconAtEnd) ...[
                  Icon(iconData, color: textColor),
                  const SizedBox(width: 8),
                ],
                Text(
                  text ?? '',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    decoration: decoration,
                  ),
                ),
                if (iconData != null && iconAtEnd) ...[
                  const SizedBox(width: 8),
                  Icon(iconData, color: textColor),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
