import 'package:business_map/utils/app_text_style.dart';
import 'package:business_map/utils/size_config.dart';
import 'package:business_map/view/custom_widgets/button/app_primary_button.dart';
import 'package:flutter/material.dart';

/// Shared empty-state layout used across Saved, Suggestions, and similar screens.
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool usePrimaryTint;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
    this.usePrimaryTint = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tint = usePrimaryTint
        ? theme.primaryColor.withValues(alpha: 0.1)
        : Colors.grey[100]!;
    final iconColor =
        usePrimaryTint ? theme.primaryColor : Colors.grey[300]!;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: SizeConfig.width(40)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: tint,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 64, color: iconColor),
            ),
            SizedBox(height: SizeConfig.height(20)),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.headingMedium(context).copyWith(
                color: Colors.grey[700],
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            SizedBox(height: SizeConfig.height(8)),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
                fontSize: 14,
                height: 1.45,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: SizeConfig.height(28)),
              AppPrimaryButton(
                text: actionLabel!,
                onPressed: onAction,
                width: SizeConfig.width(220),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
