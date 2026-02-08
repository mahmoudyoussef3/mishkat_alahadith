import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import '../../domain/entities/ramadan_task_entity.dart';

class RamadanTaskItem extends StatelessWidget {
  final RamadanTaskEntity task;
  final int todayDay;
  final VoidCallback onToggleDaily;
  final ValueChanged<bool> onToggleMonthly;
  final VoidCallback onDelete;

  const RamadanTaskItem({
    super.key,
    required this.task,
    required this.todayDay,
    required this.onToggleDaily,
    required this.onToggleMonthly,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDaily = task.type == TaskType.daily;
    final completedToday = task.completedDays.contains(todayDay);
    final monthlyCompleted = task.completedDays.isNotEmpty;

    return Card(
      color: ColorsManager.cardBackground,
      margin: EdgeInsetsDirectional.only(bottom: 8.h),
      child: Padding(
        padding: EdgeInsetsDirectional.only(
          start: 12.w,
          end: 12.w,
          top: 12.h,
          bottom: 12.h,
        ),
        child: Row(
          children: [
            // Checkbox area
            InkWell(
              onTap: () {
                if (isDaily) {
                  onToggleDaily();
                } else {
                  onToggleMonthly(!monthlyCompleted);
                }
              },
              child: Container(
                width: 24.w,
                height: 24.w,
                decoration: BoxDecoration(
                  color:
                      (isDaily ? completedToday : monthlyCompleted)
                          ? ColorsManager.success
                          : ColorsManager.mediumGray,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Icon(
                  (isDaily ? completedToday : monthlyCompleted)
                      ? Icons.check
                      : Icons.close,
                  size: 16.sp,
                  color: ColorsManager.white,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            // Title and meta
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task.title, style: TextStyles.titleLarge),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      _TypeBadge(type: task.type),
                      SizedBox(width: 8.w),
                      if (isDaily)
                        Text(
                          completedToday ? 'مكتملة اليوم' : 'غير مكتملة اليوم',
                          style: TextStyles.bodySmall,
                        ),
                      if (!isDaily)
                        Text(
                          monthlyCompleted ? 'مكتملة' : 'غير مكتملة',
                          style: TextStyles.bodySmall,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete, color: ColorsManager.error),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final TaskType type;
  const _TypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final isDaily = type == TaskType.daily;
    final label = isDaily ? 'يومية' : 'شهرية';
    final color =
        isDaily ? ColorsManager.primaryPurple : ColorsManager.primaryGold;
    final textColor = isDaily ? ColorsManager.white : ColorsManager.black;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(isDaily ? 1.0 : 0.2),
        borderRadius: BorderRadius.circular(8.r),
        border:
            isDaily
                ? null
                : Border.all(color: ColorsManager.primaryGold, width: 1),
      ),
      child: Text(
        label,
        style: TextStyles.labelMedium.copyWith(color: textColor),
      ),
    );
  }
}
