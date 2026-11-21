import 'package:business_map/utils/app_colors.dart';
import 'package:business_map/utils/app_text_style.dart';
import 'package:business_map/utils/size_config.dart';
import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final List<Map<String, dynamic>> navItems;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.navItems,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: SizeConfig.height(60),
      padding: EdgeInsets.symmetric(horizontal: SizeConfig.width(20)),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: AppColors.colorOnLight.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          navItems.length,
              (index) => GestureDetector(
            onTap: () => onTap(index),
            child: _BottomNavItem(
              icon: navItems[index]['icon'],
              label: navItems[index]['label'],
              isActive: currentIndex == index,
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.width(12),
        vertical: SizeConfig.height(8),
      ),
      decoration: BoxDecoration(
        color: isActive ? theme.primaryColor.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(SizeConfig.radius(30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: SizeConfig.icon(26),
            color: isActive ? theme.primaryColor : theme.iconTheme.color,
          ),
          if (isActive) SizedBox(width: SizeConfig.width(6)),
          if (isActive)
            Text(
              label,
              style: AppTextStyles.formLabel(context).copyWith(
                color: theme.primaryColor,
                fontSize: SizeConfig.text(12)
              ),
            ),
        ],
      ),
    );
  }
}
