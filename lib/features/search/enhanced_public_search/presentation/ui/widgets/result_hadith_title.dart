import 'package:flutter/material.dart';
import 'package:mishkat_almasabih/core/theming/enhanced_search_styles.dart';
import 'package:mishkat_almasabih/core/theming/enhanced_search_decorations.dart';

class ResultHadithTitle extends StatelessWidget {
  final String title;
  const ResultHadithTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          EnhancedSearchDecorations.titleIcon,
          color: EnhancedSearchDecorations.titleIconColor,
          size: EnhancedSearchDecorations.titleIconSize,
        ),
        Text(
          title,
          style: EnhancedSearchTextStyles.hadithTitle,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
