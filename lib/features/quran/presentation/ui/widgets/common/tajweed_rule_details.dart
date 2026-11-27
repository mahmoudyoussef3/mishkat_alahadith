import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/app_palette_override.dart';
import 'package:mishkat_almasabih/core/theming/quran_styles.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mushaf_text/mushaf_text.dart';

/// What a rule means, how long it is held, which letters it takes, and the
/// verse of the matn it comes from — so the reader can check it rather than
/// take it on trust.
///
/// Has no frame of its own: a sheet sets it in a card, the guide inside an
/// expanded row.
class TajweedRuleDetails extends StatelessWidget {
  final TajweedRule rule;

  const TajweedRuleDetails({super.key, required this.rule});

  @override
  Widget build(BuildContext context) {
    final palette = AppPaletteOverride.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DetailRow(label: 'التعريف', value: rule.definition),
        _DetailRow(label: 'المقدار', value: rule.amount),
        _DetailRow(label: 'الحروف', value: rule.letters),
        SizedBox(height: 4.h),
        _Label('المرجع', color: palette.purpleText),
        SizedBox(height: 2.h),
        Text(
          rule.source,
          style: TextStyles.titleSmall.copyWith(
            fontWeight: FontWeight.w700,
            height: 1.6,
            color: palette.primaryText,
          ),
        ),
        SizedBox(height: 10.h),
        Container(
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
          decoration: BoxDecoration(
            color: palette.goldSoft,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Text(
            // Verses are separated by ‖; one per line reads as poetry.
            rule.evidence.replaceAll(' ‖ ', '\n'),
            textAlign: TextAlign.center,
            style: QuranTextStyles.matnVerse(palette.goldInk),
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final palette = AppPaletteOverride.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Label(label, color: palette.purpleText),
          SizedBox(height: 2.h),
          Text(
            value,
            style: TextStyles.explanationBody.copyWith(
              fontSize: 14.5.sp,
              height: 1.75,
              color: palette.primaryText,
            ),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  final Color color;

  const _Label(this.text, {required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyles.caption.copyWith(
        fontWeight: FontWeight.w700,
        color: color,
      ),
    );
  }
}
