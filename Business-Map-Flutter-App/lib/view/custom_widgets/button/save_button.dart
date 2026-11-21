import 'package:business_map/utils/app_colors.dart';
import 'package:flutter/material.dart';

class SaveButton extends StatelessWidget {
  final bool isSaved;
  final bool isLoading;
  final VoidCallback onTap;
  final bool isMini;
  final bool isAppBarCollapsed;

  const SaveButton({
    super.key,
    required this.isSaved,
    required this.isLoading,
    required this.onTap,
    this.isMini = false,
    this.isAppBarCollapsed = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.all(isMini ? 6 : 10),
        decoration: BoxDecoration(
          color: isSaved 
            ? Colors.amber.withOpacity(0.15) 
            : (isAppBarCollapsed ? Colors.transparent : Colors.white),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            if (!isMini && !isSaved && !isAppBarCollapsed)
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: isLoading
          ? SizedBox(
              width: isMini ? 18 : 22, 
              height: isMini ? 18 : 22, 
              child: const CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(
              isSaved ? Icons.bookmark_rounded : Icons.bookmark_add_outlined,
              color: isSaved 
                ? Colors.amber[800] 
                : (isAppBarCollapsed ? theme.iconTheme.color : AppColors.iconColor),
              size: isMini ? 20 : 24,
            ),
      ),
    );
  }
}
