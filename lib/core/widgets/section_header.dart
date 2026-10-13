import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';

/// Section title with an optional trailing text action ("عرض الكل").
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
    this.padding,
  });

  final String title;
  final String? actionLabel;

  /// Shown before [actionLabel], e.g. a refresh glyph.
  final IconData? actionIcon;
  final VoidCallback? onAction;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final label = actionLabel;
    return Padding(
      padding: padding ?? EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 10.h),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(title, style: TextStyles.sectionTitle),
            ),
          ),
          if (label != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                minimumSize: Size(0, 36.h),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (actionIcon != null) ...[
                    Icon(actionIcon, size: 18.r),
                    SizedBox(width: 4.w),
                  ],
                  Text(label, style: TextStyles.actionLabel),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
