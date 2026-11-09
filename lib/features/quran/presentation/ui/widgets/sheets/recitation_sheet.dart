import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/di/dependency_injection.dart';
import 'package:mishkat_almasabih/core/theming/app_palette_override.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/core/widgets/app_switch.dart';
import 'package:mishkat_almasabih/core/widgets/segmented_tabs.dart';
import 'package:mishkat_almasabih/core/widgets/settings_group.dart';
import 'package:mishkat_almasabih/core/widgets/snackbars.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_edition.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_hizb_quarter.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/recitation.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/recitation_settings.dart';
import 'package:mishkat_almasabih/features/quran/presentation/logic/hizb_index/quran_hizb_index_cubit.dart';
import 'package:mishkat_almasabih/features/quran/presentation/logic/mushaf_reader/mushaf_reader_cubit.dart';
import 'package:mishkat_almasabih/features/quran/presentation/logic/recitation/quran_recitation_cubit.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/helpers/quran_cloud_labels.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/helpers/quran_ui_helpers.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/widgets/common/edition_picker_sheet.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/widgets/common/quran_sheet.dart';
import 'package:mushaf_text/mushaf_text.dart' show toArabicNumerals;

/// The reciter, where to start listening from the page being read, and how
/// the recitation plays.
Future<void> showRecitationSheet(
  BuildContext context, {
  required MushafReaderCubit readerCubit,
  required QuranRecitationCubit recitationCubit,
}) {
  return showQuranSheet<void>(
    context: context,
    initialChildSize: 0.8,
    maxChildSize: 0.95,
    builder:
        (context, controller) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: readerCubit),
            BlocProvider.value(value: recitationCubit),
            BlocProvider(
              create: (_) => getIt<QuranHizbIndexCubit>()..loadIfNeeded(),
            ),
          ],
          child: _RecitationSheetContent(controller: controller),
        ),
  );
}

class _RecitationSheetContent extends StatelessWidget {
  final ScrollController controller;

  const _RecitationSheetContent({required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: controller,
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
      children: [
        const QuranSheetHandle(),
        const QuranSheetHeader(
          title: 'الاستماع إلى التلاوة',
          subtitle: 'تُظلَّل الآية المتلوّة وتُقلَّب الصفحات معها',
        ),
        SizedBox(height: 18.h),
        const _ReciterGroup(),
        SizedBox(height: 22.h),
        const _StartGroup(),
        SizedBox(height: 22.h),
        const _PlaybackOptions(),
      ],
    );
  }
}

class _ReciterGroup extends StatelessWidget {
  const _ReciterGroup();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      QuranRecitationCubit,
      QuranRecitationState,
      RecitationSettings
    >(
      selector: (state) => state.settings,
      builder:
          (context, settings) => SettingsGroup(
            title: 'القارئ',
            children: [
              SettingsTile(
                icon: Icons.record_voice_over_rounded,
                title: settings.reciterName,
                subtitle: 'اضغط لاختيار قارئ آخر',
                onTap: () => _pickReciter(context, settings.reciterId),
              ),
            ],
          ),
    );
  }

  Future<void> _pickReciter(BuildContext context, String current) {
    final cubit = context.read<QuranRecitationCubit>();
    return pickEdition(
      context,
      type: QuranEditionType.recitation,
      selectedId: current,
      apply: (reciter) => cubit.setReciter(reciter!),
    );
  }
}

/// Where to start: computed from the page being read.
class _StartGroup extends StatelessWidget {
  const _StartGroup();

