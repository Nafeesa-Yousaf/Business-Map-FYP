import 'package:business_map/utils/size_config.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String? hintText;
  final IconData? leadingIcon;
  final bool isPassword;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Color? fillColor;
  final int? maxLines;
  final bool isReadOnly;
  final void Function(String)? onChanged;

  const CustomTextField({
    super.key,
    required this.controller,
    this.hintText,
    this.leadingIcon,
    this.isPassword = false,
    this.focusNode,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.fillColor,
    this.maxLines = 1,
    this.isReadOnly=false,
    this.onChanged,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      obscureText: widget.isPassword ? _obscureText : false,
      readOnly: widget.isReadOnly,
      validator: widget.validator,
      onChanged: widget.onChanged,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      maxLines: widget.isPassword ? 1 : widget.maxLines,
      decoration: InputDecoration(
        hintText: widget.hintText ?? '',
        fillColor: widget.fillColor??theme.inputDecorationTheme.fillColor,
        prefixIcon: widget.leadingIcon != null
            ? Icon(
          widget.leadingIcon,
          size: theme.iconTheme.size,
          color: theme.iconTheme.color,
        )
            : null,
        suffixIcon: widget.isPassword
            ? IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            size: theme.iconTheme.size,
            color: theme.iconTheme.color,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SizeConfig.radius(10)),
        ),
      ),
    );
  }
}
