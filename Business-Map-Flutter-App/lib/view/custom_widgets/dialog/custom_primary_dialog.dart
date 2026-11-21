import 'package:business_map/utils/app_colors.dart';
import 'package:business_map/utils/size_config.dart';
import 'package:flutter/material.dart';

class CustomPrimaryDialog extends StatefulWidget {
  final String title;
  final String content;
  final String? secondaryButtonText;
  final VoidCallback? secondaryCallBack;
  final String primaryButtonText;
  final VoidCallback primaryButtonCallBack;
  final Color? primaryButtonColor;
  final bool isVertical;
  final bool showTextField;
  final TextEditingController? textFieldController;
  final String? hintText;
  final String? defaultValue;
  final int? maxLines;
  final int? minLines;
  final bool isPrimaryLoading;
  final String? Function(String?)? validator;

  CustomPrimaryDialog({
    super.key,
    required this.title,
    required this.content,
    this.secondaryButtonText,
    this.secondaryCallBack,
    required this.primaryButtonText,
    required this.primaryButtonCallBack,
    this.primaryButtonColor,
    this.isVertical = false,
    this.showTextField = false,
    this.textFieldController,
    this.hintText,
    this.defaultValue,
    this.maxLines = 1,
    this.minLines,
    this.isPrimaryLoading = false,
    this.validator,
  });

  @override
  State<CustomPrimaryDialog> createState() => _CustomPrimaryDialogState();
}

class _CustomPrimaryDialogState extends State<CustomPrimaryDialog> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    final controller = widget.textFieldController ?? TextEditingController();
    if (widget.defaultValue != null && controller.text.isEmpty) {
      controller.text = widget.defaultValue!;
    }

    Widget primaryButton() {
      return ElevatedButton(
        onPressed: widget.isPrimaryLoading
            ? () {}
            : () {
                if (_formKey.currentState?.validate() ?? true) {
                  widget.primaryButtonCallBack();
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.primaryButtonColor ?? theme.primaryColor,
          foregroundColor: AppColors.pureWhite,
          padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.width(5),
            vertical: SizeConfig.height(5),
          ),
        ),
        child: widget.isPrimaryLoading
            ? SizedBox(
                width: SizeConfig.width(15),
                height: SizeConfig.width(15),
                child: CircularProgressIndicator(
                  color: AppColors.pureWhite,
                  strokeWidth: 1.0,
                ),
              )
            : Text(
                widget.primaryButtonText,
                style: theme.textTheme.bodyMedium!.copyWith(
                  color: AppColors.pureWhite,
                ),
              ),
      );
    }

    Widget secondaryButton() {
      if (widget.secondaryButtonText == null || widget.secondaryCallBack == null) {
        return SizedBox.shrink();
      }
      return ElevatedButton(
        onPressed: widget.secondaryCallBack,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.colorOnDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SizeConfig.radius(12)),
            side: BorderSide(color: widget.primaryButtonColor ?? theme.primaryColor),
          ),
          foregroundColor: widget.primaryButtonColor ?? theme.primaryColor,
          padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.width(5),
            vertical: SizeConfig.height(5),
          ),
        ),
        child: Text(
          widget.secondaryButtonText!,
          style: theme.textTheme.bodyMedium!.copyWith(
            color: widget.primaryButtonColor ?? theme.primaryColor,
          ),
        ),
      );
    }

    return AlertDialog(
      title: Text(widget.title, style: theme.textTheme.titleMedium),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.content),
            if (widget.showTextField) ...[
              SizedBox(height: SizeConfig.height(10)),
              TextFormField(
                controller: controller,
                maxLines: widget.maxLines,
                minLines: widget.minLines,
                decoration: InputDecoration(hintText: widget.hintText ?? "Enter here"),
                validator:
                    widget.validator ??
                    (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "This field cannot be empty";
                      }
                      if (value == widget.defaultValue) {
                        return "New name must be different from the current name.";
                      }
                      return null;
                    },
              ),
            ],
          ],
        ),
      ),
      actions: [
        if (widget.isVertical) ...[
          Column(
            children: [
              SizedBox(width: double.infinity, child: primaryButton()),
              if (widget.secondaryButtonText != null && widget.secondaryCallBack != null)
                SizedBox(height: SizeConfig.height(2)),
              if (widget.secondaryButtonText != null && widget.secondaryCallBack != null)
                SizedBox(width: double.infinity, child: secondaryButton()),
            ],
          ),
        ] else ...[
          Row(
            children: [
              if (widget.secondaryButtonText != null && widget.secondaryCallBack != null)
                Expanded(child: secondaryButton()),
              if (widget.secondaryButtonText != null && widget.secondaryCallBack != null)
                SizedBox(width: SizeConfig.width(10)),
              Expanded(child: primaryButton()),
            ],
          ),
        ],
      ],
    );
  }
}
