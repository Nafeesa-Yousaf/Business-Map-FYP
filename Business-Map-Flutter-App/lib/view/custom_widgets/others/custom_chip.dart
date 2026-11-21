import 'package:business_map/utils/size_config.dart';
import 'package:flutter/material.dart';

class CustomChip extends StatelessWidget {
  final String label;
  final Color? color;
  final Color? backgroundColor;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final bool isBold;
  final Gradient? gradient;

  const CustomChip({
    super.key,
    required this.label,
    this.color,
    this.backgroundColor,
    this.fontSize,
    this.padding,
    this.borderRadius,
    this.isBold = true,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.primaryColor;
    final effectiveBgColor = backgroundColor ?? effectiveColor.withOpacity(0.08);

    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: gradient != null ? null : effectiveBgColor,
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius ?? 10),
        border: Border.all(color: effectiveColor.withOpacity(0.12)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: effectiveColor,
          fontWeight: isBold ? FontWeight.w700 : FontWeight.normal,
          fontSize: fontSize ?? SizeConfig.text(11),
        ),
      ),
    );
  }
}
