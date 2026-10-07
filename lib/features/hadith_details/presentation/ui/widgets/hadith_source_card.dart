import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';

/// One labelled fact about where a hadith comes from.
class HadithSourceRow {
  const HadithSourceRow(this.icon, this.label, this.value);

  final IconData icon;
  final String label;
  final String value;
}

/// "المصدر": the book, author and chapter a hadith is recorded in. Rows
/// with no value are left out; with none at all, nothing is shown.
class HadithSourceCard extends StatelessWidget {
  const HadithSourceCard({super.key, required this.rows});

  final List<HadithSourceRow> rows;

  @override
  Widget build(BuildContext context) {
    final visible = rows.where((row) => row.value.trim().isNotEmpty).toList();
    if (visible.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Text(
            'المصدر',
            style: TextStyles.caption.copyWith(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            color: ColorsManager.cardBackground,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: ColorsManager.border),
          ),
          child: Column(
            children: [
              for (var i = 0; i < visible.length; i++) ...[
                if (i > 0) Divider(height: 1, color: ColorsManager.lightGray),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        visible[i].icon,
                        size: 20.r,
                        color: ColorsManager.purpleText,
                      ),
                      SizedBox(width: 12.w),
                      SizedBox(
                        width: 96.w,
                        child: Text(
                          visible[i].label,
                          style: TextStyles.caption.copyWith(fontSize: 13.sp),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          visible[i].value,
                          style: TextStyles.titleSmall.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