  @override
  Widget build(BuildContext context) {
    final reader = context.watch<MushafReaderCubit>().state;
    final hizb = context.watch<QuranHizbIndexCubit>().state;
    if (reader is! MushafReaderReady) return const SizedBox.shrink();

    final info = reader.pageInfo;
    final surah = reader.headerSurah;
    final quarter = switch ((hizb, info)) {
      (QuranHizbIndexLoaded(:final quarters), final info?) =>
        QuranHizbQuarter.containingAyah(quarters, info.firstAyahId),
      _ => null,
    };

    final options = <
      ({
        IconData icon,
        String title,
        String subtitle,
        RecitationRequest request,
      })
    >[
      if (info != null)
        (
          icon: Icons.play_circle_outline_rounded,
          title: 'من أول هذه الصفحة',
          subtitle: 'حتى نهاية سورة ${info.openingSurah.nameArabic}',
          request: RecitationFromAyah(info.firstAyahId),
        ),
      if (surah != null)
        (
          icon: Icons.menu_book_rounded,
          title: 'السورة كاملة',
          subtitle: 'سورة ${surah.nameArabic} من أولها',
          request: RecitationOfScope(RecitationScope.surah(surah.number)),
        ),
      (
        icon: Icons.description_outlined,
        title: 'هذه الصفحة',
        subtitle: 'الصفحة ${toArabicNumerals(reader.page)}',
        request: RecitationOfScope(RecitationScope.page(reader.page)),
      ),
      if (quarter != null)
        (
          icon: Icons.pie_chart_outline_rounded,
          title: 'هذا الربع',
          subtitle: hizbQuarterTitle(quarter.number),
          request: RecitationOfScope(
            RecitationScope.hizbQuarter(quarter.number),
          ),
        ),
      if (info != null)
        (
          icon: Icons.layers_outlined,
          title: 'هذا الجزء',
          subtitle: juzTitle(info.juz),
          request: RecitationOfScope(RecitationScope.juz(info.juz)),
        ),
    ];

    return SettingsGroup(
      title: 'ابدأ الاستماع',
      footer:
          hizb is QuranHizbIndexLoading
              ? const _Hint('جارٍ تحميل أرباع الأحزاب…')
              : null,
      children: [
        for (final option in options)
          SettingsTile(
            icon: option.icon,
            title: option.title,
            subtitle: option.subtitle,
            trailing: Icon(
              Icons.play_arrow_rounded,
              size: 22.r,
              color: AppPaletteOverride.of(context).primaryPurple,
            ),
            onTap: () {
              final cubit = context.read<QuranRecitationCubit>();
              Navigator.of(context).pop();
              cubit.start(option.request);
            },
          ),
      ],
    );
  }
}

class _PlaybackOptions extends StatelessWidget {
  const _PlaybackOptions();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      QuranRecitationCubit,
      QuranRecitationState,
      RecitationSettings
    >(
      selector: (state) => state.settings,
      builder: (context, settings) {
        final cubit = context.read<QuranRecitationCubit>();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SettingsGroupTitle('تكرار كل آية'),
            SizedBox(height: 8.h),
            SegmentedTabs(
              labels: [for (final r in AyahRepeat.values) ayahRepeatLabel(r)],
              selectedIndex: settings.repeat.index,
              onChanged:
                  (i) => _apply(context, cubit.setRepeat(AyahRepeat.values[i])),
            ),
            SizedBox(height: 6.h),
            _Hint(ayahRepeatDescription(settings.repeat)),
            SizedBox(height: 20.h),
            const SettingsGroupTitle('سرعة التلاوة'),
            SizedBox(height: 8.h),
            SegmentedTabs(
              labels: [
                for (final s in RecitationSpeed.values) recitationSpeedLabel(s),
              ],
              selectedIndex: settings.speed.index,
              onChanged:
                  (i) => _apply(
                    context,
                    cubit.setSpeed(RecitationSpeed.values[i]),
                  ),
            ),
            SizedBox(height: 22.h),
            SettingsGroup(
              title: 'خيارات',
              children: [
                SettingsTile(
                  icon: Icons.playlist_play_rounded,
                  title: 'متابعة التلاوة',
                  subtitle: 'الانتقال إلى ما بعدها حين تنتهي',
                  trailing: AppSwitch(
                    value: settings.continuous,
                    semanticLabel: 'متابعة التلاوة',
                    onChanged: (v) => _apply(context, cubit.setContinuous(v)),
                  ),
                ),
                SettingsTile(
                  icon: Icons.data_saver_on_rounded,
                  title: 'توفير البيانات',
                  subtitle: 'جودة صوت أقل وملفات أصغر',
                  trailing: AppSwitch(
                    value: settings.quality == RecitationQuality.dataSaver,
                    semanticLabel: 'توفير البيانات',
                    onChanged:
                        (v) => _apply(
                          context,
                          cubit.setQuality(
                            v
                                ? RecitationQuality.dataSaver
                                : RecitationQuality.high,
                          ),
                        ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  /// The change shows at once; the reader hears of it only if it could not
  /// be kept for next time.
  static Future<void> _apply(BuildContext context, Future<bool> change) async {
    final saved = await change;
    if (!saved && context.mounted) {
      showErrorSnackbar(context, 'تعذر حفظ الإعداد لمرة قادمة');
    }
  }
}

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
          color: AppPaletteOverride.of(context).secondaryText,
        ),
      ),
    );
  }
}
