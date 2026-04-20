import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/functions.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/domain/entities/hadith_entity.dart';

class HadithCategoryCard extends StatelessWidget {
  final HadithEntity hadith;
  final int index;

  const HadithCategoryCard({
    super.key,
    required this.hadith,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsetsDirectional.only(top: 6.h, bottom: 6.h),
      padding: EdgeInsetsDirectional.fromSTEB(18.w, 16.h, 18.w, 18.h),
      decoration: BoxDecoration(
        color: ColorsManager.cardBackground,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: ColorsManager.primaryPurple.withAlpha(14),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: ColorsManager.black.withAlpha(10),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          PositionedDirectional(
            top: 4.h,
            end: 6.w,
            child: Icon(
              Icons.format_quote,
              size: 36.sp,
              color: ColorsManager.primaryPurple.withAlpha(24),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: _IndexBadge(index: index),
              ),
              SizedBox(height: 12.h),
              Text(
                hadith.title,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.justify,
                style: TextStyles.hadithText.copyWith(
                  fontSize: 17.sp,
                  height: 1.8,
                  color: ColorsManager.primaryText,
                  fontStyle: FontStyle.normal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IndexBadge extends StatelessWidget {
  final int index;

  const _IndexBadge({required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsetsDirectional.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorsManager.primaryPurple.withAlpha(220),
            ColorsManager.secondaryPurple.withAlpha(210),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: ColorsManager.primaryPurple.withAlpha(35),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        textDirection: TextDirection.rtl,
        children: [
          Icon(Icons.bookmark, size: 14.sp, color: ColorsManager.white),
          SizedBox(width: 6.w),
          Text(
            convertToArabicNumber(index),
            style: TextStyles.labelMedium.copyWith(
              color: ColorsManager.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
