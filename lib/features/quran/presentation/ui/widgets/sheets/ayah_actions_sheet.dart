import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/di/dependency_injection.dart';
import 'package:mishkat_almasabih/core/theming/quran_decorations.dart';
import 'package:mishkat_almasabih/core/theming/quran_styles.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/ayah_details.dart';
import 'package:mishkat_almasabih/features/quran/presentation/logic/ayah_details/ayah_details_cubit.dart';
import 'package:mishkat_almasabih/features/quran/presentation/logic/mushaf_reader/mushaf_reader_cubit.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/helpers/quran_ui_helpers.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/widgets/common/quran_message_view.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/widgets/common/quran_sheet.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/widgets/common/rule_swatch.dart';
import 'package:mushaf_text/mushaf_text.dart';

import 'tajweed_rule_sheet.dart';

/// What the reader chose to do with the ayah; the screen carries it out.
sealed class AyahSheetIntent {
  const AyahSheetIntent();
}

final class CopyAyahIntent extends AyahSheetIntent {
  final AyahDetails details;

  const CopyAyahIntent(this.details);
}

final class ShareAyahIntent extends AyahSheetIntent {
  final AyahDetails details;

  const ShareAyahIntent(this.details);
}

final class ToggleAyahBookmarkIntent extends AyahSheetIntent {
  final AyahDetails details;

  const ToggleAyahBookmarkIntent(this.details);
}

final class FollowRuleIntent extends AyahSheetIntent {
  final String ruleKey;

  const FollowRuleIntent(this.ruleKey);
}

Future<AyahSheetIntent?> showAyahActionsSheet(
  BuildContext context, {
  required MushafReaderCubit readerCubit,
  required MushafColors mushafColors,
  required int ayahId,
}) {
  final state = readerCubit.state;
  final tajweed = state is MushafReaderReady && state.settings.tajweedEnabled;
  final naturalMadd =
      state is MushafReaderReady && state.settings.naturalMaddEnabled;
  final colors = QuranSurfaceColors.mushaf(mushafColors);

  return showQuranSheet<AyahSheetIntent>(
    context: context,
    colors: colors,
    initialChildSize: 0.62,
    builder:
        (context, controller) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create:
                  (_) =>
                      getIt<AyahDetailsCubit>()
                        ..load(ayahId, includeNaturalMadd: naturalMadd),
            ),
            BlocProvider.value(value: readerCubit),
          ],
          child: BlocBuilder<AyahDetailsCubit, AyahDetailsState>(
            builder:
                (context, detailsState) => switch (detailsState) {
                  AyahDetailsLoading() => ListView(
                    controller: controller,
                    children: [
                      QuranSheetHandle(colors: colors),
                      SizedBox(height: 80.h),
                      Center(
                        child: CircularProgressIndicator(color: colors.accent),
                      ),
                    ],
                  ),
                  AyahDetailsFailure(:final message) => ListView(
                    controller: controller,
                    children: [
                      QuranSheetHandle(colors: colors),
                      QuranMessageView(
                        colors: colors,
                        icon: Icons.error_outline_rounded,
                        message: message,
                        actionLabel: 'إعادة المحاولة',
                        onAction:
                            () => context.read<AyahDetailsCubit>().load(
                              ayahId,
                              includeNaturalMadd: naturalMadd,
                            ),
                      ),
                    ],
                  ),
                  AyahDetailsLoaded(:final details) => _AyahDetailsBody(
                    controller: controller,
                    colors: colors,
                    details: details,
                    tajweedEnabled: tajweed,
                  ),
                },
          ),
        ),
  );
}

class _AyahDetailsBody extends StatelessWidget {
  final ScrollController controller;
  final QuranSurfaceColors colors;
  final AyahDetails details;
  final bool tajweedEnabled;

  const _AyahDetailsBody({
    required this.controller,
    required this.colors,
    required this.details,
    required this.tajweedEnabled,
  });

