import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/profile_styles.dart';
import 'package:mishkat_almasabih/core/theming/profile_decorations.dart';
import 'package:mishkat_almasabih/features/theme/domain/entities/app_theme_mode.dart';
import 'package:mishkat_almasabih/features/theme/presentation/logic/theme_cubit.dart';

class DarkModeToggle extends StatelessWidget {
  const DarkModeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, AppThemeMode>(
      builder: (context, mode) {
        return Container(
          padding: EdgeInsets.all(16.w),
          decoration: ProfileDecorations.darkModeCard(),
          child: Row(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  mode.isDark ? FontAwesomeIcons.moon : FontAwesomeIcons.sun,
                  key: ValueKey(mode),
                  color:
                      mode.isDark
                          ? ColorsManager.primaryGold
                          : ColorsManager.primaryPurple,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("الوضع الليلي", style: ProfileTextStyles.darkModeTitle),
                    SizedBox(height: 2.h),
                    Text(
                      mode.isDark ? "مفعّل" : "معطّل",
                      style: ProfileTextStyles.darkModeStatus,
                    ),
                  ],
                ),
              ),
              Switch(
                value: mode.isDark,
                onChanged: (_) => context.read<ThemeCubit>().toggle(),
                activeThumbColor: ColorsManager.white,
                activeTrackColor: ProfileDecorations.darkModeSwitchActiveColor,
              ),
            ],
          ),
        );
      },
    );
  }
}
