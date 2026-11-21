import 'package:business_map/provider/input_options/input_options_provider.dart';
import 'package:business_map/provider/profile/profile_provider.dart';
import 'package:business_map/utils/app_text_style.dart';
import 'package:business_map/utils/images.dart';
import 'package:business_map/core/routes/routes_name.dart';
import 'package:business_map/utils/size_config.dart';
import 'package:business_map/view/custom_widgets/button/AppTextButton.dart';
import 'package:business_map/view/custom_widgets/button/app_primary_button.dart';
import 'package:business_map/view/custom_widgets/button/social_auth_button.dart';
import 'package:business_map/view/custom_widgets/sections/auth_header.dart';
import 'package:business_map/view/custom_widgets/snack_bar/custom_snackbar.dart';
import 'package:business_map/view/custom_widgets/text/section_label.dart';
import 'package:business_map/view/custom_widgets/textfield/custom_textfield.dart';
import 'package:business_map/view/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../provider/auth/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          height: SizeConfig.screenHeight - MediaQuery.of(context).padding.top,
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.width(20),
                vertical: SizeConfig.height(20),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const AuthHeader(title: "Login"),
                      ],
                    ),

                    SizedBox(height: SizeConfig.height(35)),


                    const SectionLabel(label: "Email"),
                    CustomTextField(
                      controller: emailController,
                      hintText: "john@example.com",
                      keyboardType: TextInputType.emailAddress,
                      leadingIcon: Icons.email_outlined,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Email cannot be empty";
                        }
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$',
                        ).hasMatch(value)) {
                          return "Enter a valid email";
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: SizeConfig.height(20)),

                    const SectionLabel(label: "Password"),
                    CustomTextField(
                      controller: passwordController,
                      hintText: "Enter your password",
                      leadingIcon: Icons.lock_outline,
                      isPassword: true,
                      textInputAction: TextInputAction.done,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Password cannot be empty";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: SizeConfig.height(10)),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AppTextButton(
                          text: "Forgot Password?",
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              RoutesName.forgotPasswordScreen,
                            );
                          },
                        )
                      ],
                    ),

                    SizedBox(height: SizeConfig.height(30)),

                    Consumer<AuthProvider>(
                      builder: (context, authProvider, _) {
                        return SizedBox(
                          width: double.infinity,
                          child: AppPrimaryButton(
                            text: "Login",
                            onPressed: () async {
                              if (_formKey.currentState?.validate() ?? false) {
                                final success = await authProvider.login(
                                  emailController.text.trim(),
                                  passwordController.text.trim(),
                                );

                                if (success == true) {
                                  if (!mounted) return;
                                  _fetchInitialData(context);
                                } else if (success == false) {
                                  CustomSnackbar.show(
                                    context: context,
                                    message:
                                        authProvider.errorMsg ?? "Login failed",
                                    isError: true,
                                  );
                                }
                              }
                            },
                            isLoading: authProvider.isLoading &&
                                authProvider.loadingFor == AuthLoadingFor.login,
                          ),
                        );
                      },
                    ),

                    SizedBox(height: SizeConfig.height(30)),

                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: SizeConfig.width(3),
                          ),
                          child: Text(
                            "OR",
                            style: AppTextStyles.dividerLabel(context),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            thickness: 1,
                            color: theme.dividerColor.withOpacity(0.3),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: SizeConfig.height(30)),


                    Consumer<AuthProvider>(
                      builder: (context, authProvider, _) {
                        bool isGoogleLoading = authProvider.isLoading && 
                            authProvider.loadingFor == AuthLoadingFor.googleAuth;

                        return SocialAuthButton(
                          text: "Continue with Google",
                          iconPath: Images.googleIcon,
                          onTap: () => _handleGoogleAuth(authProvider),
                          isLoading: isGoogleLoading,
                        );
                      },
                    ),

                    SizedBox(height: SizeConfig.height(30)),

                    /// Sign up
                    Center(
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 0,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: AppTextStyles.signupPrompt(context),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                RoutesName.signupScreen,
                              );
                            },
                            child: Text(
                              "Sign up",
                              style: AppTextStyles.signupPrompt(
                                context,
                              ).copyWith(color: theme.primaryColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _fetchInitialData(BuildContext context,
      {bool isRetry = false}) async {
    final profileProvider = context.read<ProfileProvider>();
    final inputOptionsProvider = context.read<InputOptionsProvider>();

    try {
      await Future.wait([
        profileProvider.fetchUserData(),
        inputOptionsProvider.fetchAllHomeData(),
      ]);

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        RoutesName.dashboard,
            (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
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
            await _fetchInitialData(ctx, isRetry: true);
          }
        },
      );
    }
  }

  Future<void> _handleGoogleAuth(AuthProvider authProvider) async {
    bool success = await authProvider.googleAuth();
    if (success) {
      if (mounted) {
        await _fetchInitialData(context);
      }
    } else {
      if (authProvider.errorMsg?.trim() != "") {
        CustomSnackbar.show(
          context: context,
          message:
          authProvider.errorMsg ?? "Login failed",
          isError: true,
        );
      }
    }
  }
}
