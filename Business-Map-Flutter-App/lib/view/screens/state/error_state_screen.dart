import 'package:business_map/utils/app_colors.dart';
import 'package:business_map/utils/app_text_style.dart';
import 'package:business_map/utils/size_config.dart';
import 'package:business_map/view/custom_widgets/button/app_primary_button.dart';
import 'package:flutter/material.dart';

enum ErrorType { noInternet, apiError }

class ErrorStateScreen extends StatefulWidget {
  final ErrorType errorType;
  final String? title;
  final String? message;
  final Future<void> Function(BuildContext context) onRetry;

  const ErrorStateScreen({
    super.key,
    required this.errorType,
    this.title,
    this.message,
    required this.onRetry,
  });

  @override
  State<ErrorStateScreen> createState() => _ErrorStateScreenState();
}

class _ErrorStateScreenState extends State<ErrorStateScreen> {
  bool _isLoading = false;
  late ErrorType _currentErrorType;
  String? _currentTitle;
  String? _currentMessage;

  @override
  void initState() {
    super.initState();
    _currentErrorType = widget.errorType;
    _currentTitle = widget.title;
    _currentMessage = widget.message;
  }

  Future<void> _handleRetry() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await widget.onRetry(context);
    } catch (e) {
      if (mounted) {
        setState(() {
          if (e.toString().toLowerCase().contains('socket') ||
              e.toString().toLowerCase().contains('network') ||
              e.toString().toLowerCase().contains('connection')) {
            _currentErrorType = ErrorType.noInternet;
          } else {
            _currentErrorType = ErrorType.apiError;
          }
          _currentMessage = e.toString().replaceFirst('Exception: ', '');
          _currentTitle = "Retry Failed";
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    String displayTitle = _currentTitle ??
        (_currentErrorType == ErrorType.noInternet
            ? "No Connection"
            : "Sync Interrupted");

    String displayMessage = _currentMessage ??
        (_currentErrorType == ErrorType.noInternet
            ? "Please check your internet connection and try again to fetch data."
            : "Our servers are experiencing issues. Please try again later.");

    IconData errorIcon = _currentErrorType == ErrorType.noInternet
        ? Icons.wifi_off_rounded
        : Icons.cloud_off_rounded;

    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: SizeConfig.width(30)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(SizeConfig.width(30)),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                errorIcon,
                size: SizeConfig.width(80),
                color: theme.primaryColor,
              ),
            ),
            SizedBox(height: SizeConfig.height(40)),

            Text(
              displayTitle,
              style: AppTextStyles.headingLarge(context).copyWith(
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: SizeConfig.height(16)),
            Text(
              displayMessage,
              style: AppTextStyles.bodyMedium(context).copyWith(
                color: AppColors.iconColor,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: SizeConfig.height(60)),

            AppPrimaryButton(
              text: "Retry Now",
              onPressed: _handleRetry,
              isLoading: _isLoading,
              width: SizeConfig.width(200),
            ),
          ],
        ),
      ),
    );
  }
}
