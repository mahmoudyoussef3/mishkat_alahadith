import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';

class RamadanProgress extends StatelessWidget {
  final int todayDay;
  final double dailyPercent;
  final double monthlyPercent;
  final double weeklyPercent;
  final String? motivationalText;

  const RamadanProgress({
    super.key,
    required this.todayDay,
    required this.dailyPercent,
    required this.monthlyPercent,
    required this.weeklyPercent,
    this.motivationalText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBar(
          title: 'تقدّم اليوم (اليوم $todayDay)',
          percent: dailyPercent,
          color: ColorsManager.primaryPurple,
        ),
        SizedBox(height: 8.h),
        _buildBar(
          title: 'تقدّم الشهر',
          percent: monthlyPercent,
          color: ColorsManager.primaryGold,
        ),
        SizedBox(height: 8.h),
        _buildBar(
          title: 'تقدّم الأسبوع',
          percent: weeklyPercent,
          color: ColorsManager.secondaryPurple,
        ),
        if (motivationalText != null) ...[
          SizedBox(height: 12.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
            decoration: BoxDecoration(
              color: ColorsManager.primaryGold.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              motivationalText!,
              style: TextStyles.titleMedium.copyWith(
                color: ColorsManager.primaryPurple,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBar({
    required String title,
    required double percent,
    required Color color,
  }) {
    final capped = percent.clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(title, style: TextStyles.titleMedium)),
            Text(
              '${(capped * 100).toStringAsFixed(0)}%',
              style: TextStyles.labelMedium.copyWith(
                color: ColorsManager.secondaryText,
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: LinearProgressIndicator(
            value: capped,
            minHeight: 10.h,
            color: color,
            backgroundColor: ColorsManager.lightGray,
          ),
        ),
      ],
    );
  }
}
