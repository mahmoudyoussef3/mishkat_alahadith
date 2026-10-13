import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/app_palette_override.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/core/widgets/app_icon_button.dart';

/// Header of a pushed screen: back button, title with an optional context
/// line, and trailing actions. Optional [bottom] content (a search field,
/// filters) sits under it, above the hairline.
class DetailHeader extends StatelessWidget {
  const DetailHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions = const [],
    this.bottom,
    this.showDivider = true,
  });

  final String title;
  final String? subtitle;

  /// Shown between the back button and the title, e.g. a category icon.
  final Widget? leading;
  final List<Widget> actions;
  final Widget? bottom;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final palette = AppPaletteOverride.of(context);
    final subtitle = this.subtitle;
    final bottom = this.bottom;

    return DecoratedBox(
      decoration: BoxDecoration(
        border:
            showDivider
                ? Border(bottom: BorderSide(color: palette.border))
                : null,
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                AppIconButton(
                  tooltip: 'رجوع',
                  icon: Icons.arrow_back_rounded,
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
                if (leading != null) ...[SizedBox(width: 10.w), leading!],
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(
                        header: true,
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyles.sectionTitle.copyWith(
                            fontSize: 17.sp,
                            height: 1.3,
                            color: palette.primaryText,
                          ),
                        ),
                      ),
                      if (subtitle != null && subtitle.isNotEmpty)
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
                for (final action in actions) ...[SizedBox(width: 8.w), action],
              ],
            ),
            if (bottom != null) ...[SizedBox(height: 12.h), bottom],
          ],
        ),
      ),
    );
  }
}
