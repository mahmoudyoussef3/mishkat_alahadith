import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';

/// Titled card of settings rows separated by hairlines, with optional
/// content (such as a hint) below the card.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({
    super.key,
    required this.title,
    required this.children,
    this.footer,
  });

  final String title;
  final List<Widget> children;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Semantics(
            header: true,
            child: Text(
              title,
              style: TextStyles.caption.copyWith(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Material(
          color: ColorsManager.cardBackground,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
            side: BorderSide(color: ColorsManager.border),
          ),
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) Divider(height: 1, color: ColorsManager.lightGray),
                children[i],
              ],
            ],
          ),
        ),
        if (footer != null) ...[SizedBox(height: 8.h), footer!],
      ],
    );
  }
}

/// One row of a [SettingsGroup]: tinted icon, title, optional subtitle and
/// a trailing control. Tappable rows without a [trailing] widget show a
/// forward chevron.
class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor,
    this.iconBackground,
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? iconBackground;

  /// Draws the row in the error colour, e.g. for signing out.
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final subtitle = this.subtitle;
    final (wellColor, glyphColor) =
        destructive
            ? (ColorsManager.errorSoft, ColorsManager.error)
            : (
              iconBackground ?? ColorsManager.primarySoft,
              iconColor ?? ColorsManager.purpleText,
            );
    final trailing =
        this.trailing ??
        (onTap != null && !destructive
            ? Icon(
              Icons.chevron_right_rounded,
              size: 20.r,
              color: ColorsManager.gray,
            )
            : null);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                color: wellColor,
                borderRadius: BorderRadius.circular(13.r),
              ),
              child: Icon(icon, size: 21.r, color: glyphColor),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color:
                          destructive
                              ? ColorsManager.error
                              : ColorsManager.primaryText,
                    ),
                  ),
                  if (subtitle != null && subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: TextStyles.caption.copyWith(height: 1.6),
                    ),
                ],
              ),
            ),
            if (trailing != null) ...[SizedBox(width: 12.w), trailing],
          ],
        ),
      ),
    );
  }
}
