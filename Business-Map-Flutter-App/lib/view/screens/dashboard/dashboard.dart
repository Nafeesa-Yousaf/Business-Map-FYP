import 'package:business_map/provider/business/business_idea_provider.dart';
import 'package:business_map/provider/connectivity/connectivity_provider.dart';
import 'package:business_map/provider/location/location_provider.dart';
import 'package:business_map/utils/size_config.dart';
import 'package:business_map/view/custom_widgets/bottom_nav_bar/custom_bottom_nav_bar.dart';
import 'package:business_map/view/custom_widgets/state/offline_banner.dart';
import 'package:business_map/view/screens/drawer/drawer.dart';
import 'package:business_map/view/screens/home/home_screen.dart';
import 'package:business_map/view/screens/saved/save_item_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../provider/dashboard/bottom_nav_bar_provider.dart';
import '../../../provider/profile/profile_provider.dart';
import '../business_idea_generation/business_idea_generation_screen.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  void initState() {
    super.initState();
  }

  final List<Map<String, dynamic>> _navItems = [
    {'icon': Icons.home_outlined, 'label': "Home"},
    {'icon': Icons.lightbulb_outline_rounded, 'label': "Suggestion"},
    {'icon': Icons.bookmark_border_outlined, 'label': "Saved"},
  ];

  final List<Widget> tabs = [
    HomeScreen(),
    BusinessIdeaGenerationScreen(),
    SaveItemScreen(),
  ];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.read<ProfileProvider>();
    final theme = Theme.of(context);
    return Consumer<BottomNavBarProvider>(
      builder: (context, bottomNav, _) {
        return PopScope(
          canPop: bottomNav.currentIndex == 0,
          onPopInvoked: (didPop) {
            if (didPop) return;
            if (bottomNav.currentIndex != 0) {
              bottomNav.setIndex(0);
            }
          },
          child: Scaffold(
            key: _scaffoldKey,
            drawer: const SideDrawer(),
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
              ),
              title: RichText(
                textAlign: TextAlign.start,
                text: TextSpan(
                  text: "Hello ",
                  style: theme.textTheme.headlineSmall,
                  children: [
                    TextSpan(
                      text:
                          "${profileProvider.userProfile?.name?.split(" ").first ?? ''}!",
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              titleSpacing: SizeConfig.width(0),
              centerTitle: false,
            ),
            body: Column(
              children: [
                Consumer<ConnectivityProvider>(
                  builder: (context, connectivity, _) {
                    if (!connectivity.isOffline) {
                      return const SizedBox.shrink();
                    }
                    return const OfflineBanner();
                  },
                ),
                Expanded(child: tabs[bottomNav.currentIndex]),
              ],
            ),
            bottomNavigationBar: CustomBottomNavBar(
              currentIndex: bottomNav.currentIndex,
              navItems: _navItems,
              onTap: (index) {
                if (index == bottomNav.currentIndex) return;
                // Leaving a tab dismisses any in-flight analysis stream.
                context.read<LocationProvider>().cancelStream();
                context.read<BusinessIdeaProvider>().cancelStream();
                bottomNav.setIndex(index);
              },
            ),
          ),
        );
      },
    );
  }
}
