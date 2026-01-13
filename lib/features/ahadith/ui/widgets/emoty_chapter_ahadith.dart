import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/hadith_decorations.dart';
import 'package:mishkat_almasabih/core/theming/hadith_styles.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 40.w),
          padding: EdgeInsets.all(32.w),
          decoration: HadithDecorations.emptyStateCard(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80.w,
                height: 80.h,
                decoration: HadithDecorations.patternOverlay(
                  ColorsManager.primaryPurple,
                  40,
                ),
                child: Icon(
                  Icons.search_off,
                  size: 40.r,
                  color: ColorsManager.primaryPurple,
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'لا توجد نتائج',
                style: HadithTextStyles.emptyTitle,
              ),
              SizedBox(height: 12.h),
              Text(
                'حاول بكلمة أبسط أو مختلفة',
                style: HadithTextStyles.emptySubtitle,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
