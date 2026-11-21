import 'package:business_map/utils/app_text_style.dart';
import 'package:business_map/utils/size_config.dart';
import 'package:flutter/material.dart';

class SectionLabel extends StatelessWidget {
  final String label;
  final double? bottomPadding;
  final bool isBold;
  final Widget? trailing;

  const SectionLabel({
    super.key,
    required this.label,
    this.bottomPadding,
    this.isBold = true,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding ?? SizeConfig.height(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.formLabel(context).copyWith(
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
