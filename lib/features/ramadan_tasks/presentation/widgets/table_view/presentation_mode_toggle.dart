import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';

/// Presentation display mode for the Ramadan tasks screen.
enum PresentationMode { card, table }

/// A sleek toggle switch between Card View and Table View modes.
/// Includes subtle haptic feedback and smooth transitions.
class PresentationModeToggle extends StatelessWidget {
  final PresentationMode mode;
  final ValueChanged<PresentationMode> onChanged;

  const PresentationModeToggle({
    super.key,
    required this.mode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorsManager.lightGray,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: ColorsManager.mediumGray.withOpacity(0.3),
          width: 1,
        ),
      ),
      padding: EdgeInsets.all(3.w),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleChip(
            icon: Icons.view_agenda_rounded,
            label: 'بطاقات',
            isSelected: mode == PresentationMode.card,
            onTap: () {
              if (mode != PresentationMode.card) {
                HapticFeedback.selectionClick();
                onChanged(PresentationMode.card);
              }
            },
          ),
          SizedBox(width: 2.w),
          _ToggleChip(
            icon: Icons.grid_on_rounded,
            label: 'جدول',
            isSelected: mode == PresentationMode.table,
            onTap: () {
              if (mode != PresentationMode.table) {
                HapticFeedback.selectionClick();
                onChanged(PresentationMode.table);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleChip({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: 12.w,
          vertical: 7.h,
        ),
        decoration: BoxDecoration(
          color: isSelected ? ColorsManager.primaryPurple : Colors.transparent,
          borderRadius: BorderRadius.circular(10.r),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: ColorsManager.primaryPurple.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                icon,
                key: ValueKey('${icon.hashCode}_$isSelected'),
                size: 16.sp,
                color:
                    isSelected
                        ? ColorsManager.white
                        : ColorsManager.secondaryText,
              ),
            ),
            SizedBox(width: 5.w),
            Text(
              label,
              style: TextStyles.bodySmall.copyWith(
                color:
                    isSelected
                        ? ColorsManager.white
                        : ColorsManager.secondaryText,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
