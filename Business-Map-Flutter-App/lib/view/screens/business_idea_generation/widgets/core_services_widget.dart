import 'package:flutter/material.dart';
import 'package:business_map/utils/app_text_style.dart';
import 'business_section_header.dart';

class CoreServicesWidget extends StatelessWidget {
  final List<String> services;

  const CoreServicesWidget({
    super.key,
    required this.services,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BusinessSectionHeader(
          title: "Core Services",
          subTitle: "What you offer",
          ttsText: services.join(". "),
          sectionId: "services",
          accentColor: theme.primaryColor,
        ),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: services.map((service) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_outline_rounded, 
                    color: theme.primaryColor, size: 18),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      service,
                      style: AppTextStyles.bodyMedium(context).copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
