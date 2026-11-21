import 'package:business_map/utils/size_config.dart';
import 'package:flutter/material.dart';

class CustomSnackbar {
  static void show({
    required BuildContext context,
    required String message,
    bool isError = false,
    Duration duration = const Duration(seconds: 3),
    ScaffoldMessengerState? messenger,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final snackBar = SnackBar(
      backgroundColor: isError
          ? colorScheme.errorContainer
          : colorScheme.primaryContainer,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      duration: duration,
      padding: EdgeInsets.zero,
      content: Stack(
        alignment: AlignmentDirectional.topEnd,
        children: [
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.width(16),
                vertical: SizeConfig.height(12),
              ),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isError
                      ? colorScheme.onErrorContainer
                      : colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
          Positioned(
            right: 5,
            top: 5,
            child: GestureDetector(
              child: Icon(
                Icons.close,
                color: isError
                    ? colorScheme.onErrorContainer
                    : colorScheme.onPrimaryContainer,
              ),
              onTap: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
            ),
          ),
        ],
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}
