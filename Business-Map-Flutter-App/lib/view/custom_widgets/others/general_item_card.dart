import 'package:business_map/utils/app_colors.dart';
import 'package:business_map/utils/app_text_style.dart';
import 'package:business_map/utils/size_config.dart';
import 'package:business_map/view/custom_widgets/shimmer/custom_shimmer.dart';
import 'package:business_map/view/custom_widgets/others/app_network_image.dart';
import 'package:flutter/material.dart';

class GeneralItemCard extends StatelessWidget {
  final String name;
  final String location;
  final String description;
  final String imageUrl;
  final String? usp;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isSelected;

  const GeneralItemCard({
    super.key,
    required this.name,
    required this.location,
    required this.description,
    required this.imageUrl,
    this.usp,
    this.onTap,
    this.onLongPress,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Placeholder Widget for consistency
    Widget placeholderWidget() => Container(
          width: SizeConfig.screenWidth * 0.28,
          height: SizeConfig.height(90),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(SizeConfig.radius(15)),
          ),
          child: Icon(
            Icons.image_not_supported_outlined,
            color: Colors.grey[400],
            size: 30,
          ),
        );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.all(SizeConfig.width(10)),
      margin: EdgeInsets.symmetric(vertical: SizeConfig.height(4)),
      decoration: BoxDecoration(
        color: isSelected ? theme.primaryColor.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(SizeConfig.radius(16)),
        border: Border.all(
          color: isSelected ? theme.primaryColor : Colors.grey[100]!,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(SizeConfig.radius(15)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (isSelected)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: SizeConfig.width(10)),
                child: Icon(Icons.check_circle, color: theme.primaryColor),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: SizeConfig.height(4)),
                  Text(
                    location,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppColors.colorOnLight,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: SizeConfig.height(6)),
                  Text(
                    description,
                    style: AppTextStyles.bodyMedium(context).copyWith(
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (usp != null && usp!.isNotEmpty) ...[
                    SizedBox(height: SizeConfig.height(10)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star_rounded, color: Colors.amber[700], size: 14),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              usp!,
                              style: TextStyle(
                                color: theme.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: SizeConfig.text(10),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: SizeConfig.width(15)),
            ClipRRect(
              borderRadius: BorderRadius.circular(SizeConfig.radius(15)),
              child: imageUrl.isEmpty
                  ? placeholderWidget()
                  : AppNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      width: SizeConfig.screenWidth * 0.28,
                      height: SizeConfig.height(90),
                      placeholder: (context, url) => CustomShimmer(
                        width: SizeConfig.screenWidth * 0.32,
                        height: SizeConfig.height(110),
                      ),
                      errorWidget: (context, url, error) => placeholderWidget(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
