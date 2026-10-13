import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/core/widgets/app_icon_button.dart';
import 'package:mishkat_almasabih/features/theme/presentation/ui/widgets/theme_toggle_button.dart';

/// Brand row at the top of Home: logo, name and motto, theme and menu.
class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14.r),
          child: ColoredBox(
            color: ColorsManager.primarySoft,
            child: Image.asset(
              'assets/images/app_logo.png',
              width: 44.r,
              height: 44.r,
              fit: BoxFit.cover,
              excludeFromSemantics: true,
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(
                  'مشكاة الأحاديث',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyles.sectionTitle.copyWith(
                    fontSize: 20.sp,
                    height: 1.3,
                  ),
                ),
              ),
              Text(
                'نُحْيِي السُّنَّةَ... فَتُحْيِينَا',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyles.caption,
              ),
            ],
          ),
        ),
        const ThemeToggleButton(),
        SizedBox(width: 8.w),
        AppIconButton(
          tooltip: 'القائمة',
          icon: Icons.menu_rounded,
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ],
    );
  }
}
