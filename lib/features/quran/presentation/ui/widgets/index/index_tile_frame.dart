import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/quran_decorations.dart';
import 'package:mishkat_almasabih/core/theming/quran_styles.dart';

/// The card every index row sits in: a badge, two lines, and a trailing slot.
class IndexTileFrame extends StatelessWidget {
  final QuranSurfaceColors colors;
  final Widget leading;
  final Widget title;
  final String subtitle;
  final Widget? trailing;
  final bool isCurrent;
  final VoidCallback onTap;

  const IndexTileFrame({
    super.key,
    required this.colors,
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
    this.isCurrent = false,
  });

  @override
  Widget build(BuildContext context) {
    final trailing = this.trailing;
    return Material(
      type: MaterialType.transparency,
      child: Ink(
        decoration: QuranDecorations.indexTile(colors, isCurrent: isCurrent),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            child: Row(
              children: [
                leading,
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      title,
                      SizedBox(height: 2.h),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: QuranTextStyles.tileMeta(colors.subtitle),
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
    );
  }
}

/// A number set in a diamond — the octagonal frame of a surah number in print.
class IndexNumberBadge extends StatelessWidget {
  final String label;
  final QuranSurfaceColors colors;

  const IndexNumberBadge({
    super.key,
    required this.label,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final side = 30.r;
    return SizedBox(
      width: 42.r,
      height: 42.r,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: 0.785398, // 45°
            child: Container(
              width: side,
              height: side,
              decoration: QuranDecorations.numberBadge(colors),
            ),
          ),
          Text(label, style: QuranTextStyles.numberBadge(colors.accent)),
        ],
      ),
    );
  }
}
