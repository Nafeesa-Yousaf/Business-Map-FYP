import 'package:business_map/utils/app_colors.dart';
import 'package:business_map/utils/size_config.dart';
import 'package:flutter/material.dart';

class CustomDropdownField<T> extends StatelessWidget {
  final List<DropdownMenuItem<T>> items;
  final T? value;
  final String hintText;
  final void Function(T?) onChanged;
  final String? Function(T?)? validator;
  final Color? fillColor;

  const CustomDropdownField({
    super.key,
    required this.items,
    this.value,
    required this.hintText,
    required this.onChanged,
    this.validator,
    this.fillColor,
  });

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        fillColor: fillColor ?? theme.inputDecorationTheme.fillColor,
        filled: true,
        contentPadding: EdgeInsets.symmetric(
          horizontal: SizeConfig.width(12),
          vertical: SizeConfig.height(10),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SizeConfig.radius(12)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SizeConfig.radius(10)),
          borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SizeConfig.radius(10)),
          borderSide: BorderSide(color: theme.primaryColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SizeConfig.radius(10)),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
      icon: const Icon(Icons.keyboard_arrow_down),
      dropdownColor: AppColors.pureWhite,
      isExpanded: true,
      menuMaxHeight: SizeConfig.height(300),
      style: theme.textTheme.bodyMedium,
    );
  }
}
