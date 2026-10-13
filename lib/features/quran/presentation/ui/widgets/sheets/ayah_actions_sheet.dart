import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/di/dependency_injection.dart';
import 'package:mishkat_almasabih/core/theming/app_palette.dart';
import 'package:mishkat_almasabih/core/theming/app_palette_override.dart';
import 'package:mishkat_almasabih/core/theming/mushaf_palette.dart';
import 'package:mishkat_almasabih/core/theming/quran_styles.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/core/widgets/app_badge.dart';
import 'package:mishkat_almasabih/core/widgets/dashed_divider.dart';
import 'package:mishkat_almasabih/core/widgets/state_message.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/ayah_details.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/mushaf_reader_settings.dart';
import 'package:mishkat_almasabih/features/quran/presentation/logic/ayah_details/ayah_details_cubit.dart';
import 'package:mishkat_almasabih/features/quran/presentation/logic/mushaf_reader/mushaf_reader_cubit.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/helpers/quran_ui_helpers.dart';
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
  required int ayahId,
}) {
  final state = readerCubit.state;
  final tajweed = state is MushafReaderReady && state.settings.tajweedEnabled;
  final naturalMadd =
      state is MushafReaderReady && state.settings.naturalMaddEnabled;
  final fontScale =
      state is MushafReaderReady
          ? state.settings.fontScale
          : QuranFontScale.medium;

  return showQuranSheet<AyahSheetIntent>(
    context: context,
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
                      const QuranSheetHandle(),
                      SizedBox(height: 80.h),
                      const Center(child: CircularProgressIndicator()),
                    ],
                  ),
                  AyahDetailsFailure(:final message) => ListView(
                    controller: controller,
                    children: [
                      const QuranSheetHandle(),
                      StateMessage.error(
                        message: message,
                        onRetry:
                            () => context.read<AyahDetailsCubit>().load(
                              ayahId,
                              includeNaturalMadd: naturalMadd,
                            ),
                      ),
                    ],
                  ),
                  AyahDetailsLoaded(:final details) => _AyahDetailsBody(
                    controller: controller,
                    details: details,
                    tajweedEnabled: tajweed,
                    fontScale: fontScale,
                  ),
                },
          ),
        ),
  );
}

class _AyahDetailsBody extends StatelessWidget {
  final ScrollController controller;
  final AyahDetails details;
  final bool tajweedEnabled;
  final QuranFontScale fontScale;

  const _AyahDetailsBody({
    required this.controller,
    required this.details,
    required this.tajweedEnabled,
    required this.fontScale,
  });

