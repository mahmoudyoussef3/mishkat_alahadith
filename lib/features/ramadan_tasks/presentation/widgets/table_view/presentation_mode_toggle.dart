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
/// - Islamic-inspired emerald/deep-teal gradient on selected chip
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

  // Islamic-inspired palette
  static const emerald = Color(0xFF0D7C66);
  static const deepTeal = Color(0xFF0A5E4F);
  static const softMint = Color(0xFFE8F5F0);
  static const borderMint = Color(0xFFB2DFDB);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: softMint,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: borderMint, width: 1),
        boxShadow: [
          BoxShadow(
            color: emerald.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
          horizontal: 14.w,
          vertical: 8.h,
        ),
        decoration: BoxDecoration(
          gradient:
              isSelected
                  ? const LinearGradient(
                    colors: [
                      PresentationModeToggle.emerald,
                      PresentationModeToggle.deepTeal,
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
                      color: PresentationModeToggle.emerald.withOpacity(0.25),
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
