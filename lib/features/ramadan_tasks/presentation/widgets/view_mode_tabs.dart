import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import '../cubit/ramadan_tasks_cubit.dart';

/// iOS-style segmented tab bar for switching between Today / History / All views.
class ViewModeTabs extends StatelessWidget {
  final ViewMode viewMode;
  final ValueChanged<ViewMode> onChange;

  const ViewModeTabs({
    super.key,
    required this.viewMode,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsetsDirectional.all(4.w),
      decoration: BoxDecoration(
        color: ColorsManager.lightGray,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          _tab('اليوم', Icons.today_rounded, ViewMode.today),
          SizedBox(width: 4.w),
          _tab('السجل', Icons.history_rounded, ViewMode.history),
          SizedBox(width: 4.w),
          _tab('الكل', Icons.list_alt_rounded, ViewMode.all),
        ],
      ),
    );
  }

  Widget _tab(String label, IconData icon, ViewMode mode) {
    final selected = viewMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChange(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: EdgeInsetsDirectional.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: selected ? ColorsManager.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10.r),
            boxShadow:
                selected
                    ? [
                      BoxShadow(
                        color: ColorsManager.black.withOpacity(0.06),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                    : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16.sp,
                color:
                    selected
                        ? ColorsManager.primaryPurple
                        : ColorsManager.secondaryText,
              ),
              SizedBox(width: 4.w),
              Text(
                label,
                style: TextStyles.titleSmall.copyWith(
                  color:
                      selected
                          ? ColorsManager.primaryPurple
                          : ColorsManager.secondaryText,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
