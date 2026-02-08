import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import '../cubit/ramadan_tasks_cubit.dart';

/// Friendly empty state with illustration icon and contextual message.
class RamadanEmptyState extends StatelessWidget {
  final ViewMode viewMode;

  const RamadanEmptyState({super.key, required this.viewMode});

  @override
  Widget build(BuildContext context) {
    final (icon, message) = switch (viewMode) {
      ViewMode.today => (
        Icons.task_alt_rounded,
        'لا توجد مهام لليوم.\nاضغط + لإضافة مهمة جديدة.',
      ),
      ViewMode.history => (
        Icons.history_rounded,
        'لا توجد مهام مسجّلة لهذا اليوم.',
      ),
      ViewMode.all => (
        Icons.playlist_add_rounded,
        'لم تُضف أي مهام بعد.\nاضغط + لتبدأ.',
      ),
    };

    return Padding(
      padding: EdgeInsetsDirectional.symmetric(vertical: 40.h),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                color: ColorsManager.primaryPurple.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 36.sp,
                color: ColorsManager.primaryPurple.withOpacity(0.5),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyles.bodyMedium.copyWith(
                color: ColorsManager.secondaryText,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
