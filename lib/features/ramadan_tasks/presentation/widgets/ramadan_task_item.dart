import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import '../../domain/entities/ramadan_task_entity.dart';

/// A single task card with animated checkbox, type badge, and delete.
/// Optimized with RepaintBoundary for scrolling performance.
class RamadanTaskItem extends StatelessWidget {
  final RamadanTaskEntity task;
  final int todayDay;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final bool readOnly;

  const RamadanTaskItem({
    super.key,
    required this.task,
    required this.todayDay,
    required this.onToggle,
    required this.onDelete,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDaily = task.type == TaskType.daily;
    final relevantDay = isDaily ? todayDay : task.createdForDay;
    final isCompleted = task.completedDays.contains(relevantDay);

    return RepaintBoundary(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: ColorsManager.cardBackground,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color:
                isCompleted
                    ? ColorsManager.success.withOpacity(0.25)
                    : ColorsManager.mediumGray.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: ColorsManager.black.withOpacity(0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14.r),
            onTap: readOnly ? null : onToggle,
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyles.titleMedium.copyWith(
                            decoration:
                                isCompleted ? TextDecoration.lineThrough : null,
                            color:
                                isCompleted
                                    ? ColorsManager.secondaryText
                                    : ColorsManager.primaryText,
                            decorationColor: ColorsManager.secondaryText,
                          ),
                          child: Text(
                            task.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (task.description.isNotEmpty) ...[
                          SizedBox(height: 3.h),
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
                        SizedBox(height: 6.h),
                        Row(
                          children: [
                            _TypeBadge(task: task),
                            if (!readOnly) ...[
                              SizedBox(width: 8.w),
                              _StatusIndicator(isCompleted: isCompleted),
                            ],
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
                        color: ColorsManager.error.withOpacity(0.6),
                        size: 20.sp,
                      ),
                      iconSize: 20.sp,
                      padding: EdgeInsetsDirectional.all(8.w),
                      constraints: BoxConstraints(
                        minWidth: 36.w,
                        minHeight: 36.w,
                      ),
                      tooltip: 'حذف',
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
                : const SizedBox.shrink(key: ValueKey('empty')),
      ),
    );
  }
}

/// Small type badge (daily / today only).
class _TypeBadge extends StatelessWidget {
  final RamadanTaskEntity task;

  const _TypeBadge({required this.task});

  @override
  Widget build(BuildContext context) {
    final isDaily = task.type == TaskType.daily;
    final label = isDaily ? 'يومياً' : 'اليوم ${task.createdForDay} فقط';
    return Container(
      padding: EdgeInsetsDirectional.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color:
            isDaily
                ? ColorsManager.primaryPurple.withOpacity(0.1)
                : ColorsManager.primaryGold.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        label,
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

/// Status indicator with dot
class _StatusIndicator extends StatelessWidget {
  final bool isCompleted;

  const _StatusIndicator({required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6.w,
          height: 6.w,
          decoration: BoxDecoration(
            color:
                isCompleted ? ColorsManager.success : ColorsManager.mediumGray,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 4.w),
        Text(
          isCompleted ? 'مكتملة' : 'غير مكتملة',
          style: TextStyles.bodySmall.copyWith(
            color:
                isCompleted
                    ? ColorsManager.success
                    : ColorsManager.secondaryText,
            fontSize: 11.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
