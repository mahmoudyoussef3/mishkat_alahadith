import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/extensions.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/features/home/presentation/ui/widgets/home_prayer_strip.dart';

/// Four quick ways into the app's companion tools.
class HomeShortcuts extends StatelessWidget {
  const HomeShortcuts({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Shortcut(
          icon: Icons.menu_book_rounded,
          label: 'المصحف',
          foreground: ColorsManager.primaryGold,
          background: ColorsManager.goldSoft,
          onTap: () => context.pushNamed(Routes.quranScreen),
        ),
        _Shortcut(
          icon: Icons.explore_rounded,
          label: 'القبلة',
          foreground: ColorsManager.success,
          background: ColorsManager.successSoft,
          onTap: () => context.pushNamed(Routes.qiblahFinder),
        ),
        _Shortcut(
          icon: Icons.schedule_rounded,
          label: 'المواقيت',
          foreground: ColorsManager.purpleText,
          background: ColorsManager.primarySoft,
          onTap: () => openPrayerTimesFromHome(context),
        ),
        _Shortcut(
          icon: Icons.category_rounded,
          label: 'التصنيفات',
          foreground: ColorsManager.purpleText,
          background: ColorsManager.primarySoft,
          onTap: () => context.pushNamed(Routes.categoriesScreen),
        ),
      ],
    );
  }
}

class _Shortcut extends StatelessWidget {
  const _Shortcut({
    required this.icon,
    required this.label,
    required this.foreground,
    required this.background,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color foreground;
  final Color background;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        button: true,
        label: label,
        excludeSemantics: true,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18.r),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 4.h),
            child: Column(
              children: [
                Container(
                  width: 56.r,
                  height: 56.r,
                  decoration: BoxDecoration(
                    color: background,
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                  child: Icon(icon, size: 26.r, color: foreground),
                ),
                SizedBox(height: 6.h),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyles.chipLabel.copyWith(
                    fontWeight: FontWeight.w600,
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
