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
    final translations =
        hadith.translations.where((text) => text.trim().isNotEmpty).toList();
    final translation = translations.isNotEmpty ? translations.first : null;

    return Container(
      margin: EdgeInsetsDirectional.only(top: 6.h, bottom: 6.h),
      padding: EdgeInsetsDirectional.all(16.w),
      decoration: BoxDecoration(
        color: ColorsManager.cardBackground,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: ColorsManager.primaryPurple.withAlpha(18),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: ColorsManager.black.withAlpha(12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            textDirection: TextDirection.rtl,
            children: [
              _IndexBadge(index: index),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  hadith.title,
                  textDirection: TextDirection.rtl,
                  style: TextStyles.arabicTitle.copyWith(
                    fontSize: 18.sp,
                    height: 1.4,
                    color: ColorsManager.primaryText,
                  ),
                ),
              ),
            ],
          ),
          if (translation != null) ...[
            SizedBox(height: 8.h),
            Text(
              translation,
              style: TextStyles.bodySmall.copyWith(
                fontSize: 13.sp,
                color: ColorsManager.secondaryText,
                height: 1.5,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (translations.length > 1) ...[
            SizedBox(height: 10.h),
            _TranslationPill(count: translations.length),
          ],
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

class _TranslationPill extends StatelessWidget {
  final int count;

  const _TranslationPill({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsetsDirectional.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: ColorsManager.primaryPurple.withAlpha(24),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        textDirection: TextDirection.rtl,
        children: [
          Icon(
            Icons.translate,
            size: 14.sp,
            color: ColorsManager.primaryPurple,
          ),
          SizedBox(width: 6.w),
          Text(
            'ترجمات: ${convertToArabicNumber(count)}',
            style: TextStyles.labelSmall.copyWith(
              color: ColorsManager.primaryPurple,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
