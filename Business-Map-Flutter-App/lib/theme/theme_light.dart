import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:business_map/utils/size_config.dart';

final themeLight = ThemeData(
  primaryColor: const Color(0xFF006D77),
  scaffoldBackgroundColor: Colors.white,
  colorScheme: ColorScheme.light(
    primary: const Color(0xFF006D77),
    secondary: const Color(0xFF83C5BE),
    surface: Colors.white,
    background: const Color(0xFFF8F9FA),
    error: const Color(0xFFE63946),
    brightness: Brightness.light,
  ),

  textTheme: TextTheme(
    displayLarge: GoogleFonts.montserrat(
      fontSize: SizeConfig.text(57),
      fontWeight: FontWeight.w800,
      color: const Color(0xFF1A1A1A),
      letterSpacing: -1.5,
    ),
    displayMedium: GoogleFonts.montserrat(
      fontSize: SizeConfig.text(45),
      fontWeight: FontWeight.w700,
      color: const Color(0xFF1A1A1A),
      letterSpacing: -1.0,
    ),
    displaySmall: GoogleFonts.montserrat(
      fontSize: SizeConfig.text(36),
      fontWeight: FontWeight.w600,
      color: const Color(0xFF1A1A1A),
      letterSpacing: -0.5,
    ),

    headlineLarge: GoogleFonts.montserrat(
      fontSize: SizeConfig.text(32),
      fontWeight: FontWeight.w700,
      color: const Color(0xFF1F2937),
    ),
    headlineMedium: GoogleFonts.montserrat(
      fontSize: SizeConfig.text(24),
      fontWeight: FontWeight.w600,
      color: const Color(0xFF1F2937),
    ),
    headlineSmall: GoogleFonts.montserrat(
      fontSize: SizeConfig.text(20),
      fontWeight: FontWeight.w600,
      color: const Color(0xFF000000),
    ),

    titleLarge: GoogleFonts.montserrat(
      fontSize: SizeConfig.text(22),
      fontWeight: FontWeight.w600,
      color: const Color(0xFF1F2937),
    ),
    titleMedium: GoogleFonts.montserrat(
      fontSize: SizeConfig.text(18),
      fontWeight: FontWeight.w600,
      color: const Color(0xFF1F2937),
    ),
    titleSmall: GoogleFonts.montserrat(
      fontSize: SizeConfig.text(16),
      fontWeight: FontWeight.w500,
      color: const Color(0xFF000000),
    ),

    bodyLarge: GoogleFonts.poppins(
      fontSize: SizeConfig.text(16),
      fontWeight: FontWeight.w400,
      color: const Color(0xFF4B5563),
      height: 1.6,
    ),
    bodyMedium: GoogleFonts.poppins(
      fontSize: SizeConfig.text(14),
      fontWeight: FontWeight.w400,
      color: const Color(0xFF4B5563),
      height: 1.5,
    ),
    bodySmall: GoogleFonts.poppins(
      fontSize: SizeConfig.text(12),
      fontWeight: FontWeight.w400,
      color: const Color(0xFF6B7280),
    ),

    labelLarge: GoogleFonts.poppins(
      fontSize: SizeConfig.text(16),
      fontWeight: FontWeight.w500,
      color: Color(0xFF4B5563),
    ),
    labelMedium: GoogleFonts.poppins(
      fontSize: SizeConfig.text(14),
      fontWeight: FontWeight.w500,
      color: const Color(0xFF1F2937),
    ),
    labelSmall: GoogleFonts.poppins(
      fontSize: SizeConfig.text(12),
      fontWeight: FontWeight.w500,
      color: const Color(0xFF6B7280),
    ),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF006D77),
      foregroundColor: Colors.white,
      textStyle: GoogleFonts.montserrat(
          fontSize: SizeConfig.text(16),
          fontWeight: FontWeight.w600,
          color: Colors.white
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SizeConfig.radius(12)),
      ),
      padding: EdgeInsets.symmetric(
        vertical: SizeConfig.height(16),
        horizontal: SizeConfig.width(24),
      ),
      elevation: 0,
      shadowColor: Colors.transparent,
      animationDuration: const Duration(milliseconds: 200),
      enableFeedback: true,
    ),
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: const Color(0xFF006D77),
      textStyle: GoogleFonts.poppins(
        fontSize: SizeConfig.text(14),
        fontWeight: FontWeight.w500,
      ),
      padding: EdgeInsets.symmetric(
        vertical: SizeConfig.height(12),
        horizontal: SizeConfig.width(16),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SizeConfig.radius(8)),
      ),
    ),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: const Color(0xFF006D77),
      side: const BorderSide(color: Color(0xFF006D77), width: 1),
      textStyle: GoogleFonts.poppins(
        fontSize: SizeConfig.text(14),
        color: Color(0xFF4B5563),
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SizeConfig.radius(12)),
      ),
      padding: EdgeInsets.symmetric(
        vertical: SizeConfig.height(14),
        horizontal: SizeConfig.width(24),
      ),
    ),
  ),

  cardTheme: CardThemeData(
    color: const Color(0xFF006D77).withOpacity(0.09),
    elevation: 1,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(SizeConfig.radius(16)),
      side: BorderSide(
        color:const Color(0xFF006D77),
        width: 1
      )
    ),
    margin: EdgeInsets.all(SizeConfig.width(8)),
    shadowColor: Colors.black.withOpacity(0.1),
    surfaceTintColor: Colors.transparent,
  ),

  appBarTheme: AppBarTheme(
    backgroundColor: Colors.white,
    elevation: 0.5,
    centerTitle: false,
    titleSpacing: 0,
    surfaceTintColor: Colors.transparent,
    iconTheme:  IconThemeData(color: Color(0xFF006D77), size: SizeConfig.icon(24)),
    titleTextStyle: GoogleFonts.montserrat(
      fontSize: SizeConfig.text(20),
      fontWeight: FontWeight.w600,
      color: const Color(0xFF1A1A1A),
    ),
    scrolledUnderElevation: 1,
  ),

  iconTheme: IconThemeData(
    color: const Color(0xFF4B5563),
    size: SizeConfig.icon(20),
  ),

  inputDecorationTheme: InputDecorationTheme(
    contentPadding: EdgeInsets.symmetric(
      vertical: SizeConfig.height(10),
      horizontal: SizeConfig.width(12),
    ),
    filled: true,
    fillColor: Color(0xffF7FBFD),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(SizeConfig.radius(12)),
      borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(SizeConfig.radius(12)),
      borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(SizeConfig.radius(12)),
      borderSide: const BorderSide(color: Color(0xFF006D77), width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(SizeConfig.radius(12)),
      borderSide: const BorderSide(color: Color(0xFFE63946), width: 1.5),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(SizeConfig.radius(12)),
      borderSide: const BorderSide(color: Color(0xFFE63946), width: 1.5),
    ),
    hintStyle: GoogleFonts.poppins(
      fontSize: SizeConfig.text(14),
      color: const Color(0xFF9CA3AF),
    ),
    labelStyle: GoogleFonts.poppins(
      fontSize: SizeConfig.text(14),
      color: const Color(0xFF4B5563),
      fontWeight: FontWeight.w500,
    ),
    floatingLabelStyle: GoogleFonts.poppins(
      color: const Color(0xFF006D77),
      fontWeight: FontWeight.w600,
    ),
    errorMaxLines: 3,
    errorStyle: GoogleFonts.poppins(
      fontSize: SizeConfig.text(12),
      color: const Color(0xFFE63946),
    ),
  ),

  dividerTheme: DividerThemeData(
    color: const Color(0xFF4B5563).withOpacity(0.5),
    thickness: 1,
    space: 0,
    indent: 20,
    endIndent: 20,
  ),

  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: const Color(0xFF006D77),
    foregroundColor: Colors.white,
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(SizeConfig.radius(16)),
    ),
  ),

  chipTheme: ChipThemeData(
    backgroundColor: const Color(0xFF006D77).withOpacity(0.09),
    disabledColor: const Color(0xFFE5E7EB),
    selectedColor: const Color(0xFF006D77),
    secondarySelectedColor: const Color(0xFF83C5BE),
    labelStyle: GoogleFonts.poppins(
      fontSize: SizeConfig.text(12),
      color: const Color(0xff5D5D5D),
      fontWeight: FontWeight.w500,
    ),
    secondaryLabelStyle: GoogleFonts.poppins(
      fontSize: SizeConfig.text(12),
      color: Colors.white,
      fontWeight: FontWeight.w500,
    ),
    padding: EdgeInsets.symmetric(
      horizontal: SizeConfig.width(12),
      vertical: SizeConfig.height(6),
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(SizeConfig.radius(30)),
      side: BorderSide(
        color: Color(0xFF006D77).withOpacity(0.5),
      )
    ),
  ),
  dropdownMenuTheme: DropdownMenuThemeData(
    textStyle: GoogleFonts.poppins(
      fontSize: SizeConfig.text(14),
      color: const Color(0xFF1F2937),
    ),
    menuStyle: MenuStyle(
      backgroundColor: const MaterialStatePropertyAll(Colors.white),
      elevation: const MaterialStatePropertyAll(2),
      surfaceTintColor: const MaterialStatePropertyAll(Colors.transparent),
      shape: MaterialStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SizeConfig.radius(12)),
          side: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
      ),
      padding: MaterialStatePropertyAll(
        EdgeInsets.symmetric(vertical: SizeConfig.height(8)),
      ),
    ),
  ),

);
