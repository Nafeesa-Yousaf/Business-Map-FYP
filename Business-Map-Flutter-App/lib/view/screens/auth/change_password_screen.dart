import 'package:business_map/provider/auth/auth_provider.dart';
import 'package:business_map/view/custom_widgets/button/app_primary_button.dart';
import 'package:business_map/view/custom_widgets/sections/password_validation_view.dart';
import 'package:business_map/view/custom_widgets/snack_bar/custom_snackbar.dart';
import 'package:business_map/view/custom_widgets/text/section_label.dart';
import 'package:flutter/material.dart';
import 'package:business_map/utils/app_text_style.dart';
import 'package:business_map/utils/size_config.dart';
import 'package:business_map/view/custom_widgets/textfield/custom_textfield.dart';
import 'package:provider/provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

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

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Change Password"),
      ),
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
                    Container(
                      padding: EdgeInsets.all(SizeConfig.width(24)),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.primary.withOpacity(0.1),
                      ),
                      child: Icon(
                        Icons.lock_reset,
                        size: SizeConfig.width(60),
                        color: theme.colorScheme.primary,
                      ),
                    ),

                    SizedBox(height: SizeConfig.height(35)),


                    const SectionLabel(label: "Current Password"),
                    CustomTextField(
                      controller: _currentPasswordController,
                      hintText: "Enter Current Password",
                      isPassword: true,
                      textInputAction: TextInputAction.done,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Current password cannot be empty";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: SizeConfig.height(20)),
                    
                    const SectionLabel(label: "New Password"),
                    CustomTextField(
                      controller: _newPasswordController,
                      hintText: "Enter new Password",
                      isPassword: true,
                      textInputAction: TextInputAction.done,
                      onChanged: _updatePasswordFlags,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "New Password cannot be empty";
                        }
                        if (value == _currentPasswordController.text) {
                          return "Current and New Password cannot be same";
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
                      isVisible: _showPasswordRequirements && _newPasswordController.text.isNotEmpty,
                    ),

                    SizedBox(height: SizeConfig.height(20)),

                    const SectionLabel(label: "Confirm Password"),
                    CustomTextField(
                      controller: _confirmPasswordController,
                      hintText: "Re-enter New Password",
                      isPassword: true,
                      textInputAction: TextInputAction.done,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Confirm password cannot be empty";
                        }
                        if (value != _newPasswordController.text) {
                          return "Passwords do not match";
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
                            text: "Change Password",
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                final success = await authProvider.changePassword(
                                  _currentPasswordController.text,
                                  _newPasswordController.text,
                                );

                                if (success == true) {
                                  final messenger = ScaffoldMessenger.of(context);
                                  if (!mounted) return;
                                  Navigator.pop(context);
                                  CustomSnackbar.show(
                                    context: context,
                                    message: "Password Successfully Changed",
                                    isError: false,
                                    messenger: messenger,
                                  );
                                } else if (success == false) {
                                  CustomSnackbar.show(
                                    context: context,
                                    message: authProvider.errorMsg ?? "Change Password Failed",
                                    isError: true,
                                  );
                                }
                              } else {
                                if (_newPasswordController.text.isNotEmpty) {
                                  setState(() {
                                    _showPasswordRequirements = true;
                                  });
                                }
                              }
                            },
                            isLoading: authProvider.isLoading &&
                                authProvider.loadingFor == AuthLoadingFor.changePassword,
                          ),
                        );
                      },
                    )
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
