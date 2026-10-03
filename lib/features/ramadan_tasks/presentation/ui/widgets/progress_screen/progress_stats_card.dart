import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import '../../../domain/entities/ramadan_task_entity.dart';

/// Detailed progress stats card showing daily, weekly, and monthly
/// indicators with animated circular rings and stat badges.
class ProgressStatsCard extends StatelessWidget {
  final int todayDay;
  final double dailyPercent;
  final double weeklyPercent;
  final double overallPercent;
  final int dailyCompleted;
  final int dailyTotal;
  final List<RamadanTaskEntity> allTasks;
  final String hijriDateString;

  const ProgressStatsCard({
    super.key,
    required this.todayDay,
    required this.dailyPercent,
    required this.weeklyPercent,
    required this.overallPercent,
    required this.dailyCompleted,
    required this.dailyTotal,
    required this.allTasks,
    required this.hijriDateString,
  });

  // ── Compute streak & perfect days ──

  int get _perfectDays {
    final daily = allTasks.where((t) => t.type == TaskType.daily).toList();
    if (daily.isEmpty) return 0;
    int count = 0;
    for (int d = 1; d <= todayDay; d++) {
      final completed = daily.where((t) => t.completedDays.contains(d)).length;
      if (completed == daily.length) count++;
    }
    return count;
  }

  int get _streak {
    final daily = allTasks.where((t) => t.type == TaskType.daily).toList();
    if (daily.isEmpty) return 0;
    int count = 0;
    for (int d = todayDay; d >= 1; d--) {
      final completed = daily.where((t) => t.completedDays.contains(d)).length;
      if (completed == daily.length) {
        count++;
      } else {
        break;
      }
    }
    return count;
  }

  int get _totalCompletions {
    final daily = allTasks.where((t) => t.type == TaskType.daily).toList();
    int total = 0;
    for (int d = 1; d <= todayDay; d++) {
      total += daily.where((t) => t.completedDays.contains(d)).length;
    }
    // Add todayOnly completions
    for (final t in allTasks.where((t) => t.type == TaskType.todayOnly)) {
      total += t.completedDays.length;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [ColorsManager.primaryPurple, ColorsManager.darkPurple],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: ColorsManager.primaryPurple.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Header with date ──
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(16.w, 16.h, 16.w, 0),
            child: Row(
              children: [
                Icon(
                  Icons.insights_rounded,
                  color: ColorsManager.primaryGold,
                  size: 22.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  'إحصائيات رمضان',
                  style: TextStyles.titleLarge.copyWith(
                    color: ColorsManager.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsetsDirectional.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: ColorsManager.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    'يوم ${_toArabicNumerals(todayDay)}',
                    style: TextStyles.titleSmall.copyWith(
                      color: ColorsManager.primaryGold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // ── Three progress rings ──
          Padding(
            padding: EdgeInsetsDirectional.symmetric(horizontal: 12.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ProgressRing(
                  label: 'اليومي',
                  percent: dailyPercent,
                  color: ColorsManager.primaryGold,
                  subtitle: '$dailyCompleted/$dailyTotal',
                ),
                _ProgressRing(
                  label: 'الأسبوعي',
                  percent: weeklyPercent,
                  color: ColorsManager.secondaryPurple,
                  subtitle: '${(weeklyPercent * 100).toInt()}%',
                ),
                _ProgressRing(
                  label: 'الشهري',
                  percent: overallPercent,
                  color: ColorsManager.success,
                  subtitle: '${(overallPercent * 100).toInt()}%',
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // ── Stat badges row ──
          Padding(
            padding: EdgeInsetsDirectional.symmetric(horizontal: 16.w),
            child: Container(
              padding: EdgeInsetsDirectional.all(12.w),
              decoration: BoxDecoration(
                color: ColorsManager.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _StatBadge(
                      icon: Icons.local_fire_department_rounded,
                      iconColor: ColorsManager.error,
                      label: 'التوالي',
                      value: '${_toArabicNumerals(_streak)} يوم',
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 36.h,
                    color: ColorsManager.white.withOpacity(0.2),
                  ),
                  Expanded(
                    child: _StatBadge(
                      icon: Icons.emoji_events_rounded,
                      iconColor: ColorsManager.primaryGold,
                      label: 'أيام مثالية',
                      value: _toArabicNumerals(_perfectDays),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 36.h,
                    color: ColorsManager.white.withOpacity(0.2),
                  ),
                  Expanded(
                    child: _StatBadge(
                      icon: Icons.done_all_rounded,
                      iconColor: ColorsManager.success,
                      label: 'إنجازات',
                      value: _toArabicNumerals(_totalCompletions),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  static String _toArabicNumerals(int number) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number
        .toString()
        .split('')
        .map((d) => arabicDigits[int.parse(d)])
        .join();
  }
}

// ─────────────────────────────────────────────────────────────
// Animated progress ring
// ─────────────────────────────────────────────────────────────

class _ProgressRing extends StatelessWidget {
  final String label;
  final double percent;
  final Color color;
  final String subtitle;

  const _ProgressRing({
    required this.label,
    required this.percent,
    required this.color,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final capped = percent.clamp(0.0, 1.0);
    return Column(
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: capped),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutCubic,
          builder: (_, value, __) {
            return SizedBox(
              width: 68.w,
              height: 68.w,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 68.w,
                    height: 68.w,
                    child: CircularProgressIndicator(
                      value: value,
                      strokeWidth: 5.w,
                      strokeCap: StrokeCap.round,
                      backgroundColor: ColorsManager.white.withOpacity(0.12),
                      color: color,
                    ),
                  ),
                  Text(
                    '${(value * 100).toInt()}%',
                    style: TextStyles.titleMedium.copyWith(
                      color: ColorsManager.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        SizedBox(height: 6.h),
        Text(
          label,
          style: TextStyles.bodySmall.copyWith(
            color: ColorsManager.white.withOpacity(0.85),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          subtitle,
          style: TextStyles.bodySmall.copyWith(
            color: color.withOpacity(0.9),
            fontSize: 10.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Stat badge
// ─────────────────────────────────────────────────────────────

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _StatBadge({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 20.sp),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyles.titleSmall.copyWith(
            color: ColorsManager.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: TextStyles.bodySmall.copyWith(
            color: ColorsManager.white.withOpacity(0.65),
            fontSize: 10.sp,
          ),
        ),
      ],
    );
  }
}
