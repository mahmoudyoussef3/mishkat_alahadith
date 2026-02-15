import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';

/// Presentation display mode for the Ramadan tasks screen.
enum PresentationMode { card, table }

/// A premium Ramadan-themed toggle switch between Card View and Table View.
///
/// Features:
/// - Purple gradient using app colors (primaryPurple to darkPurple) on selected chip
/// - Smooth animated transitions (300ms)
/// - Haptic feedback on toggle
/// - RTL-aware layout
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
        color: ColorsManager.primaryBackground,
        borderRadius: BorderRadius.circular(14.r),
      
 
      ),
      padding: EdgeInsets.all(16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
                    SizedBox(width: 2.w),

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
          horizontal: 14.w,
          vertical: 8.h,
        ),
        decoration: BoxDecoration(
          gradient:
              isSelected
                  ? const LinearGradient(
                    colors: [
                      ColorsManager.primaryPurple,
                      ColorsManager.darkPurple,
                    ],
                    begin: AlignmentDirectional.topStart,
                    end: AlignmentDirectional.bottomEnd,
                  )
                  : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(11.r),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: ColorsManager.primaryPurple.withOpacity(0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                  : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16.sp,
              color:
                  isSelected
                      ? ColorsManager.white
                      : ColorsManager.secondaryText,
            ),
            SizedBox(width: 6.w),
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
