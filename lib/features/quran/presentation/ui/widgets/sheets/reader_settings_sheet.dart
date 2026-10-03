import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/quran_decorations.dart';
import 'package:mishkat_almasabih/core/theming/quran_styles.dart';
import 'package:mishkat_almasabih/core/widgets/snackbars.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/mushaf_reader_settings.dart';
import 'package:mishkat_almasabih/features/quran/presentation/logic/mushaf_reader/mushaf_reader_cubit.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/helpers/quran_ui_helpers.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/widgets/common/quran_sheet.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/widgets/common/tajweed_guide_link.dart';
import 'package:mushaf_text/mushaf_text.dart';

Future<void> showReaderSettingsSheet(
  BuildContext context, {
  required MushafReaderCubit readerCubit,
  required MushafColors mushafColors,
}) {
  return showQuranSheet<void>(
    context: context,
    colors: QuranSurfaceColors.mushaf(mushafColors),
    initialChildSize: 0.64,
    builder:
        (context, controller) => BlocProvider.value(
          value: readerCubit,
          child: _ReaderSettingsContent(controller: controller),
        ),
  );
}

/// Repaints in the chosen paper as the reader switches theme, so the choice
/// previews itself.
class _ReaderSettingsContent extends StatelessWidget {
  final ScrollController controller;

  const _ReaderSettingsContent({required this.controller});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return BlocSelector<
      MushafReaderCubit,
      MushafReaderState,
      MushafReaderSettings
    >(
      selector:
          (state) =>
              state is MushafReaderReady
                  ? state.settings
                  : MushafReaderSettings.defaults,
      builder: (context, settings) {
        final mushaf = resolveMushafColors(settings.themeMode, brightness);
        final colors = QuranSurfaceColors.mushaf(mushaf);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          color: colors.background,
          child: ListView(
            controller: controller,
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 28.h),
            children: [
              QuranSheetHandle(colors: colors),
              SizedBox(height: 6.h),
              Text(
                'إعدادات القراءة',
                style: QuranTextStyles.sheetTitle(colors.title),
              ),
              SizedBox(height: 16.h),
              Text(
                'لون الصفحة',
                style: QuranTextStyles.sectionTitle(colors.title),
              ),
              SizedBox(height: 10.h),
              Row(
                children: [
                  for (final mode in MushafThemeMode.values) ...[
                    if (mode != MushafThemeMode.values.first)
                      SizedBox(width: 10.w),
                    Expanded(
                      child: _ThemeOption(
                        mode: mode,
                        preview: resolveMushafColors(mode, brightness),
                        selected: settings.themeMode == mode,
                        selectedBorder: colors.accent,
                        labelColor: colors.title,
                        onTap:
                            () => _apply(
                              context,
                              context.read<MushafReaderCubit>().setThemeMode(
                                mode,
                              ),
                            ),
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(height: 22.h),
              Text(
                'التجويد',
                style: QuranTextStyles.sectionTitle(colors.title),
              ),
              _SettingSwitch(
                colors: colors,
                title: 'تلوين أحكام التجويد',
                subtitle:
                    'يُلوَّن كل حكم بلونه، والمس أي حرف ملوّن لمعرفة حكمه ومرجعه.',
                value: settings.tajweedEnabled,
                onChanged:
                    (v) => _apply(
                      context,
                      context.read<MushafReaderCubit>().setTajweedEnabled(v),
                    ),
              ),
              _SettingSwitch(
                colors: colors,
                title: 'تلوين المدّ الطبيعي',
                subtitle: 'أكثر الأحكام تكرارًا، وتلوينه يصبغ معظم الصفحة.',
                value: settings.naturalMaddEnabled,
                onChanged:
                    settings.tajweedEnabled
                        ? (v) => _apply(
                          context,
                          context
                              .read<MushafReaderCubit>()
                              .setNaturalMaddEnabled(v),
                        )
                        : null,
              ),
              Divider(color: colors.border, height: 28.h),
              TajweedGuideLink(colors: colors),
            ],
          ),
        );
      },
    );
  }

  Future<void> _apply(BuildContext context, Future<bool> change) async {
    final saved = await change;
    if (!saved && context.mounted) {
      showErrorSnackbar(
        context,
        'تعذر حفظ الإعداد، سيُطبَّق في هذه الجلسة فقط',
      );
    }
  }
}

class _ThemeOption extends StatelessWidget {
  final MushafThemeMode mode;
  final MushafColors preview;
  final bool selected;
  final Color selectedBorder;
  final Color labelColor;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.mode,
    required this.preview,
    required this.selected,
    required this.selectedBorder,
    required this.labelColor,
    required this.onTap,
  });

  ({String label, IconData icon}) get _look => switch (mode) {
    MushafThemeMode.system => (
      label: 'تلقائي',
      icon: Icons.brightness_auto_rounded,
    ),
    MushafThemeMode.day => (label: 'نهاري', icon: Icons.light_mode_rounded),
    MushafThemeMode.night => (label: 'ليلي', icon: Icons.dark_mode_rounded),
  };

  @override
  Widget build(BuildContext context) {
    final look = _look;
    return Semantics(
      button: true,
      selected: selected,
      label: look.label,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 64.h,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: QuranDecorations.themeOption(
                preview,
                selected: selected,
                selectedBorder: selectedBorder,
              ),
              child: Text(
                'بِسۡمِ ٱللَّهِ',
                style: QuranTextStyles.mushafText(
                  color: preview.ink,
                  size: 18.sp,
                ),
              ),
            ),
            SizedBox(height: 6.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(look.icon, size: 14.sp, color: labelColor),
                SizedBox(width: 4.w),
                Text(
                  look.label,
                  style: QuranTextStyles.themeOptionLabel(
                    labelColor,
                    selected: selected,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingSwitch extends StatelessWidget {
  final QuranSurfaceColors colors;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const _SettingSwitch({
    required this.colors,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      value: value,
      onChanged: onChanged,
      activeThumbColor: colors.background,
      activeTrackColor: colors.accent,
      title: Text(title, style: QuranTextStyles.switchTitle(colors.title)),
      subtitle: Text(
        subtitle,
        style: QuranTextStyles.switchSubtitle(colors.subtitle),
      ),
    );
  }
}
