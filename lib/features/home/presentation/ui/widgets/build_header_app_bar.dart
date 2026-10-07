import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/extensions.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/core/widgets/app_icon_button.dart';

/// Light top bar for pushed screens: back (or menu) button, title with an
/// optional description, and trailing actions. Stays pinned so its actions
/// remain reachable while reading.
class BuildHeaderAppBar extends StatelessWidget {
  const BuildHeaderAppBar({
    super.key,
    this.description,
    required this.title,
    this.home = false,
    this.pinned = false,
    this.actions,
    this.bottomNav = false,
  });

  final String title;
  final String? description;

  /// Shows a menu button that opens the drawer instead of a back button.
  final bool home;

  /// Kept for call-site compatibility; the bar is always pinned.
  final bool pinned;
  final bool bottomNav;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final description = this.description;
    final actions = this.actions ?? const <Widget>[];

    return SliverAppBar(
      pinned: true,
      automaticallyImplyLeading: false,
      toolbarHeight: 64.h,
      titleSpacing: 16.w,
      backgroundColor: ColorsManager.secondaryBackground,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: ColorsManager.border,
      centerTitle: false,
      title: Row(
        children: [
          AppIconButton(
            tooltip: home ? 'القائمة' : 'رجوع',
            icon: home ? Icons.menu_rounded : Icons.arrow_back_rounded,
            onPressed: () {
              if (home) {
                Scaffold.of(context).openDrawer();
              } else {
                context.pop();
              }
            },
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                  ),
                ),
                if (description != null && description.isNotEmpty)
                  Text(
                    description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyles.caption,
                  ),
              ],
            ),
          ),
          for (final action in actions) ...[SizedBox(width: 8.w), action],
        ],
      ),
    );
  }
}

/// Header action in the same rounded-square style as the back button.
class AppBarActionButton extends StatelessWidget {
  const AppBarActionButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return AppIconButton(icon: icon, onPressed: onPressed, tooltip: tooltip);
  }
}
