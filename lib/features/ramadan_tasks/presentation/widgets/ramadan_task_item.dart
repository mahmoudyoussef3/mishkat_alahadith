import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import '../../domain/entities/ramadan_task_entity.dart';

/// A single task card with animated checkbox, type badge, and swipe-to-delete.
class RamadanTaskItem extends StatelessWidget {
  final RamadanTaskEntity task;
  final int todayDay;
  final VoidCallback onToggleDaily;
  final ValueChanged<bool> onToggleMonthly;
  final VoidCallback onDelete;
  final bool readOnly;

  const RamadanTaskItem({
    super.key,
    required this.task,
    required this.todayDay,
    required this.onToggleDaily,
    required this.onToggleMonthly,
    required this.onDelete,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDaily = task.type == TaskType.daily;
    final isCompleted =
        isDaily
            ? task.completedDays.contains(todayDay)
            : task.completedDays.isNotEmpty;

    final card = Container(
      decoration: BoxDecoration(
        color: ColorsManager.cardBackground,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color:
              isCompleted
                  ? ColorsManager.success.withOpacity(0.3)
                  : ColorsManager.mediumGray.withOpacity(0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: ColorsManager.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14.r),
          onTap:
              readOnly
                  ? null
                  : () {
                    if (isDaily) {
                      onToggleDaily();
                    } else {
                      onToggleMonthly(!isCompleted);
                    }
                  },
          child: Padding(
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: 14.w,
              vertical: 14.h,
            ),
            child: Row(
              children: [
                // ── Animated checkbox ──
                _AnimatedCheckbox(isCompleted: isCompleted),
                SizedBox(width: 14.w),

                // ── Title + meta ──
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyles.titleMedium.copyWith(
                          decoration:
                              isCompleted ? TextDecoration.lineThrough : null,
                          color:
                              isCompleted
                                  ? ColorsManager.secondaryText
                                  : ColorsManager.primaryText,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (task.description.isNotEmpty) ...[                        SizedBox(height: 2.h),
                        Text(
                          task.description,
                          style: TextStyles.bodySmall.copyWith(
                            color: ColorsManager.secondaryText,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          _TypeBadge(type: task.type),
                          SizedBox(width: 8.w),
                          if (isDaily)
                            _StatusText(
                              text: isCompleted ? 'مكتملة' : 'غير مكتملة',
                              isCompleted: isCompleted,
                            ),
                          if (!isDaily)
                            _StatusText(
                              text: isCompleted ? 'تم الإنجاز' : 'لم تكتمل',
                              isCompleted: isCompleted,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── Delete button ──
                if (!readOnly)
                  IconButton(
                    onPressed: onDelete,
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: ColorsManager.error.withOpacity(0.7),
                      size: 22.sp,
                    ),
                    splashRadius: 20.r,
                    tooltip: 'حذف',
                  ),
              ],
            ),
          ),
        ),
      ),
    );

    return card;
  }
}

/// Animated circular checkbox with scale + color transition.
class _AnimatedCheckbox extends StatelessWidget {
  final bool isCompleted;
  const _AnimatedCheckbox({required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      width: 28.w,
      height: 28.w,
      decoration: BoxDecoration(
        color: isCompleted ? ColorsManager.success : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: isCompleted ? ColorsManager.success : ColorsManager.mediumGray,
          width: 2,
        ),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder:
            (child, anim) => ScaleTransition(scale: anim, child: child),
        child:
            isCompleted
                ? Icon(
                  Icons.check_rounded,
                  key: const ValueKey('check'),
                  size: 16.sp,
                  color: ColorsManager.white,
                )
                : SizedBox(key: const ValueKey('empty'), width: 16.sp),
      ),
    );
  }
}

/// Small type badge (daily / monthly).
class _TypeBadge extends StatelessWidget {
  final TaskType type;
  const _TypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final isDaily = type == TaskType.daily;
    return Container(
      padding: EdgeInsetsDirectional.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color:
            isDaily
                ? ColorsManager.primaryPurple.withOpacity(0.1)
                : ColorsManager.primaryGold.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        isDaily ? 'يومية' : 'شهرية',
        style: TextStyles.bodySmall.copyWith(
          color:
              isDaily ? ColorsManager.primaryPurple : ColorsManager.primaryGold,
          fontWeight: FontWeight.w600,
          fontSize: 11.sp,
        ),
      ),
    );
  }
}

/// Completion status text.
class _StatusText extends StatelessWidget {
  final String text;
  final bool isCompleted;
  const _StatusText({required this.text, required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyles.bodySmall.copyWith(
        color:
            isCompleted ? ColorsManager.success : ColorsManager.secondaryText,
        fontSize: 11.sp,
      ),
    );
  }
}
