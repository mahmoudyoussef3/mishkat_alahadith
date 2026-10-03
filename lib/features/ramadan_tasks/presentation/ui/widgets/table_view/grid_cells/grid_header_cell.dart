import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import '../../../../domain/entities/ramadan_task_entity.dart';
import '../../../cubit/ramadan_tasks_cubit.dart';
import '../../edit_task_sheet.dart';

/// Header cell for a task column on the solid-purple header row.
///
/// Displays a white icon with a short label underneath.
/// Tap opens edit sheet. Long-press shows a context menu with
/// edit & delete options.
class GridHeaderCell extends StatelessWidget {
  final String title;
  final IconData icon;
  final TaskType taskType;
  final RamadanTaskEntity task;

  const GridHeaderCell({
    super.key,
    required this.title,
    required this.icon,
    required this.taskType,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: title,
      preferBelow: true,
      waitDuration: const Duration(milliseconds: 400),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () => showEditTaskSheet(context, task),
          onLongPress: () => _showContextMenu(context),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 20.sp, color: ColorsManager.white),
                SizedBox(height: 2.h),
                Text(
                  _shortLabel(title),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyles.labelSmall.copyWith(
                    fontSize: 10.sp,
                    color: ColorsManager.white.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (sheetCtx) => Directionality(
            textDirection: TextDirection.rtl,
            child: Container(
              decoration: BoxDecoration(
                color: ColorsManager.secondaryBackground,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
              ),
              padding: EdgeInsetsDirectional.only(
                start: 16.w,
                end: 16.w,
                top: 12.h,
                bottom: 16.h,
              ),
              child: SafeArea(
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
                    SizedBox(height: 12.h),
                    Text(
                      title,
                      style: TextStyles.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),
                    // Edit option
                    ListTile(
                      leading: Icon(
                        Icons.edit_rounded,
                        color: ColorsManager.primaryPurple,
                        size: 22.sp,
                      ),
                      title: Text('تعديل المهمة', style: TextStyles.titleSmall),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      onTap: () {
                        Navigator.pop(sheetCtx);
                        showEditTaskSheet(context, task);
                      },
                    ),
                    SizedBox(height: 4.h),
                    // Delete option
                    ListTile(
                      leading: Icon(
                        Icons.delete_outline_rounded,
                        color: ColorsManager.error,
                        size: 22.sp,
                      ),
                      title: Text(
                        'حذف المهمة',
                        style: TextStyles.titleSmall.copyWith(
                          color: ColorsManager.error,
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      onTap: () {
                        Navigator.pop(sheetCtx);
                        _confirmDelete(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  void _confirmDelete(BuildContext context) {
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
                'هل أنت متأكد من حذف "$title"؟',
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

  /// Extracts a short label from the title.
  /// Keeps up to 2 words or 10 characters (whichever is shorter)
  /// to prevent overflow inside narrow table columns.
  String _shortLabel(String title) {
    if (title.length <= 10) return title;
    final words = title.split(' ');
    if (words.length <= 2) {
      return title.length <= 14 ? title : '${title.substring(0, 10)}…';
    }
    final twoWords = words.take(2).join(' ');
    return twoWords.length <= 14 ? twoWords : '${twoWords.substring(0, 10)}…';
  }
}
