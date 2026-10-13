import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/core/widgets/app_icon_button.dart';

/// Marks screens hosted inside another screen, such as a bottom-navigation
/// tab, so they do not show a back button of their own.
class EmbeddedScreenScope extends InheritedWidget {
  const EmbeddedScreenScope({super.key, required super.child});

  static bool isEmbedded(BuildContext context) =>
      context.getInheritedWidgetOfExactType<EmbeddedScreenScope>() != null;

  @override
  bool updateShouldNotify(EmbeddedScreenScope oldWidget) => false;
}

/// Large page title for top-level screens ("المكتبة", "البحث").
///
/// Shows a back button when the screen was pushed as its own page, and none
/// inside an [EmbeddedScreenScope], so the same screen works both ways.
class ScreenTitleHeader extends StatelessWidget {
  const ScreenTitleHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.padding,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final canPop =
        !EmbeddedScreenScope.isEmbedded(context) &&
        (ModalRoute.of(context)?.impliesAppBarDismissal ?? false);
    final subtitle = this.subtitle;

    return Padding(
      padding: padding ?? EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 0),
      child: Row(
        children: [
          if (canPop) ...[
            AppIconButton(
              tooltip: 'رجوع',
              icon: Icons.arrow_back_rounded,
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            SizedBox(width: 12.w),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  child: Text(title, style: TextStyles.screenTitle),
                ),
                if (subtitle != null && subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: TextStyles.caption.copyWith(fontSize: 13.sp),
                  ),
              ],
            ),
          ),
          if (trailing != null) ...[SizedBox(width: 12.w), trailing!],
        ],
      ),
    );
  }
}
