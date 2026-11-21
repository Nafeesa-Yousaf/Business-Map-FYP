import 'package:business_map/utils/app_text_style.dart';
import 'package:flutter/material.dart';

class DetailSectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color themeColor;
  final Widget content;
  final double borderRadius;

  final Widget? trailing;

  const DetailSectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.themeColor,
    required this.content,
    this.borderRadius = 28,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Icon(icon, size: 100, color: themeColor.withOpacity(0.03)),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: themeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, size: 20, color: themeColor),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyles.headingMedium(context).copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    if (trailing != null) trailing!,
                  ],
                ),
                const SizedBox(height: 18),
                content,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
