import 'package:business_map/utils/size_config.dart';
import 'package:business_map/view/custom_widgets/text/bullet_points.dart';
import 'package:flutter/material.dart';
import 'package:business_map/utils/app_colors.dart';
import 'package:business_map/utils/app_text_style.dart';

class SwotTile extends StatelessWidget {
  final String letter;
  final String title;
  final Color color;
  final List<String> points;

  const SwotTile({
    super.key,
    required this.letter,
    required this.title,
    required this.color,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: SizeConfig.width(45),
          backgroundColor: color,
          child: Text(
            letter,
            style: theme.textTheme.displayLarge?.copyWith(
              fontSize: 50,
              color: AppColors.pureWhite,
            ),
          ),
        ),
         SizedBox(width: SizeConfig.width(20)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.headingLarge(context).copyWith(
                  color: color,
                ),
              ),
              SizedBox(height: SizeConfig.height(6)),
              BulletPoints(points: points),
            ],
          ),
        ),
      ],
    );
  }
}
