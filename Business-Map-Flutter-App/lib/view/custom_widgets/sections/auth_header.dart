import 'package:business_map/utils/app_text_style.dart';
import 'package:business_map/utils/images.dart';
import 'package:business_map/utils/size_config.dart';
import 'package:flutter/material.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const AuthHeader({
    super.key,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          Images.appLogo,
          height: SizeConfig.height(100),
          width: SizeConfig.width(100),
        ),

        SizedBox(height: SizeConfig.height(20)),

        Text(
          title,
          style: AppTextStyles.pageTitle(context),
          textAlign: TextAlign.center,
        ),

        if (subtitle != null) ...[
          SizedBox(height: SizeConfig.height(16)),
          Text(
            subtitle!,
            style: AppTextStyles.tagline(context),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
