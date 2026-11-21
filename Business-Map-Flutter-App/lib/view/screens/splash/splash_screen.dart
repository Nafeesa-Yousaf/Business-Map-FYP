import 'package:business_map/provider/auth/auth_provider.dart';
import 'package:business_map/provider/input_options/input_options_provider.dart';
import 'package:business_map/provider/profile/profile_provider.dart';
import 'package:business_map/utils/app_colors.dart';
import 'package:business_map/utils/app_text_style.dart';
import 'package:business_map/utils/images.dart';
import 'package:business_map/core/routes/routes_name.dart';
import 'package:business_map/utils/size_config.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/error_state_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth(context);
  }

  Future<void> _checkAuth(BuildContext context, {bool isRetry = false}) async {
    final authProvider = context.read<AuthProvider>();
    final profileProvider = context.read<ProfileProvider>();

    final isUserAuthenticated = await authProvider.isUserLoggedIn();

    if (isUserAuthenticated) {
      final inputOptionsProvider = context.read<InputOptionsProvider>();
      
      try {
        await Future.wait([
          profileProvider.fetchUserData(),
          inputOptionsProvider.fetchAllHomeData(),
        ]);

        Navigator.pushNamedAndRemoveUntil(context, RoutesName.dashboard,  (route) => false);
        
      } catch (e) {
        if (isRetry) rethrow;
        
        ErrorType type = ErrorType.apiError;
        if (e.toString().toLowerCase().contains('socket') ||
            e.toString().toLowerCase().contains('network') ||
            e.toString().toLowerCase().contains('connection')) {
          type = ErrorType.noInternet;
        }

        Navigator.pushReplacementNamed(
          context, 
          RoutesName.errorStateScreen,
          arguments: {
            'errorType': type,
            'message': e.toString().replaceFirst('Exception: ', ''),
            'onRetry': (ctx) async {
              await _checkAuth(ctx, isRetry: true);
            }
          }
        );
      }
    } else {
      Navigator.pushNamedAndRemoveUntil(context, RoutesName.loginScreen, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Container(
      height: SizeConfig.screenHeight,
      width: SizeConfig.screenWidth,
      color: theme.primaryColor,
      padding: EdgeInsets.symmetric(
        vertical: SizeConfig.width(20),
        horizontal: SizeConfig.height(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            Images.splashImg,
            height: SizeConfig.height(285),
            width: SizeConfig.width(285),
          ),
          SizedBox(height: SizeConfig.height(20)),
          Text(
            "Business Map",
            style: AppTextStyles.pageTitle(
              context,
            ).copyWith(color: AppColors.pureWhite),
          ),
          SizedBox(height: SizeConfig.height(10)),
          Text(
            "Where Opportunity Meets Location",
            textAlign: TextAlign.center,
            style: AppTextStyles.tagline(
              context,
            ).copyWith(color: AppColors.pureWhite),
          ),
        ],
      ),
    );
  }
}
