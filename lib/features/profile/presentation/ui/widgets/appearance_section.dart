import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/core/widgets/app_switch.dart';
import 'package:mishkat_almasabih/core/widgets/settings_group.dart';
import 'package:mishkat_almasabih/features/reading_preferences/domain/entities/hadith_font_scale.dart';
import 'package:mishkat_almasabih/features/reading_preferences/presentation/logic/hadith_font_scale_cubit.dart';
import 'package:mishkat_almasabih/features/reading_preferences/presentation/ui/hadith_font_size_sheet.dart';
import 'package:mishkat_almasabih/features/theme/domain/entities/app_theme_mode.dart';
import 'package:mishkat_almasabih/features/theme/presentation/logic/theme_cubit.dart';

/// Night mode and hadith text size.
class AppearanceSection extends StatelessWidget {
  const AppearanceSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsGroup(
      title: 'المظهر',
      children: [
        BlocBuilder<ThemeCubit, AppThemeMode>(
          builder: (context, mode) {
            final toggle = context.read<ThemeCubit>().toggle;
            return SettingsTile(
              icon: Icons.dark_mode_rounded,
              title: 'الوضع الليلي',
              subtitle: mode.isDark ? 'مفعّل' : 'معطّل',
              onTap: toggle,
              trailing: AppSwitch(
                value: mode.isDark,
                semanticLabel: 'الوضع الليلي',
                onChanged: (_) => toggle(),
              ),
            );
          },
        ),
        BlocBuilder<HadithFontScaleCubit, HadithFontScale>(
          builder:
              (context, scale) => SettingsTile(
                icon: Icons.format_size_rounded,
                title: 'حجم خط الحديث',
                subtitle: scale.label,
                onTap: () => showHadithFontSizeSheet(context),
              ),
        ),
      ],
    );
  }
}
