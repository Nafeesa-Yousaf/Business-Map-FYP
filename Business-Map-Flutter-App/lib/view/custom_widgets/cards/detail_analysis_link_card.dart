import 'package:business_map/utils/app_text_style.dart';
import 'package:business_map/utils/size_config.dart';
import 'package:business_map/view/custom_widgets/others/custom_chip.dart';
import 'package:flutter/material.dart';

class DetailAnalysisLinkCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? badge;
  final String imagePath;
  final Color? badgeColor;
  final VoidCallback onTap;
  final String heroTag;

  const DetailAnalysisLinkCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.badge,
    required this.imagePath,
    this.badgeColor,
    required this.onTap,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasBadge = badge != null && badge!.isNotEmpty;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Row(
          children: [
            Hero(
              tag: heroTag,
              child: Image.asset(
                imagePath,
                width: SizeConfig.width(80),
                height: SizeConfig.height(80),
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.headingMedium(context).copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodyMedium(context).copyWith(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),

                  if (hasBadge)
                    CustomChip(
                      label: badge!.toUpperCase(),
                      color: badgeColor,
                      fontSize: 10,
                      borderRadius: 6,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
