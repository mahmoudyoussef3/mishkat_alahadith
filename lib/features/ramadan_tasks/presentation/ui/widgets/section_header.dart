import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';

/// Section header row with a title and a task count badge.
class SectionHeader extends StatelessWidget {
  final String title;
  final int count;

  const SectionHeader({super.key, required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: TextStyles.headlineSmall),
        const Spacer(),
        Container(
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: 10.w,
            vertical: 4.h,
          ),
          decoration: BoxDecoration(
            color: ColorsManager.primaryPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            '$count',
            style: TextStyles.titleSmall.copyWith(
              color: ColorsManager.primaryPurple,
            ),
          ),
        ),
      ],
    );
  }
}
