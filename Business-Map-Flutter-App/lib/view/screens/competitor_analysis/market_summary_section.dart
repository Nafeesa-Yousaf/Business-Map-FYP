import 'package:flutter/material.dart';
import 'package:business_map/utils/app_text_style.dart';
import 'package:business_map/utils/size_config.dart';

class MarketSummarySection extends StatelessWidget {
  final int totalCompetitors;
  final String competitionLevel;
  final Color competitionColor;

  const MarketSummarySection({
    super.key,
    required this.totalCompetitors,
    required this.competitionLevel,
    required this.competitionColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: _buildDataTile(
            context,
            title: "Competitor Count",
            value: totalCompetitors.toString(),
            label: "Competitors",
            icon: Icons.store_rounded,
            color: theme.primaryColor,
          ),
        ),
        SizedBox(width: SizeConfig.width(16)),
        Expanded(
          child: _buildDataTile(
            context,
            title: "Competition Level",
            value: competitionLevel,
            label: "Intensity",
            icon: Icons.speed_rounded,
            color: competitionColor,
          ),
        ),
      ],
    );
  }

  Widget _buildDataTile(
    BuildContext context, {
    required String title,
    required String value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          SizedBox(height: SizeConfig.height(12)),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.headingMedium(
              context,
            ).copyWith(fontWeight: FontWeight.w900, fontSize: 18, color: color),
          ),
        ],
      ),
    );
  }
}
