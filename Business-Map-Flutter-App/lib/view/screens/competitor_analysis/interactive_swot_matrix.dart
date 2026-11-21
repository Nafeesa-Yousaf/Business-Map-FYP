import 'package:flutter/material.dart';
import 'package:business_map/data/model/response/location_suggestion_response.dart';
import 'package:business_map/view/custom_widgets/button/urdu_read_button.dart';
import 'package:business_map/provider/tts/tts_provider.dart';
import 'package:provider/provider.dart';

class InteractiveSwotMatrix extends StatelessWidget {
  final Insights insights;

  const InteractiveSwotMatrix({super.key, required this.insights});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableWidth = constraints.maxWidth;
        final double matrixSize = (availableWidth - 90).clamp(180, 320);

        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildAxisLabel(Icons.keyboard_arrow_up_rounded, "INTERNAL"),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildAxisLabelVertical(
                    Icons.keyboard_arrow_left_rounded,
                    "HELPFUL",
                  ),

                  Container(
                    width: matrixSize,
                    height: matrixSize,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 1.5,
                          height: matrixSize,
                          color: Colors.grey[200],
                        ),
                        Container(
                          width: matrixSize,
                          height: 1.5,
                          color: Colors.grey[200],
                        ),

                        Column(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  _buildQuadrantBox(
                                    context,
                                    "Strengths",
                                    insights.strengths,
                                    const Color(0xFFC8E6C9),
                                    const Color(0xFF1B5E20),
                                    Icons.bolt_rounded,
                                  ),
                                  _buildQuadrantBox(
                                    context,
                                    "Weaknesses",
                                    insights.weaknesses,
                                    const Color(0xFFFFE0B2),
                                    const Color(0xFFE65100),
                                    Icons.report_problem_rounded,
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  _buildQuadrantBox(
                                    context,
                                    "Opportunities",
                                    insights.opportunities,
                                    const Color(0xFFBBDEFB),
                                    const Color(0xFF0D47A1),
                                    Icons.trending_up_rounded,
                                  ),
                                  _buildQuadrantBox(
                                    context,
                                    "Threats",
                                    insights.threats,
                                    const Color(0xFFF8BBD0),
                                    const Color(0xFF880E4F),
                                    Icons.gpp_maybe_rounded,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.grey[300]!,
                              width: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  _buildAxisLabelVertical(
                    Icons.keyboard_arrow_right_rounded,
                    "HARMFUL",
                  ),
                ],
              ),

              _buildAxisLabel(Icons.keyboard_arrow_down_rounded, "EXTERNAL"),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAxisLabel(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Icon(icon, size: 16, color: Colors.grey[400]),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[500],
              fontWeight: FontWeight.w900,
              fontSize: 9,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAxisLabelVertical(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: RotatedBox(
        quarterTurns: 3,
        child: Column(
          children: [
            Icon(icon, size: 14, color: Colors.grey[400]),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[500],
                fontWeight: FontWeight.w900,
                fontSize: 8,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuadrantBox(
    BuildContext context,
    String title,
    List<String> points,
    Color bgColor,
    Color textColor,
    IconData icon,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _showSwotDetails(context, title, points, textColor, icon),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: textColor.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: textColor.withOpacity(0.4), size: 22),
              const SizedBox(height: 6),
              Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "${points.length} Insights",
                style: TextStyle(
                  color: textColor.withOpacity(0.5),
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSwotDetails(
    BuildContext context,
    String title,
    List<String> points,
    Color color,
    IconData icon,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(icon, color: color, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        title,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  UrduReadButton(
                    text: points.join(". "),
                    sectionId: 'swot_${title.toLowerCase()}',
                    title: title,
                  ),
                ],
              ),

              const SizedBox(height: 32),

              ...points
                  .map(
                    (p) => Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: color.withOpacity(0.08)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            size: 18,
                            color: color.withOpacity(0.4),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              p,
                              style: TextStyle(
                                color: Colors.grey[800],
                                height: 1.5,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ],
          ),
        );
      },
    ).whenComplete(() {
      try {
        Provider.of<TTSProvider>(context, listen: false).stop();
      } catch (e) {}
    });
  }
}
