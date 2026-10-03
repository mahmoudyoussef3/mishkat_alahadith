import 'package:flutter/material.dart';
import 'package:mishkat_almasabih/core/theming/daily_hadith_styles.dart';

class HadithRichText extends StatelessWidget {
  final String hadith;

  const HadithRichText({super.key, required this.hadith});

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: [
          TextSpan(text: hadith, style: DailyHadithTextStyles.hadithText),
        ],
      ),
    );
  }
}
