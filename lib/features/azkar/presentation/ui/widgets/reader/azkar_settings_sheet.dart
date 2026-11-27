import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/app_palette_override.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/core/widgets/app_switch.dart';
import 'package:mishkat_almasabih/core/widgets/font_size_stepper.dart';
import 'package:mishkat_almasabih/core/widgets/segmented_tabs.dart';
import 'package:mishkat_almasabih/core/widgets/settings_group.dart';
import 'package:mishkat_almasabih/features/azkar/domain/entities/azkar_settings.dart';
import 'package:mishkat_almasabih/features/azkar/presentation/logic/azkar_reader/azkar_reader_cubit.dart';
import 'package:mishkat_almasabih/features/azkar/presentation/ui/helpers/azkar_ui_helpers.dart';

/// Text size, translation and counting preferences, applied as they change.
Future<void> showAzkarSettingsSheet(BuildContext context) {
  final cubit = context.read<AzkarReaderCubit>();
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder:
        (_) => BlocProvider.value(
          value: cubit,
          child: const Directionality(
            textDirection: TextDirection.rtl,
            child: _AzkarSettingsSheet(),
          ),
        ),
  );
}

class _AzkarSettingsSheet extends StatelessWidget {
  const _AzkarSettingsSheet();

  static const _sample =
      'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ، سُبْحَانَ اللَّهِ الْعَظِيمِ';

  @override
  Widget build(BuildContext context) {
    final palette = AppPaletteOverride.of(context);
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
        child: BlocSelector<AzkarReaderCubit, AzkarReaderState, AzkarSettings?>(
          selector:
              (state) => state is AzkarReaderLoaded ? state.settings : null,
          builder: (context, settings) {
            if (settings == null) return const SizedBox.shrink();
            final cubit = context.read<AzkarReaderCubit>();
            void apply(AzkarSettings next) => cubit.updateSettings(next);

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('إعدادات القراءة', style: TextStyles.sectionTitle),
                Text(
                  'تُطبَّق على جميع أبواب الأذكار',
                  style: TextStyles.caption.copyWith(fontSize: 13.sp),
                ),
                SizedBox(height: 16.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 18.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: palette.cardBackground,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: palette.border),
                  ),
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 180),
                    alignment: Alignment.topCenter,
                    child: Text(
                      _sample,
                      textAlign: TextAlign.center,
                      style: TextStyles.readingMedium.copyWith(
                        fontSize: 19.sp * settings.fontScale.factor,
                        height: 2.0,
                        color: palette.primaryText,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                FontSizeStepper(
                  labels: [
                    for (final scale in AzkarFontScale.values) scale.label,
                  ],
                  selectedIndex: settings.fontScale.index,
                  onChanged:
                      (index) => apply(
                        settings.copyWith(
                          fontScale: AzkarFontScale.values[index],
                        ),
                      ),
                ),
                SizedBox(height: 20.h),
                const SettingsGroupTitle('الترجمة تحت النص العربي'),
                SizedBox(height: 8.h),
                SegmentedTabs(
                  labels: [
                    for (final translation in AzkarTranslation.values)
                      translation.label,
                  ],
                  selectedIndex: settings.translation.index,
                  onChanged:
                      (index) => apply(
                        settings.copyWith(
                          translation: AzkarTranslation.values[index],
                        ),
                      ),
                ),
                SizedBox(height: 20.h),
                SettingsGroup(
                  title: 'العدّ',
                  children: [
                    _SwitchRow(
                      icon: Icons.vibration_rounded,
                      title: 'الاهتزاز مع كل عدّة',
                      value: settings.hapticFeedback,
                      onChanged:
                          (value) =>
                              apply(settings.copyWith(hapticFeedback: value)),
                    ),
                    _SwitchRow(
                      icon: Icons.keyboard_double_arrow_down_rounded,
                      title: 'الانتقال إلى الذكر التالي تلقائياً',
                      value: settings.autoAdvance,
                      onChanged:
                          (value) =>
                              apply(settings.copyWith(autoAdvance: value)),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('تم'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = AppPaletteOverride.of(context);
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            Icon(icon, size: 22.r, color: palette.purpleText),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                title,
                style: TextStyles.titleSmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: palette.primaryText,
                ),
              ),
            ),
            AppSwitch(value: value, onChanged: onChanged, semanticLabel: title),
          ],
        ),
      ),
    );
  }
}
