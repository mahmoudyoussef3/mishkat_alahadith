import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import '../../../domain/entities/ramadan_task_entity.dart';
import '../../cubit/ramadan_tasks_cubit.dart';

/// Dialog for adding a custom worship task with title, description,
/// and daily/today-only selection.
class CustomTaskDialog extends StatefulWidget {
  const CustomTaskDialog({super.key});

  @override
  State<CustomTaskDialog> createState() => _CustomTaskDialogState();
}

class _CustomTaskDialogState extends State<CustomTaskDialog> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  TaskType _type = TaskType.daily;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<RamadanTasksCubit>().addNewTask(
      title: _titleCtrl.text,
      description: _descCtrl.text,
      type: _type,
    );
    Navigator.pop(context); // close dialog
    Navigator.pop(context); // close bottom sheet
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Padding(
          padding: EdgeInsetsDirectional.all(20.w),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Header ──
                Row(
                  children: [
                    Container(
                      width: 36.w,
                      height: 36.w,
                      decoration: BoxDecoration(
                        color: ColorsManager.primaryPurple.withValues(
                          alpha: 0.1,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.edit_note_rounded,
                        size: 20.sp,
                        color: ColorsManager.primaryPurple,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      'إضافة عبادة مخصصة',
                      style: TextStyles.headlineSmall.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 16.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),

                // ── Title field ──
                TextFormField(
                  controller: _titleCtrl,
                  textDirection: TextDirection.rtl,
                  style: TextStyles.bodyLarge,
                  validator:
                      (v) =>
                          (v == null || v.trim().isEmpty)
                              ? 'أدخل اسم العبادة'
                              : null,
                  decoration: _inputDecoration(
                    hint: 'مثال: الدعاء بعد السحور',
                    label: 'اسم العبادة',
                  ),
                ),
                SizedBox(height: 12.h),

                // ── Description field ──
                TextFormField(
                  controller: _descCtrl,
                  textDirection: TextDirection.rtl,
                  style: TextStyles.bodyMedium,
                  maxLines: 2,
                  minLines: 1,
                  decoration: _inputDecoration(
                    hint: 'وصف إضافي (اختياري)',
                    label: 'الوصف',
                  ),
                ),
                SizedBox(height: 16.h),

                // ── Type selector ──
                Text(
                  'نوع العبادة',
                  style: TextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Expanded(
                      child: _TypeChip(
                        label: 'يومية',
                        subtitle: 'تتكرر كل يوم',
                        icon: Icons.replay_rounded,
                        selected: _type == TaskType.daily,
                        onTap: () => setState(() => _type = TaskType.daily),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: _TypeChip(
                        label: 'اليوم فقط',
                        subtitle: 'لهذا اليوم فقط',
                        icon: Icons.today_rounded,
                        selected: _type == TaskType.todayOnly,
                        onTap: () => setState(() => _type = TaskType.todayOnly),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 22.h),

                // ── Submit button ──
                SizedBox(
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
                    onPressed: _submit,
                    child: Text(
                      'إضافة',
                      style: TextStyles.titleMedium.copyWith(
                        color: ColorsManager.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required String label,
  }) {
    return InputDecoration(
      hintText: hint,
      labelText: label,
      hintStyle: TextStyles.bodyMedium.copyWith(
        color: ColorsManager.secondaryText,
      ),
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: ColorsManager.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: ColorsManager.error, width: 1.5),
      ),
      contentPadding: EdgeInsetsDirectional.symmetric(
        horizontal: 16.w,
        vertical: 14.h,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Type selection chip
// ─────────────────────────────────────────────────────────────

class _TypeChip extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.selected,
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
          horizontal: 10.w,
          vertical: 10.h,
        ),
        decoration: BoxDecoration(
          color:
              selected
                  ? ColorsManager.primaryPurple.withValues(alpha: 0.08)
                  : ColorsManager.lightGray,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color:
                selected
                    ? ColorsManager.primaryPurple
                    : ColorsManager.mediumGray,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color:
                  selected
                      ? ColorsManager.primaryPurple
                      : ColorsManager.secondaryText,
              size: 22.sp,
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyles.titleSmall.copyWith(
                color:
                    selected
                        ? ColorsManager.primaryPurple
                        : ColorsManager.primaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              subtitle,
              style: TextStyles.labelSmall.copyWith(
                color: ColorsManager.secondaryText,
                fontSize: 10.sp,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
