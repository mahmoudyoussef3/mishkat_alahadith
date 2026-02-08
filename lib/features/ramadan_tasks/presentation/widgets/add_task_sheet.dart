import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import '../../domain/entities/ramadan_task_entity.dart';
import '../cubit/ramadan_tasks_cubit.dart';

/// Opens the add-task bottom sheet.
///
/// Call this from the parent page — it reads the [RamadanTasksCubit]
/// from [parentContext] so the sheet can add tasks.
void showAddTaskSheet(BuildContext parentContext) {
  final cubit = parentContext.read<RamadanTasksCubit>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  showModalBottomSheet(
    context: parentContext,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          decoration: BoxDecoration(
            color: ColorsManager.secondaryBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          padding: EdgeInsetsDirectional.only(
            start: 20.w,
            end: 20.w,
            top: 12.h,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20.h,
          ),
          child: _AddTaskSheetBody(
            titleController: titleController,
            descriptionController: descriptionController,
            onAdd: (title, description, type) {
              if (title.trim().isNotEmpty) {
                cubit.addNewTask(
                  title: title,
                  description: description,
                  type: type,
                );
                Navigator.pop(sheetContext);
              }
            },
          ),
        ),
      );
    },
  );
}

// ══════════════════════════════════════════════════════════════
// Sheet body & type pill (private to this file)
// ══════════════════════════════════════════════════════════════

/// Bottom sheet body with title/description fields and type selector.
class _AddTaskSheetBody extends StatefulWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final void Function(String title, String description, TaskType type) onAdd;

  const _AddTaskSheetBody({
    required this.titleController,
    required this.descriptionController,
    required this.onAdd,
  });

  @override
  State<_AddTaskSheetBody> createState() => _AddTaskSheetBodyState();
}

class _AddTaskSheetBodyState extends State<_AddTaskSheetBody> {
  TaskType _selectedType = TaskType.daily;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: ColorsManager.mediumGray,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 16.h),
          Text('إضافة مهمة جديدة', style: TextStyles.headlineSmall),
          SizedBox(height: 16.h),
      
          // Title field
          TextField(
            controller: widget.titleController,
            textDirection: TextDirection.rtl,
            style: TextStyles.bodyLarge,
            decoration: InputDecoration(
              hintText: 'مثال: قراءة جزء من القرآن',
              hintStyle: TextStyles.bodyMedium.copyWith(
                color: ColorsManager.secondaryText,
              ),
              filled: true,
              fillColor: ColorsManager.lightGray,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(
                  color: ColorsManager.primaryPurple,
                  width: 1.5,
                ),
              ),
              contentPadding: EdgeInsetsDirectional.symmetric(
                horizontal: 16.w,
                vertical: 14.h,
              ),
            ),
          ),
          SizedBox(height: 12.h),
      
          // Description field
          TextField(
            controller: widget.descriptionController,
            textDirection: TextDirection.rtl,
            style: TextStyles.bodyMedium,
            maxLines: 3,
            minLines: 1,
            decoration: InputDecoration(
              hintText: 'وصف المهمة (اختياري)',
              hintStyle: TextStyles.bodyMedium.copyWith(
                color: ColorsManager.secondaryText,
              ),
              filled: true,
              fillColor: ColorsManager.lightGray,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(
                  color: ColorsManager.primaryPurple,
                  width: 1.5,
                ),
              ),
              contentPadding: EdgeInsetsDirectional.symmetric(
                horizontal: 16.w,
                vertical: 14.h,
              ),
            ),
          ),
          SizedBox(height: 16.h),
      
          // Type selector — pill buttons
          Text('نوع المهمة', style: TextStyles.titleMedium),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: _TypePill(
                  label: 'يومياً',
                  subtitle: 'تتكرر كل يوم طوال الشهر',
                  icon: Icons.replay_rounded,
                  isSelected: _selectedType == TaskType.daily,
                  onTap: () => setState(() => _selectedType = TaskType.daily),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _TypePill(
                  label: 'اليوم فقط',
                  subtitle: 'لهذا اليوم فقط',
                  icon: Icons.today_rounded,
                  isSelected: _selectedType == TaskType.todayOnly,
                  onTap: () => setState(() => _selectedType = TaskType.todayOnly),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
      
          // Add button
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorsManager.primaryPurple,
                foregroundColor: ColorsManager.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
                elevation: 0,
              ),
              onPressed:
                  () => widget.onAdd(
                    widget.titleController.text,
                    widget.descriptionController.text,
                    _selectedType,
                  ),
              child: Text(
                'إضافة',
                style: TextStyles.titleMedium.copyWith(
                  color: ColorsManager.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pill-style type selector for the add-task sheet.
class _TypePill extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypePill({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: 12.w,
          vertical: 12.h,
        ),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? ColorsManager.primaryPurple.withOpacity(0.1)
                  : ColorsManager.lightGray,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color:
                isSelected
                    ? ColorsManager.primaryPurple
                    : ColorsManager.mediumGray,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color:
                  isSelected
                      ? ColorsManager.primaryPurple
                      : ColorsManager.secondaryText,
              size: 24.sp,
            ),
            SizedBox(height: 6.h),
            Text(
              label,
              style: TextStyles.titleSmall.copyWith(
                color:
                    isSelected
                        ? ColorsManager.primaryPurple
                        : ColorsManager.primaryText,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              subtitle,
              style: TextStyles.bodySmall.copyWith(
                color: ColorsManager.secondaryText,
                fontSize: 11.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