  @override
  Widget build(BuildContext context) {
    final ayah = details.ayah;
    final rules = [
      for (final key in details.ruleKeys)
        if (tajweedRuleOf(key) case final rule?) rule,
    ];

    return ListView(
      controller: controller,
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 28.h),
      children: [
        QuranSheetHandle(colors: colors),
        SizedBox(height: 6.h),
        Text(
          'سورة ${details.surah.nameArabic}',
          style: QuranTextStyles.sheetTitle(colors.title),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 6.h,
          children: [
            _InfoChip(
              label: 'الآية ${toArabicNumerals(ayah.number)}',
              colors: colors,
            ),
            _InfoChip(
              label: 'الجزء ${toArabicNumerals(ayah.juz)}',
              colors: colors,
            ),
            _InfoChip(
              label: 'الصفحة ${toArabicNumerals(ayah.page)}',
              colors: colors,
            ),
            if (ayah.isSajdah)
              _InfoChip(
                label: '۩ موضع سجدة',
                colors: colors,
                color: colors.mushaf.gold,
              ),
          ],
        ),
        SizedBox(height: 14.h),
        Container(
          padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 14.w),
          decoration: QuranDecorations.quranTextBox(colors),
          child: Text.rich(_ayahSpan(), textAlign: TextAlign.center),
        ),
        SizedBox(height: 14.h),
        Row(
          children: [
            Expanded(
              child: _SheetAction(
                colors: colors,
                icon: Icons.copy_rounded,
                label: 'نسخ',
                onTap: () => Navigator.of(context).pop(CopyAyahIntent(details)),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _SheetAction(
                colors: colors,
                icon: Icons.share_rounded,
                label: 'مشاركة',
                onTap:
                    () => Navigator.of(context).pop(ShareAyahIntent(details)),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(child: _BookmarkAction(colors: colors, details: details)),
          ],
        ),
        if (rules.isNotEmpty) ...[
          SizedBox(height: 22.h),
          Text(
            'أحكام التجويد في هذه الآية',
            style: QuranTextStyles.sectionTitle(colors.title),
          ),
          SizedBox(height: 2.h),
          Text(
            'اضغط على أي حكم لشرحه وتتبّع مواضعه في الصفحة',
            style: QuranTextStyles.sectionHint(colors.subtitle),
          ),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              for (final rule in rules)
                _RuleChip(
                  rule: rule,
                  colors: colors,
                  onTap: () => _explain(context, rule),
                ),
            ],
          ),
        ],
      ],
    );
  }

  /// The verse with its tajweed in colour when the reader has it switched on.
  TextSpan _ayahSpan() {
    final text = details.ayah.text;
    final base = QuranTextStyles.mushafText(color: colors.title, size: 24.sp);
    if (!tajweedEnabled) return TextSpan(text: text, style: base);
    return styledRanges(
      text: text,
      base: base,
      ranges: [
        for (final segment in details.tajweed)
          if (tajweedRuleOf(segment.ruleKey) case final rule?)
            (
              start: segment.start,
              end: segment.end,
              style: TextStyle(color: colors.ruleColor(rule)),
            ),
      ],
    );
  }

  Future<void> _explain(BuildContext context, TajweedRule rule) async {
    final follow = await showTajweedRuleSheet(
      context,
      colors: colors,
      rule: rule,
      canFollow: true,
    );
    if (follow == true && context.mounted) {
      Navigator.of(context).pop(FollowRuleIntent(rule.name));
    }
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final QuranSurfaceColors colors;
  final Color? color;

  const _InfoChip({required this.label, required this.colors, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: QuranDecorations.infoChip(colors),
      child: Text(label, style: QuranTextStyles.chip(color ?? colors.accent)),
    );
  }
}

class _SheetAction extends StatelessWidget {
  final QuranSurfaceColors colors;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  const _SheetAction({
    required this.colors,
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Ink(
        decoration: QuranDecorations.actionButton(colors, active: active),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14.r),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: colors.accent, size: 22.sp),
                SizedBox(height: 4.h),
                Text(label, style: QuranTextStyles.actionLabel(colors.title)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BookmarkAction extends StatelessWidget {
  final QuranSurfaceColors colors;
  final AyahDetails details;

  const _BookmarkAction({required this.colors, required this.details});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<MushafReaderCubit, MushafReaderState, bool>(
      selector:
          (state) =>
              state is MushafReaderReady &&
              state.isAyahBookmarked(details.ayah.id),
      builder:
          (context, bookmarked) => _SheetAction(
            colors: colors,
            active: bookmarked,
            icon:
                bookmarked
                    ? Icons.bookmark_remove_rounded
                    : Icons.bookmark_add_outlined,
            label: bookmarked ? 'إزالة العلامة' : 'حفظ الآية',
            onTap:
                () => Navigator.of(
                  context,
                ).pop(ToggleAyahBookmarkIntent(details)),
          ),
    );
  }
}

class _RuleChip extends StatelessWidget {
  final TajweedRule rule;
  final QuranSurfaceColors colors;
  final VoidCallback onTap;

  const _RuleChip({
    required this.rule,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ruleColor = colors.ruleColor(rule);
    return Material(
      type: MaterialType.transparency,
      child: Ink(
        decoration: QuranDecorations.ruleChip(ruleColor),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                RuleSwatch(color: ruleColor, size: 10),
                SizedBox(width: 6.w),
                Text(rule.label, style: QuranTextStyles.chip(ruleColor)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
