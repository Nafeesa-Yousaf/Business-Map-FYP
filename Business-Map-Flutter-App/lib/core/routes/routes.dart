import 'package:business_map/core/routes/route_args.dart';
import 'package:business_map/core/routes/routes_name.dart';
import 'package:flutter/material.dart';
import 'package:business_map/view/screens/screens.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RoutesName.splashScreen:
        return MaterialPageRoute(builder: (context) => SplashScreen());
      case RoutesName.loginScreen:
        return MaterialPageRoute(builder: (context) => LoginScreen());
      case RoutesName.forgotPasswordScreen:
        return MaterialPageRoute(builder: (context) => ForgotPasswordScreen());
      case RoutesName.signupScreen:
        return MaterialPageRoute(builder: (context) => SignUpScreen());
      case RoutesName.dashboard:
        return MaterialPageRoute(builder: (context) => Dashboard());
      case RoutesName.profileScreen:
        return MaterialPageRoute(builder: (context) => ProfileScreen());
      case RoutesName.changePasswordScreen:
        return MaterialPageRoute(builder: (context) => ChangePasswordScreen());
      case RoutesName.locationDetailScreen:
        return MaterialPageRoute(
            builder: (context) => LocationDetailScreen(), settings: settings);
      case RoutesName.locationSuggestionScreen:
        return MaterialPageRoute(
          builder: (context) => LocationSuggestionScreen(),
        );
      case RoutesName.competitorAnalysisScreen:
        return MaterialPageRoute(
            builder: (context) => CompetitorAnalysisScreen(),
            settings: settings);
      case RoutesName.budgetBreakdownScreen:
        return MaterialPageRoute(
            builder: (context) => BudgetBreakdownScreen(), settings: settings);
      case RoutesName.businessIdeaSuggestionsScreen:
        return MaterialPageRoute(
          builder: (context) => const BusinessIdeaSuggestionsScreen(),
          settings: settings,
        );
      case RoutesName.businessIdeaDetailScreen:
        return MaterialPageRoute(
          builder: (context) => const BusinessIdeaDetailScreen(),
          settings: settings,
        );
      case RoutesName.deleteAccountScreen:
        return MaterialPageRoute(
          builder: (context) => DeleteAccountScreen(),
        );
      case RoutesName.aboutUsScreen:
        return MaterialPageRoute(
          builder: (context) => AboutUsScreen(),
        );
      case RoutesName.errorStateScreen:
        final parsed = ErrorRouteArgs.tryParse(settings.arguments);
        if (parsed == null || parsed.onRetry == null) {
          return MaterialPageRoute(
            builder: (context) => const Scaffold(
              body: Center(child: Text('Invalid error screen arguments')),
            ),
          );
        }
        return MaterialPageRoute(
          builder: (context) => ErrorStateScreen(
            errorType: parsed.errorType,
            title: parsed.title,
            message: parsed.message,
            onRetry: parsed.onRetry!,
          ),
        );
      case RoutesName.privacyPolicyScreen:
        return MaterialPageRoute(
          builder: (context) => PrivacyPolicyScreen(),
        );
      case RoutesName.arFeatureScreen:
        return MaterialPageRoute(
          builder: (context) => const ARFeatureScreen(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (context) {
            return const Scaffold(
              body: Center(child: Text("No route generated")),
            );
          },
        );
    }
  }
}
