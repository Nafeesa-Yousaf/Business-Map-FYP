import 'package:business_map/utils/app_colors.dart';
import 'package:business_map/utils/size_config.dart';
import 'package:flutter/material.dart';

class AnalysisLoader extends StatelessWidget {
  final String? message;
  final VoidCallback? onCancel;

  const AnalysisLoader({super.key, this.message, this.onCancel});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Material(
      color: Colors.black.withOpacity(0.85),
      child: SizedBox.expand(
        child: Stack(
          children: [
            if (onCancel != null)
              Positioned(
                top: SizeConfig.height(16),
                right: SizeConfig.width(16),
                child: IconButton(
                  onPressed: onCancel,
                  tooltip: 'Cancel analysis',
                  icon: const Icon(Icons.close, color: AppColors.pureWhite),
                ),
              ),
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: SizeConfig.width(40)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildPulseLoader(theme),
                    SizedBox(height: SizeConfig.height(40)),
                    Text(
                      "Strategic Analysis",
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.pureWhite,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: SizeConfig.height(16)),
                    Text(
                      message?.toUpperCase() ??
                          "INITIALIZING GEOSPATIAL SCAN...",
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.primaryColor.withOpacity(0.9),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2.0,
                      ),
                    ),
                    SizedBox(height: SizeConfig.height(30)),
                    SizedBox(
                      width: SizeConfig.width(250),
                      child: Text(
                        "Our engine is evaluating commercial density and ROI potential for your business.",
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.pureWhite.withOpacity(0.5),
                          fontSize: SizeConfig.text(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPulseLoader(ThemeData theme) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: 1.5),
      duration: const Duration(seconds: 1),
      builder: (context, value, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: SizeConfig.width(80) * value,
              height: SizeConfig.width(80) * value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.primaryColor.withOpacity(0.2 / value),
              ),
            ),
            Container(
              width: SizeConfig.width(60) * value,
              height: SizeConfig.width(60) * value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.primaryColor.withOpacity(0.4 / value),
              ),
            ),
            Container(
              width: SizeConfig.width(50),
              height: SizeConfig.width(50),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.primaryColor,
                boxShadow: [
                  BoxShadow(
                    color: theme.primaryColor.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.analytics_outlined,
                color: Colors.white,
                size: 28,
              ),
            ),
          ],
        );
      },
      onEnd: () {},
    );
  }
}
