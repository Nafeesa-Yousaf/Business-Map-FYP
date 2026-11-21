import 'package:flutter/material.dart';
import 'package:business_map/utils/app_text_style.dart';
import 'package:business_map/utils/size_config.dart';
import 'package:business_map/view/custom_widgets/text/read_more_text_widget.dart';
import 'business_section_header.dart';

class SuitabilityAnalysisWidget extends StatelessWidget {
  final String judgment;

  const SuitabilityAnalysisWidget({
    super.key,
    required this.judgment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(SizeConfig.width(16)),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2FE),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.blue.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BusinessSectionHeader(
            title: "Why this works",
            ttsText: judgment,
            sectionId: "expert",
            accentColor: Colors.blue[700],
          ),
          ReadMoreTextWidget(
            text: judgment,
            trimLines: 3,
          ),
        ],
      ),
    );
  }
}
