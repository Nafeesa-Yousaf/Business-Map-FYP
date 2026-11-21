import 'package:business_map/utils/app_text_style.dart';
import 'package:business_map/utils/images.dart';
import 'package:business_map/utils/size_config.dart';
import 'package:business_map/view/custom_widgets/button/app_primary_button.dart';
import 'package:business_map/view/custom_widgets/sections/auth_header.dart';
import 'package:business_map/view/custom_widgets/snack_bar/custom_snackbar.dart';
import 'package:business_map/view/custom_widgets/text/section_label.dart';
import 'package:business_map/view/custom_widgets/textfield/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../provider/auth/auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const AuthHeader(
                      title: "Forgot Password",
                      subtitle:
                          "Enter your email address below. We’ll send you a link to reset your password.",
                    ),

                    SizedBox(height: SizeConfig.height(35)),

                    const SectionLabel(label: "Email"),
                    CustomTextField(
                      controller: emailController,
                      hintText: "john@example.com",
                      keyboardType: TextInputType.emailAddress,
                      leadingIcon: Icons.email_outlined,
                      textInputAction: TextInputAction.done,
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

                    SizedBox(height: SizeConfig.height(30)),

                    Consumer<AuthProvider>(
                      builder: (context, authProvider, _) {
                        return SizedBox(
                          width: double.infinity,
                          child: AppPrimaryButton(
                            text: "Send Reset Link",
                            onPressed: () async {
                              if (_formKey.currentState?.validate() ?? false) {
                                final success = await authProvider
                                    .sendResetLink(emailController.text.trim());

                                if (success == true) {
                                  CustomSnackbar.show(
                                    context: context,
                                    message:
                                        "Password reset link sent! Please check your email.",
                                    isError: false,
                                  );
                                  Navigator.pop(context);
                                } else if (success == false) {
                                  CustomSnackbar.show(
                                    context: context,
                                    message:
                                        authProvider.errorMsg ??
                                        "Unexpected error occurred.",
                                    isError: true,
                                  );
                                }
                              }
                            },
                            isLoading:
                                authProvider.isLoading &&
                                authProvider.loadingFor ==
                                    AuthLoadingFor.resetPassword,
                          ),
                        );
                      },
                    ),

                    SizedBox(height: SizeConfig.height(30)),

                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          "Remember your password? ",
                          style: AppTextStyles.signupPrompt(context),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
