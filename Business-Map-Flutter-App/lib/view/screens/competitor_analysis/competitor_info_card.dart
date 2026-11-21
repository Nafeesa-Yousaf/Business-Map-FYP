import 'package:business_map/utils/app_text_style.dart';
import 'package:business_map/utils/size_config.dart';
import 'package:business_map/view/custom_widgets/others/app_network_image.dart';
import 'package:business_map/view/custom_widgets/shimmer/custom_shimmer.dart';
import 'package:flutter/material.dart';

class CompetitorInfoCard extends StatelessWidget {
  final String name;
  final double rating;
  final String distance;
  final String location;
  final String imageUrl;

  const CompetitorInfoCard({
    super.key,
    required this.name,
    required this.rating,
    required this.distance,
    required this.location,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Hero(
            tag: "comp_img_$name",
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: AppNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                width: SizeConfig.width(90),
                height: SizeConfig.height(90),
                placeholder: (context, url) => CustomShimmer(
                  width: SizeConfig.width(90),
                  height: SizeConfig.height(90),
                ),
                errorWidget: (context, url, error) => Container(
                  width: SizeConfig.width(90),
                  height: SizeConfig.height(90),
                  color: Colors.grey[100],
                  child: Icon(Icons.business_rounded, color: Colors.grey[400], size: 30),
                ),
              ),
            ),
          ),
          SizedBox(width: SizeConfig.width(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: AppTextStyles.headingMedium(context).copyWith(
                    fontSize: SizeConfig.text(16),
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                
                Row(
                  children: [
                    Row(
                      children: List.generate(5, (index) {
                        double starValue = index + 1;
                        if (rating >= starValue) {
                          return Icon(Icons.star_rounded, size: 14, color: Colors.amber[600]);
                        } else if (rating >= starValue - 0.5) {
                          return Icon(Icons.star_half_rounded, size: 14, color: Colors.amber[600]);
                        } else {
                          return Icon(Icons.star_outline_rounded, size: 14, color: Colors.amber[600]);
                        }
                      }),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      rating.toString(),
                      style: TextStyle(
                        fontSize: SizeConfig.text(12),
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Icon(Icons.navigation_rounded, size: 12, color: theme.primaryColor),
                    const SizedBox(width: 4),
                    Text(
                      distance,
                      style: TextStyle(
                        fontSize: SizeConfig.text(12),
                        color: theme.primaryColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Icon(Icons.room_rounded, size: 12, color: Colors.grey[400]),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location,
                        style: TextStyle(
                          fontSize: SizeConfig.text(11),
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
