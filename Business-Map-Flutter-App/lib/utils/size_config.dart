import 'package:flutter/material.dart';

class SizeConfig {
  static late double screenWidth;
  static late double screenHeight;
  static late double _blockSizeHorizontal;
  static late double _blockSizeVertical;
  static late bool isMobile;
  static late bool isTablet;
  static late bool isLandscape;
  static late double textScaleFactor;

  static void init(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    screenWidth = mediaQuery.size.width;
    screenHeight = mediaQuery.size.height;
    isLandscape = mediaQuery.orientation == Orientation.landscape;
    textScaleFactor = mediaQuery.textScaleFactor;

    isTablet = screenWidth >= 600;
    isMobile = !isTablet;

    const double baseWidthMobile = 390.0;
    const double baseHeightMobile = 844.0;
    const double baseWidthTablet = 768.0;
    const double baseHeightTablet = 1024.0;

    if (isMobile) {
      _blockSizeHorizontal = screenWidth / baseWidthMobile;
      _blockSizeVertical = screenHeight / baseHeightMobile;
    } else {
      _blockSizeHorizontal = screenWidth / baseWidthTablet;
      _blockSizeVertical = screenHeight / baseHeightTablet;
    }
  }

  static double height(double inputHeight) {
    return inputHeight * _blockSizeVertical;
  }

  static double width(double inputWidth) {
    return inputWidth * _blockSizeHorizontal;
  }

  static double text(double inputFontSize) {
    double scaledSize = inputFontSize * _blockSizeHorizontal;

    if (isMobile) {
      scaledSize = scaledSize.clamp(10.0, 24.0);
    } else {
      scaledSize = scaledSize.clamp(12.0, 28.0);
    }

    if (isLandscape) {
      scaledSize *= 0.9;
    }

    return scaledSize;
  }

  static double radius(double inputRadius) {
    return inputRadius * _blockSizeHorizontal;
  }

  static double icon(double inputIconSize) {
    double scaledSize = inputIconSize * _blockSizeHorizontal;
    return scaledSize.clamp(16.0, 48.0); // Safe range
  }

}
