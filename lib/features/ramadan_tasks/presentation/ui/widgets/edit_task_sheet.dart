import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import '../../domain/entities/ramadan_task_entity.dart';
import '../cubit/ramadan_tasks_cubit.dart';

/// Opens a bottom sheet to edit task title & description.
void showEditTaskSheet(BuildContext parentContext, RamadanTaskEntity task) {
  final cubit = parentContext.read<RamadanTasksCubit>();
  final titleController = TextEditingController(text: task.title);
  final descriptionController = TextEditingController(text: task.description);

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
          child: _EditTaskSheetBody(
            titleController: titleController,
            descriptionController: descriptionController,
            taskType: task.type,
            onSave: (title, description) {
              if (title.trim().isNotEmpty) {
                cubit.editTask(
                  id: task.id,
                  title: title,
                  description: description,
                );
                Navigator.pop(sheetContext);
              }
            },
            onDelete: () {
              Navigator.pop(sheetContext);
              _showDeleteConfirm(parentContext, cubit, task);
            },
          ),
        ),
      );
    },
  );
}

void _showDeleteConfirm(
  BuildContext context,
  RamadanTasksCubit cubit,
  RamadanTaskEntity task,
) {
  showDialog(
    context: context,
    builder:
        (dialogCtx) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            title: Text('حذف المهمة', style: TextStyles.headlineSmall),
            content: Text(
              'هل أنت متأكد من حذف "${task.title}"؟',
              style: TextStyles.bodyMedium,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: Text(
                  'إلغاء',
                  style: TextStyles.titleSmall.copyWith(
                    color: ColorsManager.secondaryText,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogCtx);
                  cubit.deleteById(task.id);
                },
                child: Text(
                  'حذف',
                  style: TextStyles.titleSmall.copyWith(
                    color: ColorsManager.error,
                  ),
                ),
              ),
            ],
          ),
        ),
  );
}

/// Sheet body with title, description fields and save/delete buttons.
class _EditTaskSheetBody extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TaskType taskType;
  final void Function(String title, String description) onSave;
  final VoidCallback onDelete;

  const _EditTaskSheetBody({
    required this.titleController,
    required this.descriptionController,
    required this.taskType,
    required this.onSave,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: ColorsManager.mediumGray,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 16.h),

          // Header row with title and task type badge
          Row(
            children: [
              Expanded(
                child: Text('تعديل المهمة', style: TextStyles.headlineSmall),
              ),
              Container(
                padding: EdgeInsetsDirectional.symmetric(
                  horizontal: 10.w,
                  vertical: 4.h,
                ),
                decoration: BoxDecoration(
                  color:
                      taskType == TaskType.daily
                          ? ColorsManager.primaryPurple.withValues(alpha: 0.1)
                          : ColorsManager.primaryGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  taskType == TaskType.daily ? 'يومية' : 'اليوم فقط',
                  style: TextStyles.labelSmall.copyWith(
                    color:
                        taskType == TaskType.daily
                            ? ColorsManager.primaryPurple
                            : ColorsManager.primaryGold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Title field
          TextField(
            controller: titleController,
            textDirection: TextDirection.rtl,
            style: TextStyles.bodyLarge,
            decoration: InputDecoration(
              labelText: 'اسم المهمة',
              labelStyle: TextStyles.bodyMedium.copyWith(
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
            controller: descriptionController,
            textDirection: TextDirection.rtl,
            style: TextStyles.bodyMedium,
            maxLines: 3,
            minLines: 1,
            decoration: InputDecoration(
              labelText: 'الوصف (اختياري)',
              labelStyle: TextStyles.bodyMedium.copyWith(
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
          SizedBox(height: 20.h),

          // Buttons row: delete + save
          Row(
            children: [
              // Delete button
              SizedBox(
                height: 48.h,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ColorsManager.error,
                    side: const BorderSide(color: ColorsManager.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    padding: EdgeInsetsDirectional.symmetric(horizontal: 16.w),
                  ),
                  onPressed: onDelete,
                  icon: Icon(Icons.delete_outline_rounded, size: 20.sp),
                  label: Text(
                    'حذف',
                    style: TextStyles.titleSmall.copyWith(
                      color: ColorsManager.error,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),

              // Save button
              Expanded(
                child: SizedBox(
                  height: 48.h,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorsManager.primaryPurple,
                      foregroundColor: ColorsManager.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      elevation: 0,
                    ),
                    onPressed:
                        () => onSave(
                          titleController.text,
                          descriptionController.text,
                        ),
                    icon: Icon(Icons.check_rounded, size: 20.sp),
                    label: Text(
                      'حفظ التعديلات',
                      style: TextStyles.titleMedium.copyWith(
                        color: ColorsManager.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
