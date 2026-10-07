import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/app_palette_override.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/mushaf_palette.dart';
import 'package:mishkat_almasabih/core/theming/quran_styles.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/core/widgets/app_icon_button.dart';
import 'package:mishkat_almasabih/core/widgets/app_switch.dart';
import 'package:mishkat_almasabih/core/widgets/segmented_tabs.dart';
import 'package:mishkat_almasabih/core/widgets/settings_group.dart';
import 'package:mishkat_almasabih/core/widgets/snackbars.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/mushaf_reader_settings.dart';
import 'package:mishkat_almasabih/features/quran/presentation/logic/mushaf_reader/mushaf_reader_cubit.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/helpers/quran_ui_helpers.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/widgets/common/quran_sheet.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/widgets/common/tajweed_guide_tile.dart';
import 'package:mushaf_text/mushaf_text.dart';

/// [appBrightness] is the app's own, which automatic paper follows; the
/// theme around the reader is the paper's, so it cannot say.
Future<void> showReaderSettingsSheet(
  BuildContext context, {
  required MushafReaderCubit readerCubit,
  required Brightness appBrightness,
}) {
  return showQuranSheet<void>(
    context: context,
    initialChildSize: 0.72,
    builder:
        (context, controller) => BlocProvider.value(
          value: readerCubit,
          child: _ReaderSettingsContent(
            controller: controller,
            appBrightness: appBrightness,
          ),
        ),
  );
}

/// Repaints in the chosen paper as the reader switches theme, so the choice
/// previews itself.
class _ReaderSettingsContent extends StatelessWidget {
  final ScrollController controller;
  final Brightness appBrightness;

  const _ReaderSettingsContent({
    required this.controller,
    required this.appBrightness,
  });

  @override
  Widget build(BuildContext context) {
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
        final palette = readerPalette(settings.themeMode, appBrightness);
        final cubit = context.read<MushafReaderCubit>();
        return AppPaletteOverride(
          palette: palette,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            color: palette.elevatedSurface,
            child: ListView(
              controller: controller,
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
              children: [
                const QuranSheetHandle(),
                const QuranSheetHeader(
                  title: 'إعدادات القراءة',
                  subtitle: 'تُحفظ اختياراتك وتُطبَّق كلما فتحت المصحف',
                ),
                SizedBox(height: 18.h),
                const SettingsGroupTitle('لون الصفحة'),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    for (final mode in MushafThemeMode.values) ...[
                      if (mode != MushafThemeMode.values.first)
                        SizedBox(width: 10.w),
                      Expanded(
                        child: _ThemeOption(
                          mode: mode,
                          preview: MushafPalette.of(
                            readerPalette(mode, appBrightness),
                          ),
                          selected: settings.themeMode == mode,
                          onTap:
                              () => _apply(context, cubit.setThemeMode(mode)),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 22.h),
                const SettingsGroupTitle('طريقة العرض'),
                SizedBox(height: 8.h),
                SegmentedTabs(
                  labels: [
                    for (final mode in MushafLayoutMode.values) mode.label,
                  ],
                  selectedIndex: settings.layoutMode.index,
                  onChanged:
                      (index) => _apply(
                        context,
                        cubit.setLayoutMode(MushafLayoutMode.values[index]),
                      ),
                ),
                SizedBox(height: 8.h),
                _Hint(settings.layoutMode.description),
                SizedBox(height: 22.h),
                const SettingsGroupTitle('حجم خط الآيات'),
                SizedBox(height: 8.h),
                _FontSizePreview(
                  scale: settings.fontScale,
                  colors: MushafPalette.of(palette),
                ),
                SizedBox(height: 12.h),
                _FontScalePicker(
                  scale: settings.fontScale,
                  onChanged:
                      (scale) => _apply(context, cubit.setFontScale(scale)),
                ),
                if (settings.layoutMode == MushafLayoutMode.page) ...[
                  SizedBox(height: 8.h),
                  const _Hint(
                    'صفحة المصحف تملأ عرض الشاشة بسطورها كما طُبعت، فيُطبَّق '
                    'الحجم على النص المتدفق ونافذة الآية.',
                  ),
                ],
                SizedBox(height: 22.h),
                SettingsGroup(
                  title: 'التجويد',
                  children: [
                    _SwitchTile(
                      icon: Icons.palette_rounded,
                      title: 'تلوين أحكام التجويد',
                      subtitle:
                          'يُلوَّن كل حكم بلونه، والمس أي حرف ملوّن لمعرفة '
                          'حكمه ومرجعه.',
                      value: settings.tajweedEnabled,
                      onChanged:
                          (v) => _apply(context, cubit.setTajweedEnabled(v)),
                    ),
                    _SwitchTile(
                      icon: Icons.linear_scale_rounded,
                      title: 'تلوين المدّ الطبيعي',
                      subtitle:
                          settings.tajweedEnabled
                              ? 'أكثر الأحكام تكرارًا، وتلوينه يصبغ معظم '
                                  'الصفحة.'
                              : 'فعّل تلوين أحكام التجويد أولًا.',
                      value: settings.naturalMaddEnabled,
                      onChanged:
                          settings.tajweedEnabled
                              ? (v) => _apply(
                                context,
                                cubit.setNaturalMaddEnabled(v),
                              )
                              : null,
                    ),
                  ],
                ),
                SizedBox(height: 22.h),
                const TajweedGuideTile(),
                SizedBox(height: 20.h),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('تم'),
                ),
              ],
            ),
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

extension on MushafLayoutMode {
  String get label => switch (this) {
    MushafLayoutMode.page => 'صفحة المصحف',
    MushafLayoutMode.flowing => 'نص متدفق',
  };

  String get description => switch (this) {
    MushafLayoutMode.page =>
      'السطور كما في المصحف المطبوع، بحجم يملأ عرض الشاشة.',
    MushafLayoutMode.flowing =>
      'الآيات نصًّا متصلًا بالحجم الذي تختاره، وتُمرَّر الصفحة إلى الأسفل.',
  };
}

/// A line of explanation under a setting.
class _Hint extends StatelessWidget {
  final String text;

  const _Hint(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Text(
        text,
        style: TextStyles.caption.copyWith(
          fontSize: 12.5.sp,
          height: 1.6,
          color: AppPaletteOverride.of(context).secondaryText,
        ),
      ),
    );
  }
}

/// An ayah at the chosen size, on the reader's paper.
class _FontSizePreview extends StatelessWidget {
  static const String _sample = 'ٱلۡحَمۡدُ لِلَّهِ رَبِّ ٱلۡعَٰلَمِينَ';

  final QuranFontScale scale;
  final MushafColors colors;

  const _FontSizePreview({required this.scale, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: colors.paper,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppPaletteOverride.of(context).border),
      ),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 180),
        alignment: Alignment.topCenter,
        child: Text(
          _sample,
          textAlign: TextAlign.center,
          style: QuranTextStyles.mushafText(
            color: colors.ink,
            size: quranFontSize(scale),
          ),
        ),
      ),
    );
  }
}

