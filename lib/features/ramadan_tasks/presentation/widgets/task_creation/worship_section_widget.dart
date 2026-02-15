import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import '../../../domain/worship_templates.dart';
import 'worship_tile.dart';

/// A collapsible section grouping worship tiles under a labelled header.
class WorshipSectionWidget extends StatelessWidget {
  final WorshipSection section;
  final void Function(WorshipTemplate template) onItemTap;

  const WorshipSectionWidget({
    super.key,
    required this.section,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section header ──
        Padding(
          padding: EdgeInsetsDirectional.only(
            start: 4.w,
            bottom: 10.h,
            top: 4.h,
          ),
          child: Row(
            children: [
              Container(
                width: 30.w,
                height: 30.w,
                decoration: BoxDecoration(
                  color: section.accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  section.icon,
                  size: 16.sp,
                  color: section.accentColor,
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                section.title,
                style: TextStyles.headlineSmall.copyWith(
                  color: ColorsManager.primaryText,
                  fontWeight: FontWeight.w700,
                  fontSize: 16.sp,
                ),
              ),
            ],
          ),
        ),
        // ── Items ──
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: section.items.length,
          separatorBuilder: (_, __) => SizedBox(height: 6.h),
          itemBuilder: (_, i) {
            final item = section.items[i];
            return WorshipTile(
              title: item.title,
              icon: item.icon,
              accentColor: section.accentColor,
              onTap: () => onItemTap(item),
            );
          },
        ),
      ],
    );
  }
}
