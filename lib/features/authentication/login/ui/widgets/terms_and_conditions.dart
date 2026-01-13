import 'package:flutter/material.dart';

// Global styles not directly used; relying on AuthTextStyles
import '../../../../../core/theming/auth_styles.dart';

class TermsAndConditionsText extends StatelessWidget {
  const TermsAndConditionsText({super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: [
          TextSpan(
            text: 'By logging, you agree to our',
            style: AuthTextStyles.termsGray,
          ),
          TextSpan(
            text: ' Terms & Conditions',
            style: AuthTextStyles.termsLink,
          ),
          TextSpan(text: ' and', style: AuthTextStyles.termsGray),
          TextSpan(text: ' Privacy Policy', style: AuthTextStyles.termsLink),
        ],
      ),
    );
  }
}
