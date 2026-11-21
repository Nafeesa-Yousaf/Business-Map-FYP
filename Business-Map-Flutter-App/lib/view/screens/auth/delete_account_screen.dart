import 'package:business_map/provider/auth/auth_provider.dart';
import 'package:business_map/provider/dashboard/bottom_nav_bar_provider.dart';
import 'package:business_map/utils/app_text_style.dart';
import 'package:business_map/core/routes/routes_name.dart';
import 'package:business_map/utils/size_config.dart';
import 'package:business_map/view/custom_widgets/button/app_primary_button.dart';
import 'package:business_map/view/custom_widgets/dialog/custom_primary_dialog.dart';
import 'package:business_map/view/custom_widgets/snack_bar/custom_snackbar.dart';
import 'package:business_map/view/custom_widgets/textfield/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final TextEditingController _currentPasswordController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isConfirmed = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _currentPasswordController.clear();
    _currentPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();
    final isGoogleUser = authProvider.isGoogleUser;
    final isBusy = _isSubmitting ||
        (authProvider.isLoading &&
            authProvider.loadingFor == AuthLoadingFor.deleteAccount);

    return Scaffold(
      appBar: AppBar(title: const Text("Delete Account")),
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
                        Icons.delete_outlined,
                        size: SizeConfig.width(60),
                        color: theme.colorScheme.primary,
                      ),
                    ),

                    SizedBox(height: SizeConfig.height(35)),

                    if (!isGoogleUser) ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Enter Password",
                          style: AppTextStyles.formLabel(context),
                        ),
                      ),
                      SizedBox(height: SizeConfig.height(8)),
                      CustomTextField(
                        controller: _currentPasswordController,
                        hintText: "Enter Password",
                        isPassword: true,
                        textInputAction: TextInputAction.done,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Password is required to delete account";
                          }
                          return null;
                        },
                      ),
                    ] else ...[
                      Text(
                        "You will be asked to confirm with Google before your account is deleted.",
                        style: AppTextStyles.tagline(context),
                        textAlign: TextAlign.center,
                      ),
                    ],

                    SizedBox(height: SizeConfig.height(30)),
                    Text(
                      "Deleting your account will erase all your saved data and settings. You will no longer be able to access your business suggestions or preferences.",
                      style: AppTextStyles.tagline(context),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: SizeConfig.height(20)),

                    Row(
                      children: [
                        Checkbox(
                          activeColor: Colors.red,
                          value: _isConfirmed,
                          onChanged: isBusy
                              ? null
                              : (value) {
                                  setState(() {
                                    _isConfirmed = value ?? false;
                                  });
                                },
                        ),
                        Expanded(
                          child: Text(
                            "I understand that this action is permanent and cannot be undone.",
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: SizeConfig.height(20)),

                    AppPrimaryButton(
                      text: "Delete Account",
                      buttonColor: Colors.red,
                      isLoading: isBusy,
                      isDisabled: !_isConfirmed || isBusy,
                      onPressed: () {
                        if (!_isConfirmed || isBusy) return;
                        if (!isGoogleUser) {
                          if (!_formKey.currentState!.validate()) return;
                        }
                        _confirmDelete(context);
                      },
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

  void _confirmDelete(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final isGoogleUser = authProvider.isGoogleUser;
    final password = _currentPasswordController.text.trim();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => CustomPrimaryDialog(
        title: "Delete Account?",
        content:
            "Are you sure you want to delete your account permanently? This action cannot be undone.",
        primaryButtonText: "Delete",
        primaryButtonCallBack: () async {
          Navigator.pop(dialogContext);
          await _performDelete(
            authProvider: authProvider,
            password: isGoogleUser ? null : password,
          );
        },
        secondaryButtonText: "Cancel",
        secondaryCallBack: () => Navigator.pop(dialogContext),
      ),
    );
  }

  Future<void> _performDelete({
    required AuthProvider authProvider,
    required String? password,
  }) async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    try {
      final success = await authProvider.deleteAccount(password: password);
      _currentPasswordController.clear();

      if (!mounted) return;

      if (success) {
        try {
          context.read<BottomNavBarProvider>().setIndex(0);
        } catch (_) {}
        Navigator.of(context).pushNamedAndRemoveUntil(
          RoutesName.loginScreen,
          (route) => false,
        );
      } else {
        CustomSnackbar.show(
          context: context,
          message: authProvider.errorMsg ?? "Deletion failed",
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
