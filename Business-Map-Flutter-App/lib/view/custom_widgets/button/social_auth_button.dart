import 'package:business_map/utils/app_text_style.dart';
import 'package:business_map/utils/size_config.dart';
import 'package:flutter/material.dart';

class SocialAuthButton extends StatelessWidget {
  final String text;
  final String iconPath;
  final VoidCallback onTap;
  final bool isLoading;

  const SocialAuthButton({
    super.key,
    required this.text,
    required this.iconPath,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: isLoading ? null : onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey.withOpacity(0.3)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SizeConfig.radius(15)),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    iconPath,
                    height: SizeConfig.height(20),
                  ),
                  SizedBox(width: SizeConfig.width(10)),
                  Text(
                    text,
                    style: AppTextStyles.googleButton(context),
                  ),
                ],
              ),
      ),
    );
  }
}