/// Smaller and larger buttons around the sizes, each named by its share of
/// the designed size.
class _FontScalePicker extends StatelessWidget {
  final QuranFontScale scale;
  final ValueChanged<QuranFontScale> onChanged;

  const _FontScalePicker({required this.scale, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppIconButton(
          tooltip: 'تصغير الخط',
          icon: Icons.text_decrease_rounded,
          onPressed: scale.isSmallest ? null : () => onChanged(scale.smaller),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: SegmentedTabs(
            labels: [
              for (final option in QuranFontScale.values)
                '${toArabicNumerals((option.factor * 100).round())}٪',
            ],
            selectedIndex: scale.index,
            onChanged: (index) => onChanged(QuranFontScale.values[index]),
          ),
        ),
        SizedBox(width: 8.w),
        AppIconButton(
          tooltip: 'تكبير الخط',
          icon: Icons.text_increase_rounded,
          onPressed: scale.isLargest ? null : () => onChanged(scale.larger),
        ),
      ],
    );
  }
}

/// A settings row whose whole width toggles its switch.
class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final onChanged = this.onChanged;
    return SettingsTile(
      icon: icon,
      title: title,
      subtitle: subtitle,
      onTap: onChanged == null ? null : () => onChanged(!value),
      trailing: AppSwitch(
        value: value,
        onChanged: onChanged,
        semanticLabel: title,
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final MushafThemeMode mode;
  final MushafColors preview;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.mode,
    required this.preview,
    required this.selected,
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
    final palette = AppPaletteOverride.of(context);
    final look = _look;
    final ink = selected ? palette.purpleText : palette.secondaryText;

    return Semantics(
      button: true,
      selected: selected,
      label: look.label,
      onTap: onTap,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 72.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: preview.paper,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: selected ? palette.primaryPurple : palette.border,
                  width: selected ? 2 : 1,
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      'بِسۡمِ ٱللَّهِ',
                      style: QuranTextStyles.mushafText(
                        color: preview.ink,
                        size: 18.sp,
                      ),
                    ),
                  ),
                  if (selected)
                    PositionedDirectional(
                      top: 6.r,
                      start: 6.r,
                      child: Container(
                        width: 18.r,
                        height: 18.r,
                        decoration: BoxDecoration(
                          color: palette.primaryPurple,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          size: 13.r,
                          color: ColorsManager.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(look.icon, size: 15.r, color: ink),
                SizedBox(width: 4.w),
                Text(
                  look.label,
                  style: TextStyles.chipLabel.copyWith(
                    fontSize: 12.5.sp,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                    color: ink,
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
