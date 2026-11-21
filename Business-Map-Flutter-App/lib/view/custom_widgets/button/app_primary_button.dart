import 'package:business_map/utils/size_config.dart';
import 'package:flutter/material.dart';

class AppPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final double? width;
  final double? height;
  final double? horizontalPadding;
  final double? verticalPadding;
  final Color? textColor;
  final double? textSize;
  final Color? buttonColor;

  const AppPrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.width,
    this.height,
    this.horizontalPadding,
    this.verticalPadding,
    this.textColor,
    this.textSize,
    this.buttonColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool buttonEnabled = !isLoading && !isDisabled;

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: buttonEnabled ? onPressed : () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: isDisabled
              ? Colors.grey.shade400
              : buttonColor ?? Theme.of(context).primaryColor,
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding ?? SizeConfig.width(16),
            vertical: verticalPadding ?? SizeConfig.height(12),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: SizeConfig.width(20),
                height: SizeConfig.width(20),
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                text,
                style: TextStyle(
                  color: textColor ?? Colors.white,
                  fontSize: textSize ?? SizeConfig.text(14),
                ),
              ),
      ),
    );
  }
}
