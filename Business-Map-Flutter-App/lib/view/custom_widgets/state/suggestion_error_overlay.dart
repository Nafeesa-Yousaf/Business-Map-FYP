import 'package:business_map/utils/app_colors.dart';
import 'package:business_map/utils/app_text_style.dart';
import 'package:business_map/utils/size_config.dart';
import 'package:business_map/view/custom_widgets/button/app_primary_button.dart';
import 'package:flutter/material.dart';

/// Full-screen overlay for failed location / idea suggestion requests with retry.
class SuggestionErrorOverlay extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onDismiss;
  final bool isRetrying;

  const SuggestionErrorOverlay({
    super.key,
    required this.message,
    required this.onRetry,
    required this.onDismiss,
    this.isRetrying = false,
  });

  bool get _isOffline {
    final lower = message.toLowerCase();
    return lower.contains('internet') ||
        lower.contains('network') ||
        lower.contains('connection') ||
        lower.contains('socket');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = _isOffline ? "No Connection" : "Suggestion Failed";
    final icon = _isOffline ? Icons.wifi_off_rounded : Icons.cloud_off_rounded;

    return Material(
      color: Colors.white.withValues(alpha: 0.97),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: SizeConfig.width(32)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(SizeConfig.width(28)),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: SizeConfig.width(64), color: theme.primaryColor),
              ),
              SizedBox(height: SizeConfig.height(32)),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTextStyles.headingMedium(context).copyWith(
                  fontWeight: FontWeight.w900,
                  color: theme.primaryColor,
                ),
              ),
              SizedBox(height: SizeConfig.height(12)),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium(context).copyWith(
                  color: AppColors.iconColor,
                  height: 1.5,
                ),
              ),
              SizedBox(height: SizeConfig.height(40)),
              AppPrimaryButton(
                text: "Retry",
                onPressed: onRetry,
                isLoading: isRetrying,
                width: SizeConfig.width(200),
              ),
              SizedBox(height: SizeConfig.height(12)),
              TextButton(
                onPressed: isRetrying ? null : onDismiss,
                child: Text(
                  "Dismiss",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