  @override
  Widget build(BuildContext context) {
    final palette = AppPaletteOverride.of(context);
    final ayah = details.ayah;
    final rules = [
      for (final key in details.ruleKeys)
        if (tajweedRuleOf(key) case final rule?) rule,
    ];

    return ListView(
      controller: controller,
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
      children: [
        const QuranSheetHandle(),
        QuranSheetHeader(
          title: 'سورة ${details.surah.nameArabic}',
          subtitle: [
            'الآية ${toArabicNumerals(ayah.number)}',
            juzTitle(ayah.juz),
            'الصفحة ${toArabicNumerals(ayah.page)}',
          ].join(' · '),
          trailing:
              ayah.isSajdah
                  ? AppBadge(
                    label: '۩ موضع سجدة',
                    background: palette.goldSoft,
                    foreground: palette.goldInk,
                  )
                  : null,
        ),
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 14.h),
          decoration: BoxDecoration(
            color: palette.cardBackground,
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: palette.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text.rich(_ayahSpan(palette), textAlign: TextAlign.center),
              SizedBox(height: 14.h),
              const DashedDivider(),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: _SheetAction(
                      icon: Icons.content_copy_rounded,
                      label: 'نسخ',
                      onTap:
                          () => Navigator.of(
                            context,
                          ).pop(CopyAyahIntent(details)),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: _SheetAction(
                      icon: Icons.share_rounded,
                      label: 'مشاركة',
                      onTap:
                          () => Navigator.of(
                            context,
                          ).pop(ShareAyahIntent(details)),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(child: _BookmarkAction(details: details)),
                ],
              ),
            ],
          ),
        ),
        if (rules.isNotEmpty) ...[
          SizedBox(height: 22.h),
          Semantics(
            header: true,
            child: Text(
              'أحكام التجويد في هذه الآية',
              style: TextStyles.sectionTitle.copyWith(
                fontSize: 16.sp,
                color: palette.primaryText,
              ),
            ),
          ),
          Text(
            'اضغط على حكم لشرحه وتتبّع مواضعه في الصفحة',
            style: TextStyles.caption.copyWith(
              fontSize: 13.sp,
              color: palette.secondaryText,
            ),
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              for (final rule in rules)
                _RuleChip(rule: rule, onTap: () => _explain(context, rule)),
            ],
          ),
        ],
      ],
    );
  }

  /// The verse with its tajweed in colour when the reader has it switched on.
  TextSpan _ayahSpan(AppPalette palette) {
    final text = details.ayah.text;
    final base = QuranTextStyles.mushafText(
      color: palette.primaryText,
      size: quranFontSize(fontScale),
    );
    if (!tajweedEnabled) return TextSpan(text: text, style: base);
    final ruleColors = MushafPalette.of(palette);
    return styledRanges(
      text: text,
      base: base,
      ranges: [
        for (final segment in details.tajweed)
          if (tajweedRuleOf(segment.ruleKey) case final rule?)
            (
              start: segment.start,
              end: segment.end,
              style: TextStyle(color: ruleColors.tajweedColor(rule)),
            ),
      ],
    );
  }

  Future<void> _explain(BuildContext context, TajweedRule rule) async {
    final follow = await showTajweedRuleSheet(
      context,
      rule: rule,
      canFollow: true,
    );
    if (follow == true && context.mounted) {
      Navigator.of(context).pop(FollowRuleIntent(rule.name));
    }
  }
}

/// One of the ayah's actions, drawn like the actions under a hadith.
class _SheetAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  /// Read instead of [label] when the short label needs its context.
  final String? semanticLabel;

  const _SheetAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final palette = AppPaletteOverride.of(context);
    final ink = active ? palette.purpleText : palette.primaryText;
    final button = Material(
      color: active ? palette.primarySoft : palette.secondaryBackground,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: SizedBox(
          height: 42.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18.r, color: ink),
              SizedBox(width: 6.w),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyles.labelLarge.copyWith(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: ink,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    final semanticLabel = this.semanticLabel;
    if (semanticLabel == null) return button;
    return Semantics(
      button: true,
      label: semanticLabel,
      onTap: onTap,
      excludeSemantics: true,
      child: button,
    );
  }
}

class _BookmarkAction extends StatelessWidget {
  final AyahDetails details;

  const _BookmarkAction({required this.details});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<MushafReaderCubit, MushafReaderState, bool>(
      selector:
          (state) =>
              state is MushafReaderReady &&
              state.isAyahBookmarked(details.ayah.id),
      builder:
          (context, bookmarked) => _SheetAction(
            active: bookmarked,
            icon:
                bookmarked
                    ? Icons.bookmark_remove_rounded
                    : Icons.bookmark_add_outlined,
            // A third of the sheet's width: the icon carries the rest.
            label: bookmarked ? 'إزالة' : 'حفظ',
            semanticLabel: bookmarked ? 'إزالة علامة الآية' : 'حفظ الآية',
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
  final VoidCallback onTap;

  const _RuleChip({required this.rule, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final palette = AppPaletteOverride.of(context);
    final ruleColor = MushafPalette.of(palette).tajweedColor(rule);
    return Material(
      color: ruleColor.withValues(alpha: 0.12),
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              RuleSwatch(color: ruleColor, size: 10),
              SizedBox(width: 6.w),
              Text(
                rule.label,
                style: TextStyles.chipLabel.copyWith(
                  fontSize: 12.5.sp,
                  color: palette.primaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
