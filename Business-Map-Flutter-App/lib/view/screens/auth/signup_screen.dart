import 'package:business_map/provider/input_options/input_options_provider.dart';
import 'package:business_map/provider/profile/profile_provider.dart';
import 'package:business_map/utils/app_text_style.dart';
import 'package:business_map/utils/images.dart';
import 'package:business_map/core/routes/routes_name.dart';
import 'package:business_map/utils/size_config.dart';
import 'package:business_map/view/custom_widgets/button/app_primary_button.dart';
import 'package:business_map/view/custom_widgets/button/social_auth_button.dart';
import 'package:business_map/view/custom_widgets/sections/auth_header.dart';
import 'package:business_map/view/custom_widgets/sections/password_validation_view.dart';
import 'package:business_map/view/custom_widgets/snack_bar/custom_snackbar.dart';
import 'package:business_map/view/custom_widgets/text/section_label.dart';
import 'package:business_map/view/custom_widgets/textfield/custom_textfield.dart';
import 'package:business_map/view/screens/screens.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../provider/auth/auth_provider.dart';

class SignUpScreen extends StatefulWidget {
  SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool _has8Char = false;
  bool _hasUpper = false;
  bool _hasLower = false;
  bool _hasSpecial = false;
  bool _showPasswordRequirements = false;

  static final _upperRegex = RegExp(r'[A-Z]');
  static final _lowerRegex = RegExp(r'[a-z]');
  static final _specialRegex = RegExp(r'[!@#$%^&*(),.?":{}|<>]');

  void _updatePasswordFlags(String value) {
    bool n8Char = value.length >= 8;
    bool nUpper = _upperRegex.hasMatch(value);
    bool nLower = _lowerRegex.hasMatch(value);
    bool nSpecial = _specialRegex.hasMatch(value);

    if (n8Char != _has8Char ||
        nUpper != _hasUpper ||
        nLower != _hasLower ||
        nSpecial != _hasSpecial) {
      setState(() {
        _has8Char = n8Char;
        _hasUpper = nUpper;
        _hasLower = nLower;
        _hasSpecial = nSpecial;
      });
    }
  }

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(toolbarHeight: SizeConfig.height(35)),
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
                        const AuthHeader(title: "Sign Up"),
                      ],
                    ),

                    SizedBox(height: SizeConfig.height(35)),


                    const SectionLabel(label: "Name"),
                    CustomTextField(
                      controller: nameController,
                      hintText: "John Doe",
                      keyboardType: TextInputType.name,
                      leadingIcon: Icons.person_outline,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Name cannot be empty";
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: SizeConfig.height(20)),

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
                      textInputAction: TextInputAction.next,
                      onChanged: _updatePasswordFlags,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Password cannot be empty";
                        }
                        if (!_has8Char ||
                            !_hasUpper ||
                            !_hasLower ||
                            !_hasSpecial) {
                          return "Password does not meet the requirements below";
                        }
                        return null;
                      },
                    ),

                    PasswordValidationView(
                      has8Char: _has8Char,
                      hasUpperAndLower: _hasUpper && _hasLower,
                      hasSpecialChar: _hasSpecial,
                      isVisible: _showPasswordRequirements && passwordController.text.isNotEmpty,
                    ),

                    SizedBox(height: SizeConfig.height(20)),

                    const SectionLabel(label: "Confirm Password"),
                    CustomTextField(
                      controller: confirmPasswordController,
                      hintText: "Re-enter your password",
                      leadingIcon: Icons.lock_outline,
                      isPassword: true,
                      textInputAction: TextInputAction.done,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Confirm password cannot be empty";
                        }
                        if (value != passwordController.text) {
                          return "Passwords do not match";
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: SizeConfig.height(20)),

                    FormField<bool>(
                      initialValue: context.read<AuthProvider>().isAccepted,
                      validator: (value) {
                        if (value != true) {
                          return 'You must accept the Privacy Policy';
                        }
                        return null;
                      },
                      builder: (state) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Consumer<AuthProvider>(
                                  builder: (context, provider, _) {
                                    return Checkbox(
                                      value: provider.isAccepted,
                                      onChanged: (val) {
                                        provider.setAccepted(val ?? false);
                                        state.didChange(val);
                                      },
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      visualDensity: VisualDensity.compact,
                                      side: MaterialStateBorderSide.resolveWith(
                                        (states) {
                                          return BorderSide(
                                            color: states.contains(
                                              MaterialState.selected,
                                            )
                                                ? Theme.of(context).primaryColor
                                                : Colors.grey,
                                            width: 2,
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(width: SizeConfig.width(10)),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      text: "By continuing, I agree to ",
                                      style: AppTextStyles.signupPrompt(
                                        context,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: "Privacy Policy",
                                          style: AppTextStyles.signupPrompt(
                                            context,
                                          ).copyWith(color: theme.primaryColor),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              Navigator.pushNamed(context,
                                                  RoutesName.privacyPolicyScreen);
                                            },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (state.hasError)
                              Padding(
                                padding: const EdgeInsets.only(left: 12, top: 5),
                                child: Text(
                                  state.errorText ?? '',
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),

                    SizedBox(height: SizeConfig.height(10)),

                    Consumer<AuthProvider>(
                      builder: (context, authProvider, _) {
                        return AppPrimaryButton(
                          text: "Signup",
                          onPressed: () async {
                            if (_formKey.currentState?.validate() ?? false) {
                              final success = await authProvider.signup(
                                nameController.text.trim(),
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
                                      authProvider.errorMsg ?? 'Signup Failed',
                                  isError: true,
                                );
                              }
                            } else {
                              if (passwordController.text.isNotEmpty) {
                                setState(() {
                                  _showPasswordRequirements = true;
                                });
                              }
                            }
                          },
                          isLoading: authProvider.isLoading &&
                              authProvider.loadingFor == AuthLoadingFor.signup,
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

                    Center(
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            "Already have an account? ",
                            style: AppTextStyles.signupPrompt(context),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                RoutesName.loginScreen,
                                (route) => false,
                              );
                            },
                            child: Text(
                              "Login",
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

      Navigator.pushNamed(
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
          message: authProvider.errorMsg ?? "Login failed",
          isError: true,
        );
      }
    }
  }
}
