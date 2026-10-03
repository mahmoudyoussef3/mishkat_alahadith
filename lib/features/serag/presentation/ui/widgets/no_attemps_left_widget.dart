import 'package:flutter/material.dart';
import 'package:mishkat_almasabih/core/theming/serag_decorations.dart';
import 'package:mishkat_almasabih/core/theming/serag_styles.dart';

class NoAttemptsLeftWidget extends StatelessWidget {
  const NoAttemptsLeftWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: SeragDecorations.noAttemptsContainerPadding,
      margin: SeragDecorations.noAttemptsContainerMargin,
      decoration: SeragDecorations.noAttemptsContainer(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            SeragDecorations.noAttemptsWarningIcon,
            color: SeragDecorations.noAttemptsWarningIconColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "عذراً، لقد استنفذت الحد اليومي.\nيرجى المحاولة مرة أخرى غداً.",
              style: SeragTextStyles.noAttemptsWarningText,
            ),
          ),
        ],
      ),
    );
  }
}
