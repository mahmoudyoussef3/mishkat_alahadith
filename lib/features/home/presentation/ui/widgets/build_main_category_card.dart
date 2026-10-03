import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/spacing.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/home_decorations.dart';
import 'package:mishkat_almasabih/core/theming/home_styles.dart';

class BuildMainCategoryCard extends StatelessWidget {
  const BuildMainCategoryCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.bookCount,
    required this.gradient,
    required this.onTap,
  });
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final int bookCount;
  final Gradient gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140.h,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: ColorsManager.primaryPurple.withOpacity(0.25),
              blurRadius: 24.r,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.08,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24.r),
                  child: Image.asset(
                    'assets/images/islamic_pattern.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 50.w,
                height: 50.h,
                decoration: HomeDecorations.mainCategoryCorner(),
                child: Icon(
                  Icons.star,
                  color: ColorsManager.white.withOpacity(0.8),
                  size: 20.sp,
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(
                vertical: Spacing.md2,
                horizontal: Spacing.lg,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          title,
                          style: HomeTextStyles.mainCategoryTitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: Spacing.xs),

                        SizedBox(height: Spacing.xs),

                        Flexible(
                          child: Text(
                            description,
                            style: HomeTextStyles.mainCategoryDescription,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Spacing.md,
                      vertical: Spacing.sm,
                    ),
                    decoration: HomeDecorations.mainCategoryCountPill(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$bookCount',
                          style: HomeTextStyles.categoryCountNumber,
                        ),
                        Text('كتاب', style: HomeTextStyles.categoryCountLabel),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              bottom: 16.h,
              left: 16.w,
              child: Container(
                padding: EdgeInsets.all(12.w),
                decoration: HomeDecorations.mainCategoryIconOverlay(),
                child: Icon(icon, color: ColorsManager.white, size: 24.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
