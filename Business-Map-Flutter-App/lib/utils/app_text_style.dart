import 'package:business_map/utils/size_config.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class AppTextStyles {
  static TextStyle pageTitle(BuildContext context) => Theme.of(context).textTheme.headlineLarge!;
  static TextStyle formLabel(BuildContext context) => Theme.of(context).textTheme.labelLarge!;
  static TextStyle textButton(BuildContext context) => Theme.of(context).textTheme.labelMedium!.copyWith(
    color: Theme.of(context).colorScheme.primary,
  );
  static TextStyle tagline(BuildContext context) => Theme.of(context).textTheme.bodyLarge!;
  static TextStyle dividerLabel(BuildContext context) => Theme.of(context).textTheme.bodyMedium!;
  static TextStyle googleButton(BuildContext context) => Theme.of(context).textTheme.labelLarge!;
  static TextStyle signupPrompt(BuildContext context) => Theme.of(context).textTheme.bodyMedium!;
  static TextStyle drawerItems(BuildContext context) => Theme.of(context).textTheme.bodyMedium!;
  static TextStyle headingLarge(BuildContext context) => Theme.of(context).textTheme.headlineMedium!;
  static TextStyle headingMedium(BuildContext context) => Theme.of(context).textTheme.headlineSmall!;
  static TextStyle bodyMedium(BuildContext context) => Theme.of(context).textTheme.bodyMedium!;
  static TextStyle bodyLarge(BuildContext context) => Theme.of(context).textTheme.bodyLarge!;
  static TextStyle bodySmall(BuildContext context) => Theme.of(context).textTheme.bodySmall!;
  static TextStyle headingSmall(BuildContext context) => Theme.of(context).textTheme.titleLarge!;

  static TextStyle primaryButtonTextStyle=GoogleFonts.montserrat(
      fontSize: SizeConfig.text(16),
      fontWeight: FontWeight.w600,
      color: Colors.white
  );
}
