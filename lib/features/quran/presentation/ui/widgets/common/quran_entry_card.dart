import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/extensions.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/quran_decorations.dart';
import 'package:mishkat_almasabih/core/theming/quran_styles.dart';

/// The way into the Quran from the home screen.
class QuranEntryCard extends StatelessWidget {
  const QuranEntryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 12.h),
      child: Material(
        type: MaterialType.transparency,
        child: Ink(
          decoration: QuranDecorations.entryCard(),
          child: InkWell(
            onTap: () => context.pushNamed(Routes.quranScreen),
            borderRadius: BorderRadius.circular(18.r),
            child: Padding(
              padding: EdgeInsets.all(14.r),
              child: Row(
                children: [
                  Container(
                    width: 48.r,
                    height: 48.r,
                    decoration: QuranDecorations.entryCardIcon(),
                    child: Icon(
                      Icons.auto_stories_rounded,
                      color: ColorsManager.white,
                      size: 26.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'المصحف الشريف',
                          style: QuranTextStyles.entryCardTitle,
                        ),
                        Text(
                          'اقرأ برسم مصحف المدينة مع تلوين أحكام التجويد',
                          style: QuranTextStyles.entryCardSubtitle,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_left_rounded,
                    color: ColorsManager.primaryGold,
                    size: 26.sp,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
