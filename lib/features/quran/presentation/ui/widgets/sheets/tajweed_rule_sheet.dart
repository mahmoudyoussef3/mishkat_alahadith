import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/app_palette_override.dart';
import 'package:mishkat_almasabih/core/theming/mushaf_palette.dart';
import 'package:mishkat_almasabih/core/theming/quran_styles.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/helpers/quran_ui_helpers.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/widgets/common/quran_sheet.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/widgets/common/rule_swatch.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/widgets/common/tajweed_rule_details.dart';
import 'package:mushaf_text/mushaf_text.dart';

/// Explains [rule]. When opened from a tapped letter, [word] shows the reader's
/// own word with that letter picked out — an example they found beats a
/// canned one.
///
/// Resolves to `true` when the reader asks to follow the rule across the page.
Future<bool?> showTajweedRuleSheet(
  BuildContext context, {
  required TajweedRule rule,
  String? word,
  int start = 0,
  int end = 0,
  bool canFollow = false,
}) {
  return showQuranSheet<bool>(
    context: context,
    initialChildSize: word == null ? 0.6 : 0.72,
    builder:
        (context, controller) => _TajweedRuleSheetContent(
          controller: controller,
          rule: rule,
          word: word,
          start: start,
          end: end,
          canFollow: canFollow,
        ),
  );
}

class _TajweedRuleSheetContent extends StatelessWidget {
  final ScrollController controller;
  final TajweedRule rule;
  final String? word;
  final int start;
  final int end;
  final bool canFollow;

  const _TajweedRuleSheetContent({
    required this.controller,
    required this.rule,
    required this.word,
    required this.start,
    required this.end,
    required this.canFollow,
  });

  @override
  Widget build(BuildContext context) {
    final palette = AppPaletteOverride.of(context);
    final ruleColor = MushafPalette.of(palette).tajweedColor(rule);
    final word = this.word;
    final card = BoxDecoration(
      color: palette.cardBackground,
      borderRadius: BorderRadius.circular(20.r),
      border: Border.all(color: palette.border),
    );

    return ListView(
      controller: controller,
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
      children: [
        const QuranSheetHandle(),
        Row(
          children: [
            RuleWell(color: ruleColor, size: 46),
            SizedBox(width: 12.w),
            Expanded(
              child: QuranSheetHeader(
                title: rule.label,
                subtitle:
                    '${rule.family.label} · ${ltrIsolate(rule.englishName)}',
              ),
            ),
          ],
        ),
        if (word != null) ...[
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 12.w),
            decoration: card,
            child: Text.rich(
              styledRanges(
                text: word,
                base: QuranTextStyles.mushafText(
                  color: palette.primaryText,
                  size: 34.sp,
                ),
                ranges: [
                  (start: start, end: end, style: TextStyle(color: ruleColor)),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
        if (canFollow) ...[
          SizedBox(height: 14.h),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(true),
            icon: const Icon(Icons.travel_explore_rounded),
            label: const Text('تتبّع هذا الحكم في الصفحة'),
          ),
        ],
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
          decoration: card,
          child: TajweedRuleDetails(rule: rule),
        ),
      ],
    );
  }
}
