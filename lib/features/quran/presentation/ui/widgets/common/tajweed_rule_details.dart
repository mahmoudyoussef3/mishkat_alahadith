import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/quran_decorations.dart';
import 'package:mishkat_almasabih/core/theming/quran_styles.dart';
import 'package:mushaf_text/mushaf_text.dart';

/// What a rule means, how long it is held, which letters it takes, and the
/// verse of the matn it comes from — so the reader can check it rather than
/// take it on trust.
class TajweedRuleDetails extends StatelessWidget {
  final TajweedRule rule;
  final QuranSurfaceColors colors;

  const TajweedRuleDetails({
    super.key,
    required this.rule,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DetailRow(label: 'التعريف', value: rule.definition, colors: colors),
        _DetailRow(label: 'المقدار', value: rule.amount, colors: colors),
        _DetailRow(label: 'الحروف', value: rule.letters, colors: colors),
        Divider(color: colors.border, height: 24.h),
        Text('المرجع', style: QuranTextStyles.detailLabel(colors.accent)),
        SizedBox(height: 6.h),
        Text(rule.source, style: QuranTextStyles.tileTitle(colors.title)),
        SizedBox(height: 10.h),
        Container(
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 14.w),
          decoration: QuranDecorations.evidenceBox(colors),
          child: Text(
            // Verses are separated by ‖; one per line reads as poetry.
            rule.evidence.replaceAll(' ‖ ', '\n'),
            textAlign: TextAlign.center,
            style: QuranTextStyles.evidence(colors.title),
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final QuranSurfaceColors colors;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 64.w,
            child: Padding(
              padding: EdgeInsets.only(top: 3.h),
              child: Text(
                label,
                style: QuranTextStyles.detailLabel(colors.accent),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: QuranTextStyles.detailValue(colors.title),
            ),
          ),
        ],
      ),
    );
  }
}
