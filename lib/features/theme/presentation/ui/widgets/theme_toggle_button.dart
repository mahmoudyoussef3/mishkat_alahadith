import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/home_decorations.dart';
import 'package:mishkat_almasabih/features/theme/domain/entities/app_theme_mode.dart';
import 'package:mishkat_almasabih/features/theme/presentation/logic/theme_cubit.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, AppThemeMode>(
      builder: (context, mode) {
        return Tooltip(
          message: mode.isDark ? 'الوضع النهاري' : 'الوضع الليلي',
          child: Material(
            color: HomeDecorations.appBarIconButtonBg(),
            borderRadius: BorderRadius.circular(12.r),
            child: InkWell(
              onTap: () => context.read<ThemeCubit>().toggle(),
              borderRadius: BorderRadius.circular(12.r),
              child: Container(
                width: 40.w,
                height: 40.w,
                decoration: HomeDecorations.appBarIconButtonBorder(),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  transitionBuilder: _rotateAndFade,
                  child: Icon(
                    mode.isDark
                        ? Icons.light_mode_rounded
                        : Icons.dark_mode_rounded,
                    key: ValueKey(mode),
                    color:
                        mode.isDark
                            ? ColorsManager.primaryGold
                            : ColorsManager.white,
                    size: 20.sp,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget _rotateAndFade(Widget child, Animation<double> animation) {
    return RotationTransition(
      turns: Tween<double>(begin: 0.75, end: 1).animate(animation),
      child: FadeTransition(
        opacity: animation,
        child: ScaleTransition(scale: animation, child: child),
      ),
    );
  }
}
