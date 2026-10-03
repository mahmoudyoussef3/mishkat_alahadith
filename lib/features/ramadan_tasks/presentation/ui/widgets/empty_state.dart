import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import '../cubit/ramadan_tasks_cubit.dart';

/// Friendly empty state with illustration icon and contextual message.
/// Optimized with const constructors and smooth animations.
class RamadanEmptyState extends StatelessWidget {
  final ViewMode viewMode;

  const RamadanEmptyState({super.key, required this.viewMode});

  @override
  Widget build(BuildContext context) {
    final (icon, message, subtitle) = switch (viewMode) {
      ViewMode.today => (
        Icons.task_alt_rounded,
        'لا توجد مهام لليوم',
        'اضغط + لإضافة مهمة جديدة',
      ),
      ViewMode.history => (
        Icons.history_rounded,
        'لا توجد مهام مسجّلة',
        'لهذا اليوم',
      ),
      ViewMode.all => (
        Icons.playlist_add_rounded,
        'لم تُضف أي مهام بعد',
        'اضغط + لتبدأ',
      ),
    };

    return RepaintBoundary(
      child: Padding(
        padding: EdgeInsetsDirectional.symmetric(vertical: 40.h),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated icon container
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutBack,
                builder: (context, value, child) {
                  return Transform.scale(scale: value, child: child);
                },
                child: Container(
                  width: 80.w,
                  height: 80.w,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ColorsManager.primaryPurple.withOpacity(0.08),
                        ColorsManager.primaryPurple.withOpacity(0.03),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: ColorsManager.primaryPurple.withOpacity(0.1),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    icon,
                    size: 36.sp,
                    color: ColorsManager.primaryPurple.withOpacity(0.4),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              // Main message
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyles.titleMedium.copyWith(
                  color: ColorsManager.secondaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 6.h),
              // Subtitle
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyles.bodySmall.copyWith(
                  color: ColorsManager.disabledText,
                  fontSize: 13.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
