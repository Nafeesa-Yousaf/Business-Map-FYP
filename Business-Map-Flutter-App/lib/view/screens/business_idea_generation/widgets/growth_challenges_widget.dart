import 'package:flutter/material.dart';
import 'package:business_map/data/model/response/business_idea_suggestion_response.dart';
import 'package:business_map/utils/app_text_style.dart';
import 'package:business_map/utils/images.dart';
import 'package:business_map/view/custom_widgets/button/urdu_read_button.dart';

class GrowthChallengesWidget extends StatelessWidget {
  final BusinessIdea idea;

  const GrowthChallengesWidget({super.key, required this.idea});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "HURDLES",
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                        color: Color(0xFFE9967A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Growth Challenges",
                      style: AppTextStyles.headingMedium(
                        context,
                      ).copyWith(fontWeight: FontWeight.w900, fontSize: 22),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              UrduReadButton(
                text: idea.challenges.join(". "),
                sectionId: 'challenges_v2',
                title: 'Challenges',
              ),
            ],
          ),
        ),

        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 220,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.asset(
                          Images.growthChallengeImg,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.6),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE9967A),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              "RISK FACTOR",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 7,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Market\nResistance",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              flex: 3,
              child: Column(
                children: idea.challenges.asMap().entries.map((entry) {
                  int idx = entry.key;
                  String challenge = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: IntrinsicHeight(
                      child: Row(
                        children: [
                          Container(width: 4, color: const Color(0xFFE9967A)),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFADADD),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        "${idx + 1}",
                                        style: const TextStyle(
                                          color: Color(0xFFD32F2F),
                                          fontWeight: FontWeight.w900,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      challenge,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[800],
                                        fontWeight: FontWeight.w600,
                                        height: 1.3,
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
                }).toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
