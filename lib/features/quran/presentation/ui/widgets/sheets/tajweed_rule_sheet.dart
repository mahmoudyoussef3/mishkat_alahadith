import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/quran_decorations.dart';
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
  required QuranSurfaceColors colors,
  required TajweedRule rule,
  String? word,
  int start = 0,
  int end = 0,
  bool canFollow = false,
}) {
  return showQuranSheet<bool>(
    context: context,
    colors: colors,
    initialChildSize: word == null ? 0.6 : 0.72,
    builder:
        (context, controller) => _TajweedRuleSheetContent(
          controller: controller,
          colors: colors,
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
  final QuranSurfaceColors colors;
  final TajweedRule rule;
  final String? word;
  final int start;
  final int end;
  final bool canFollow;

  const _TajweedRuleSheetContent({
    required this.controller,
    required this.colors,
    required this.rule,
    required this.word,
    required this.start,
    required this.end,
    required this.canFollow,
  });

  @override
  Widget build(BuildContext context) {
    final ruleColor = colors.ruleColor(rule);
    final word = this.word;
    return ListView(
      controller: controller,
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 28.h),
      children: [
        QuranSheetHandle(colors: colors),
        SizedBox(height: 8.h),
        Row(
          children: [
            RuleSwatch(color: ruleColor, size: 16),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(rule.label, style: QuranTextStyles.ruleTitle(ruleColor)),
                  Text(
                    '${rule.family.label} · ${ltrIsolate(rule.englishName)}',
                    style: QuranTextStyles.ruleFamily(colors.subtitle),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (word != null) ...[
          SizedBox(height: 16.h),
          _TappedWord(
            word: word,
            start: start,
            end: end,
            ruleColor: ruleColor,
            colors: colors,
          ),
        ],
        if (canFollow) ...[
          SizedBox(height: 14.h),
          FilledButton.tonalIcon(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: ruleColor.withValues(alpha: 0.12),
              foregroundColor: ruleColor,
              padding: EdgeInsets.symmetric(vertical: 12.h),
            ),
            icon: const Icon(Icons.travel_explore_rounded),
            label: const Text('تتبّع هذا الحكم في الصفحة'),
          ),
        ],
        SizedBox(height: 18.h),
        TajweedRuleDetails(rule: rule, colors: colors),
      ],
    );
  }
}

class _TappedWord extends StatelessWidget {
  final String word;
  final int start;
  final int end;
  final Color ruleColor;
  final QuranSurfaceColors colors;

  const _TappedWord({
    required this.word,
    required this.start,
    required this.end,
    required this.ruleColor,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 12.w),
      decoration: QuranDecorations.quranTextBox(colors),
      child: Text.rich(
        styledRanges(
          text: word,
          base: QuranTextStyles.mushafText(color: colors.title, size: 34.sp),
          ranges: [
            (start: start, end: end, style: TextStyle(color: ruleColor)),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
