import 'package:flutter/material.dart';
import 'package:business_map/utils/app_text_style.dart';
import 'business_section_header.dart';

class TargetAudienceWidget extends StatelessWidget {
  final List<String> audiences;

  const TargetAudienceWidget({
    super.key,
    required this.audiences,
  });

  @override
  Widget build(BuildContext context) {
    final List<Color> cardColors = [
      const Color(0xFFF0F9FF),
      const Color(0xFFFFF7ED),
      const Color(0xFFF5F3FF),
      const Color(0xFFECFDF5),
    ];

    final List<Color> accentColors = [
      Colors.blue[400]!,
      Colors.orange[400]!,
      Colors.purple[400]!,
      Colors.green[400]!,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BusinessSectionHeader(
          title: "Target Audience",
          subTitle: "Demographics",
          ttsText: audiences.join(". "),
          sectionId: "audience",
          accentColor: Colors.green[400],
        ),

        SizedBox(height: 12,),
        Builder(
          builder: (context) {
            final List<Widget> rows = [];
            for (int i = 0; i < audiences.length; i += 2) {
              rows.add(
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: _buildAudienceCard(i, audiences[i], cardColors, accentColors)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: (i + 1 < audiences.length)
                              ? _buildAudienceCard(i + 1, audiences[i + 1], cardColors, accentColors)
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            return Column(children: rows);
          },
        ),
      ],
    );
  }

  Widget _buildAudienceCard(int idx, String audience, List<Color> cardColors, List<Color> accentColors) {
    Color bgColor = cardColors[idx % cardColors.length];
    Color accentColor = accentColors[idx % accentColors.length];
    
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 36, 16, 16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: accentColor.withOpacity(0.1)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.group_rounded,
                color: accentColor.withOpacity(0.6),
                size: 28,
              ),
              const SizedBox(height: 12),
              Text(
                audience,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[800],
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: -16,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: accentColor, width: 2),
              ),
              child: Center(
                child: Text(
                  "${idx + 1}",
                  style: TextStyle(
                    color: accentColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
