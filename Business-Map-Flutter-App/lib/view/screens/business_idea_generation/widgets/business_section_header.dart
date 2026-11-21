import 'package:flutter/material.dart';
import 'package:business_map/utils/app_text_style.dart';
import 'package:business_map/view/custom_widgets/button/urdu_read_button.dart';

class BusinessSectionHeader extends StatelessWidget {
  final String title;
  final String? subTitle;
  final String ttsText;
  final String sectionId;
  final Color? accentColor;
  final bool showTts;

  const BusinessSectionHeader({
    super.key,
    required this.title,
    this.subTitle,
    required this.ttsText,
    required this.sectionId,
    this.accentColor,
    this.showTts = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (subTitle != null)
                  Text(
                    subTitle!.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                      color: accentColor ?? Colors.orange[400],
                    ),
                  ),
                if (subTitle != null) const SizedBox(height: 4),
                Text(
                  title,
                  style: AppTextStyles.headingMedium(context).copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          if (showTts) ...[
            const SizedBox(width: 8),
            UrduReadButton(
              text: ttsText,
              sectionId: sectionId,
              title: title,
            ),
          ],
        ],
      ),
    );
  }
}
