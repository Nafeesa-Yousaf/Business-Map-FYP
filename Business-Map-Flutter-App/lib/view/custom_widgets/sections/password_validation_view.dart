import 'package:business_map/utils/size_config.dart';
import 'package:flutter/material.dart';

class PasswordValidationView extends StatelessWidget {
  final bool has8Char;
  final bool hasUpperAndLower;
  final bool hasSpecialChar;
  final bool isVisible;

  const PasswordValidationView({
    super.key,
    required this.has8Char,
    required this.hasUpperAndLower,
    required this.hasSpecialChar,
    this.isVisible = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(left: SizeConfig.width(4), top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!has8Char || !hasUpperAndLower || !hasSpecialChar)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                "Password must contain:",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          _buildRequirementRow("At least 8 characters", has8Char),
          _buildRequirementRow("Alphabets (A-Z) and (a-z)", hasUpperAndLower),
          _buildRequirementRow("One special character (!@#\$)", hasSpecialChar),
        ],
      ),
    );
  }

  Widget _buildRequirementRow(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle_rounded : Icons.cancel_rounded,
            size: 14,
            color: isMet ? Colors.grey : Colors.red,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: isMet ? Colors.grey : Colors.red,
              fontWeight: isMet ? FontWeight.normal : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
