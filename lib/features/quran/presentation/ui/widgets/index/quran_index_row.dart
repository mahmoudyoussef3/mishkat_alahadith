import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/app_palette_override.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:shimmer/shimmer.dart';

/// "السور" with how many are listed, above a [QuranIndexCard].
class QuranIndexHeader extends StatelessWidget {
  const QuranIndexHeader({
    super.key,
    required this.title,
    required this.shown,
    required this.total,
  });

  final String title;
  final String shown;
  final String total;

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
            shown == total ? total : '$shown من $total',
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

/// Paints one bordered card behind a list of [QuranIndexRow]s.
class QuranIndexCard extends StatelessWidget {
  const QuranIndexCard({super.key, required this.sliver});

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

/// One row of the index: a leading well, a title with a line under it, and
/// an optional trailing widget. [isFirst] and [isLast] round the ink to the
/// card the rows share.
class QuranIndexRow extends StatelessWidget {
  const QuranIndexRow({
    super.key,
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.isFirst,
    required this.isLast,
    this.trailing,
  });

  final Widget leading;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isFirst;
  final bool isLast;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final palette = AppPaletteOverride.of(context);
    final radius = Radius.circular(20.r);
    final trailing = this.trailing;

    return Column(
      children: [
        if (!isFirst) Divider(height: 1, color: palette.lightGray),
        Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.vertical(
              top: isFirst ? radius : Radius.zero,
              bottom: isLast ? radius : Radius.zero,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              child: Row(
                children: [
                  leading,
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            height: 1.5,
                            color: palette.primaryText,
                          ),
                        ),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyles.caption.copyWith(
                            color: palette.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (trailing != null) ...[SizedBox(width: 8.w), trailing],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// A number, or an icon, in a rounded well at the start of a row. The
/// place being read is marked in gold.
class QuranIndexWell extends StatelessWidget {
  const QuranIndexWell({
    super.key,
    this.label,
    this.icon,
    this.highlighted = false,
    this.background,
    this.foreground,
  }) : assert(label != null || icon != null);

  final String? label;
  final IconData? icon;
  final bool highlighted;
  final Color? background;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final palette = AppPaletteOverride.of(context);
    final (fill, ink) =
        highlighted
            ? (palette.goldBright, palette.onGoldBright)
            : (
              background ?? palette.primarySoft,
              foreground ?? palette.purpleText,
            );
    final label = this.label;

    return Container(
      width: 38.r,
      height: 38.r,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child:
          label == null
              ? Icon(icon, size: 20.r, color: ink)
              : FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Text(
                    label,
                    style: TextStyles.titleSmall.copyWith(
                      fontWeight: FontWeight.w800,
                      color: ink,
                    ),
                  ),
                ),
              ),
    );
  }
}

/// The page a row opens at: «ص ٢٢».
class QuranPageLabel extends StatelessWidget {
  const QuranPageLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyles.caption.copyWith(
        fontWeight: FontWeight.w700,
        color: AppPaletteOverride.of(context).secondaryText,
      ),
    );
  }
}

/// Placeholder rows while the index loads.
class QuranIndexShimmer extends StatelessWidget {
  const QuranIndexShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = AppPaletteOverride.of(context);
    final block = palette.shimmerBase;
    return QuranIndexCard(
      sliver: SliverList.builder(
        itemCount: 8,
        itemBuilder:
            (context, index) => Shimmer.fromColors(
              baseColor: palette.shimmerBase,
              highlightColor: palette.shimmerHighlight,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                child: Row(
                  children: [
                    Container(
                      width: 38.r,
                      height: 38.r,
                      decoration: BoxDecoration(
                        color: block,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(width: 110.w, height: 14.h, color: block),
                          SizedBox(height: 8.h),
                          Container(width: 160.w, height: 10.h, color: block),
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
