import 'package:flutter/material.dart';
import 'package:business_map/utils/size_config.dart';
import '../../../custom_widgets/others/custom_chip.dart';
import 'business_section_header.dart';

class MarketAlignmentWidget extends StatelessWidget {
  final List<String> tags;

  const MarketAlignmentWidget({
    super.key,
    required this.tags,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BusinessSectionHeader(
          title: "Market Alignment",
          ttsText: "Market alignment indicators: ${tags.join(", ")}",
          sectionId: "alignment",
          accentColor: Colors.blue[400],
          showTts: false,
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tags.map((tag) => CustomChip(
            label: tag,
            fontSize: SizeConfig.text(12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          )).toList(),
        ),
      ],
    );
  }
}
