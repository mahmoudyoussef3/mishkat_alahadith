import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import '../../domain/entities/ramadan_task_entity.dart';
import '../cubit/ramadan_tasks_cubit.dart';

/// Shows a confirmation dialog before deleting a task.
void showDeleteConfirmDialog(BuildContext context, RamadanTaskEntity task) {
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
                  context.read<RamadanTasksCubit>().deleteById(task.id);
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
