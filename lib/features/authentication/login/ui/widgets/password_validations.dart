import 'package:flutter/material.dart';
import '../../../../../core/theming/colors.dart';
import '../../../../../core/theming/auth_styles.dart';

class PasswordValidations extends StatelessWidget {
  final bool hasLowerCase;
  final bool hasUpperCase;
  final bool hasSpecialCharacters;
  final bool hasNumber;
  final bool hasMinLength;
  const PasswordValidations({
    super.key,
    required this.hasLowerCase,
    required this.hasUpperCase,
    required this.hasSpecialCharacters,
    required this.hasNumber,
    required this.hasMinLength,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildValidationRow('At least 1 lowercase letter', hasLowerCase),
        SizedBox(height: 2),
        buildValidationRow('At least 1 uppercase letter', hasUpperCase),
        SizedBox(height: 2),
        buildValidationRow(
          'At least 1 special character',
          hasSpecialCharacters,
        ),
        SizedBox(height: 2),
        buildValidationRow('At least 1 number', hasNumber),
        SizedBox(height: 2),
        buildValidationRow('At least 8 characters long', hasMinLength),
      ],
    );
  }

  Widget buildValidationRow(String text, bool hasValidated) {
    return Row(
      children: [
        const CircleAvatar(radius: 2.5, backgroundColor: ColorsManager.gray),
        SizedBox(width: 6),
        Text(
          text,
          style: AuthTextStyles.validationText(validated: hasValidated).copyWith(
            decoration: hasValidated ? TextDecoration.lineThrough : null,
            decorationColor: ColorsManager.success,
            decorationThickness: 2,
          ),
        ),
      ],
    );
  }
}
