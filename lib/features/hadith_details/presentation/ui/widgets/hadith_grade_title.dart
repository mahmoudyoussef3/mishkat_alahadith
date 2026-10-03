import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/hadith_details_styles.dart';
import 'package:mishkat_almasabih/core/theming/hadith_details_decorations.dart';

class HadithGradeTile extends StatelessWidget {
  final String grade;
  final VoidCallback onTap;
  const HadithGradeTile({super.key, required this.grade, required this.onTap});

  String gradeArabic(String g) {
    switch (g.toLowerCase()) {
      case 'sahih':
        return " حديث صحيح ";
      case 'good':
        return " حديث حسن ";
      case "daif":
        return " حديث ضعيف ";
      default:
        return '';
    }
  }

  Color gradeColor(String g) {
    switch (gradeArabic(g)) {
      case " حديث صحيح ":
        return ColorsManager.hadithAuthentic;
      case " حديث حسن ":
        return ColorsManager.hadithGood;
      case " حديث ضعيف ":
        return ColorsManager.hadithWeak;
      default:
        return ColorsManager.gray;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: HadithDetailsDecorations.gradeChipBg(gradeColor(grade)),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              gradeArabic(grade),
              style: HadithDetailsTextStyles.gradeLabel(gradeColor(grade)),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),

            child: TextButton.icon(
              onPressed: onTap,

              icon: Icon(Icons.copy),
              label: Text('نسخ الحديث'),
            ),
          ),
        ],
      ),
    );
  }
}
