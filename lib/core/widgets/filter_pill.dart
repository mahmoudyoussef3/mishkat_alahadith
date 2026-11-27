import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';

/// Single-choice filter pill; the selected one is drawn in solid ink.
class FilterPill extends StatelessWidget {
  const FilterPill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground =
        selected
            ? ColorsManager.secondaryBackground
            : ColorsManager.primaryText;

    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color:
            selected ? ColorsManager.primaryText : ColorsManager.cardBackground,
        shape: StadiumBorder(
          side: BorderSide(
            color: selected ? ColorsManager.primaryText : ColorsManager.border,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 7.h),
            child: Text(
              label,
              style: TextStyles.chipLabel.copyWith(
                fontSize: 13.sp,
                color: foreground,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
