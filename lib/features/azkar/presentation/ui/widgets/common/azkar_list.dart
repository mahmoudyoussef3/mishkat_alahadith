import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/app_palette_override.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:shimmer/shimmer.dart';

/// A list title with how many items it shows: «الأبواب ١٣٢».
class AzkarListHeader extends StatelessWidget {
  const AzkarListHeader({super.key, required this.title, required this.count});

  final String title;
  final String count;

  @override
  Widget build(BuildContext context) {
    final palette = AppPaletteOverride.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                title,
                style: TextStyles.sectionTitle.copyWith(
                  fontSize: 16.sp,
                  color: palette.primaryText,
                ),
              ),
            ),
          ),
          Text(
            count,
            style: TextStyles.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: palette.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}

/// Paints one bordered card behind a sliver of rows.
class AzkarListCard extends StatelessWidget {
  const AzkarListCard({super.key, required this.sliver});

  final Widget sliver;

  @override
  Widget build(BuildContext context) {
    final palette = AppPaletteOverride.of(context);
    return DecoratedSliver(
      decoration: BoxDecoration(
        color: palette.cardBackground,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: palette.border),
      ),
      sliver: sliver,
    );
  }
}

/// Placeholder rows while the chapters load.
class AzkarListShimmer extends StatelessWidget {
  const AzkarListShimmer({super.key, this.rows = 8});

  final int rows;

  @override
  Widget build(BuildContext context) {
    final palette = AppPaletteOverride.of(context);
    final block = palette.shimmerBase;
    return AzkarListCard(
      sliver: SliverList.builder(
        itemCount: rows,
        itemBuilder:
            (context, index) => Shimmer.fromColors(
              baseColor: palette.shimmerBase,
              highlightColor: palette.shimmerHighlight,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                child: Row(
                  children: [
                    Container(
                      width: 42.r,
                      height: 42.r,
                      decoration: BoxDecoration(
                        color: block,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(width: 150.w, height: 14.h, color: block),
                          SizedBox(height: 8.h),
                          Container(width: 90.w, height: 10.h, color: block),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ),
    );
  }
}
