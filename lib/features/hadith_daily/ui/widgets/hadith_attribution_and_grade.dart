import 'package:flutter/material.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/features/hadith_daily/data/models/new_daily_hadith_model.dart';
import 'package:mishkat_almasabih/core/theming/daily_hadith_styles.dart';
import 'package:mishkat_almasabih/core/theming/daily_hadith_decorations.dart';

class HadithAttributionAndGrade extends StatelessWidget {
  final NewDailyHadithModel data;
  const HadithAttributionAndGrade({super.key, required this.data});

  Color gradeColor(String? g) {
    switch (g?.toLowerCase()) {
      case "sahih":
      case "صحيح":
        return ColorsManager.hadithAuthentic;
      case "hasan":
      case "حسن":
        return ColorsManager.hadithGood;
      case "daif":
      case "ضعيف":
        return ColorsManager.hadithWeak;
      default:
        return ColorsManager.hadithAuthentic;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (data.attribution != null)
          Flexible(
            child: Text(
              "📖 ${data.attribution!}",
              style: DailyHadithTextStyles.attribution,
              textAlign: TextAlign.start,
            ),
          ),
        if (data.grade != null)
          Chip(
            backgroundColor: DailyHadithDecorations.gradeChipBg(
              gradeColor(data.grade),
            ),
            label: Text(
              data.grade ?? "",
              style: DailyHadithTextStyles.gradeLabel(gradeColor(data.grade)),
            ),
          ),
      ],
    );
  }
}
