import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/widgets/app_icon_button.dart';
import 'package:mishkat_almasabih/features/theme/domain/entities/app_theme_mode.dart';
import 'package:mishkat_almasabih/features/theme/presentation/logic/theme_cubit.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, AppThemeMode>(
      builder: (context, mode) {
        return AppIconButton(
          tooltip: mode.isDark ? 'الوضع النهاري' : 'الوضع الليلي',
          onPressed: () => context.read<ThemeCubit>().toggle(),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            transitionBuilder: _rotateAndFade,
            child: Icon(
              mode.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              key: ValueKey(mode),
              color: mode.isDark ? ColorsManager.primaryGold : null,
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
