import 'package:flutter/material.dart';

class AppTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? textColor;
  final double? textSize;
  final Widget? leading;
  final Widget? trailing;
  final bool isBold;

  const AppTextButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.textColor,
    this.textSize,
    this.leading,
    this.trailing,
    this.isBold=false
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        minimumSize: Size.zero,
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 4)],
          Text(
            text,
            style: Theme.of(context).textTheme.labelMedium!.copyWith(
              color: textColor ?? Theme.of(context).colorScheme.primary,
              fontSize: textSize,
              fontWeight: isBold?FontWeight.bold:FontWeight.normal
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 4), trailing!],
        ],
      ),
    );
  }
}
