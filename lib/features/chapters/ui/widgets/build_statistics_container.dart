// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/chapters_decorations.dart';
import 'package:mishkat_almasabih/core/theming/chapters_styles.dart';

class BuildStatisticsContainer extends StatelessWidget {
  const BuildStatisticsContainer({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: ChaptersDecorations.statsCard(color),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: ColorsManager.white.withOpacity(0.15),
            child: Icon(icon, color: ColorsManager.white, size: 24),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: ChaptersTextStyles.statsTitle,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(width: 8.w),
              Text(
                value,
                style: ChaptersTextStyles.statsValue,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
