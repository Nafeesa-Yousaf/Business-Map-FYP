import 'package:business_map/provider/auth/auth_provider.dart';
import 'package:business_map/provider/dashboard/bottom_nav_bar_provider.dart';
import 'package:business_map/provider/profile/profile_provider.dart';
import 'package:business_map/utils/app_colors.dart';
import 'package:business_map/core/routes/routes_name.dart';
import 'package:business_map/utils/size_config.dart';
import 'package:business_map/view/custom_widgets/dialog/custom_primary_dialog.dart';
import 'package:business_map/view/custom_widgets/shimmer/custom_shimmer.dart';
import 'package:business_map/view/custom_widgets/snack_bar/custom_snackbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SideDrawer extends StatelessWidget {
  const SideDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: SizeConfig.width(20)),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: SizeConfig.height(20)),
            Consumer<ProfileProvider>(
              builder: (context, profileProvider, _) {
                final user = profileProvider.userProfile;

                return Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.2),
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        backgroundColor: theme.colorScheme.surface,
                        radius: SizeConfig.width(40),
                        child: ClipOval(
                          child: (user?.imageUrl != null &&
                                  user!.imageUrl!.isNotEmpty)
                              ? CachedNetworkImage(
                                  imageUrl: user.imageUrl!,
                                  fit: BoxFit.cover,
                                  width: SizeConfig.width(80),
                                  height: SizeConfig.width(80),
                                  placeholder: (context, url) => CustomShimmer(
                                    height: SizeConfig.width(80),
                                    width: SizeConfig.width(80),
                                    borderRadius: BorderRadius.circular(54),
                                  ),
                                  errorWidget: (context, url, error) => Icon(
                                    Icons.person,
                                    color: theme.colorScheme.primary.withOpacity(0.5),
                                    size: SizeConfig.width(40),
                                  ),
                                )
                              : Icon(
                                  Icons.person,
                                  color: theme.colorScheme.primary.withOpacity(0.5),
                                  size: SizeConfig.width(40),
                                ),
                        ),
                      ),
                    ),
                    SizedBox(width: SizeConfig.width(16)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? "User",
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: SizeConfig.height(4)),
                          Text(
                            user?.email ?? "",
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: SizeConfig.height(21)),
            Divider(
              height: 1,
              thickness: 1,
              color: theme.dividerColor.withOpacity(0.1),
              indent: 0,
              endIndent: 0,
            ),
            SizedBox(height: SizeConfig.height(21)),
            _buildMenuItem(
              context,
              icon: Icons.edit,
              label: "Edit Profile",
              onTap: () {
                Navigator.pushNamed(context, RoutesName.profileScreen);
              },
            ),
            if (!context.watch<AuthProvider>().isGoogleUser) ...[
              SizedBox(height: SizeConfig.height(21)),
              _buildMenuItem(
                context,
                icon: Icons.change_circle_outlined,
                label: "Change Password",
                onTap: () {
                  Navigator.pushNamed(context, RoutesName.changePasswordScreen);
                },
              ),
            ],
            SizedBox(height: SizeConfig.height(21)),
            _buildMenuItem(
              context,
              icon: Icons.info_outline,
              label: "About Us",
              onTap: () {
                Navigator.pushNamed(context, RoutesName.aboutUsScreen);
              },
            ),
            SizedBox(height: SizeConfig.height(21)),
            _buildMenuItem(
              context,
              icon: Icons.privacy_tip_outlined,
              label: "Privacy Policy",
              onTap: () {
                Navigator.pushNamed(context, RoutesName.privacyPolicyScreen);
              },
            ),
            SizedBox(height: SizeConfig.height(21)),
            _buildMenuItem(
              context,
              icon: Icons.logout,
              label: "Logout",
              onTap: () async {
                await _logout(context);
              },
            ),
            SizedBox(height: SizeConfig.height(21)),
            _buildMenuItem(
              context,
              icon: Icons.delete_outlined,
              label: "Delete Account",
              onTap: () {
                Navigator.pushNamed(context, RoutesName.deleteAccountScreen);
              },
            ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SizeConfig.radius(12)),
        child: Container(
          margin: EdgeInsets.symmetric(
            vertical: SizeConfig.height(4),
            horizontal: SizeConfig.width(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: SizeConfig.width(20),
                backgroundColor: theme.colorScheme.primary,
                child: Icon(
                  icon,
                  size: SizeConfig.icon(24),
                  color: AppColors.pureWhite,
                ),
              ),
              SizedBox(width: SizeConfig.width(16)),
              Text(label, style: theme.textTheme.titleSmall),
            ],
          ),
        ),
      ),
    );
  }

  _logout(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return CustomPrimaryDialog(
          title: "Confirm Logout",
          content: "Are you sure you want to log out from your account?",
          primaryButtonText: "Log Out",
          primaryButtonCallBack: () async {
            final authProvider = context.read<AuthProvider>();
            final success = await authProvider.logout();

            if (success == true) {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                context,
                RoutesName.loginScreen,
                (route) => false,
              );
              context.read<BottomNavBarProvider>().setIndex(0);
            } else {
              Navigator.pop(context); // close dialog
              CustomSnackbar.show(
                context: context,
                message: authProvider.errorMsg ?? "Logout Failed",
                isError: true,
              );
            }
          },
          secondaryButtonText: "Cancel",
          secondaryCallBack: () {
            Navigator.pop(context);
          },
        );
      },
    );
  }
}
