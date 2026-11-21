import 'package:business_map/core/di/di_container.dart' as di;
import 'package:business_map/provider/auth/auth_provider.dart';
import 'package:business_map/provider/business/business_idea_provider.dart';
import 'package:business_map/provider/connectivity/connectivity_provider.dart';
import 'package:business_map/provider/dashboard/bottom_nav_bar_provider.dart';
import 'package:business_map/provider/input_options/input_options_provider.dart';
import 'package:business_map/provider/location/location_provider.dart';
import 'package:business_map/provider/profile/profile_provider.dart';
import 'package:business_map/provider/saved/saved_provider.dart';
import 'package:business_map/provider/tts/tts_provider.dart';
import 'package:business_map/theme/theme_light.dart';
import 'package:business_map/core/routes/routes.dart';
import 'package:business_map/core/routes/routes_name.dart';
import 'package:business_map/utils/size_config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await di.init();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => di.sl<AuthProvider>(),
        ),
        ChangeNotifierProvider<ProfileProvider>(
          create: (context) => di.sl<ProfileProvider>(),
        ),
        ChangeNotifierProvider<BottomNavBarProvider>(
          create: (context) => di.sl<BottomNavBarProvider>(),
        ),
        ChangeNotifierProvider<InputOptionsProvider>(
          create: (context) => di.sl<InputOptionsProvider>(),
        ),
        ChangeNotifierProvider<LocationProvider>(
          create: (context) => di.sl<LocationProvider>(),
        ),
        ChangeNotifierProvider<BusinessIdeaProvider>(
          create: (context) => di.sl<BusinessIdeaProvider>(),
        ),
        ChangeNotifierProvider<SavedProvider>(
          create: (context) => di.sl<SavedProvider>(),
        ),
        ChangeNotifierProvider<TTSProvider>(
          create: (context) => di.sl<TTSProvider>(),
        ),
        ChangeNotifierProvider<ConnectivityProvider>(
          create: (context) => di.sl<ConnectivityProvider>(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return MaterialApp(
      title: 'Business Map',
      theme: themeLight,
      debugShowCheckedModeBanner: false,
      initialRoute: RoutesName.splashScreen,
      onGenerateRoute: Routes.generateRoute,
    );
  }
}
