import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/quran_decorations.dart';
import 'package:mishkat_almasabih/core/theming/quran_styles.dart';
import 'package:mishkat_almasabih/features/quran/presentation/logic/mushaf_reader/mushaf_reader_cubit.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/helpers/quran_ui_helpers.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/widgets/common/rule_swatch.dart';
import 'package:mushaf_text/mushaf_text.dart';

/// Steps through every occurrence of one rule on the page: the page frames
/// the current word, and this counts where the reader is.
///
/// It floats over the page instead of taking a row of its own, because the
/// page sizes its text to the height it is given.
class TajweedFocusBar extends StatelessWidget {
  final MushafColors colors;

  const TajweedFocusBar({super.key, required this.colors});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      MushafReaderCubit,
      MushafReaderState,
      ({String? ruleKey, int position, int total})
    >(
      selector: (state) {
        if (state is! MushafReaderReady || !state.isFocusing) {
          return (ruleKey: null, position: 0, total: 0);
        }
        return (
          ruleKey: state.focusRuleKey,
          position: state.focusIndex + 1,
          total: state.focusTotal,
        );
      },
      builder: (context, focus) {
        final key = focus.ruleKey;
        final rule = key == null ? null : tajweedRuleOf(key);
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          transitionBuilder:
              (child, animation) => FadeTransition(
                opacity: animation,
                child: SizeTransition(sizeFactor: animation, child: child),
              ),
          child:
              rule == null
                  ? const SizedBox.shrink()
                  : _FocusBarContent(
                    key: ValueKey(rule),
                    colors: colors,
                    rule: rule,
                    position: focus.position,
                    total: focus.total,
                  ),
        );
      },
    );
  }
}

class _FocusBarContent extends StatelessWidget {
  final MushafColors colors;
  final TajweedRule rule;
  final int position;
  final int total;

  const _FocusBarContent({
    super.key,
    required this.colors,
    required this.rule,
    required this.position,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MushafReaderCubit>();
    final ruleColor = colors.tajweedColor(rule);
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
      decoration: QuranDecorations.focusBar(colors, ruleColor),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _RoundButton(
            icon: Icons.close_rounded,
            color: colors.accent,
            label: 'إنهاء التتبع',
            onTap: cubit.clearFocus,
          ),
          RuleSwatch(color: ruleColor, size: 11),
          SizedBox(width: 6.w),
          Flexible(
            child: Text(
              rule.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: QuranTextStyles.focusRule(ruleColor),
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            '${toArabicNumerals(position)} من ${toArabicNumerals(total)}',
            style: QuranTextStyles.focusCounter(colors),
          ),
          SizedBox(width: 4.w),
          // The eye moves right to left along the line, so "previous" points
          // right and "next" points left. Pinned LTR so neither icon mirrors.
          Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _RoundButton(
                  icon: Icons.chevron_left_rounded,
                  color: ruleColor,
                  label: 'الموضع التالي',
                  onTap: cubit.focusNext,
                ),
                _RoundButton(
                  icon: Icons.chevron_right_rounded,
                  color: ruleColor,
                  label: 'الموضع السابق',
                  onTap: cubit.focusPrevious,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _RoundButton({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: InkResponse(
        onTap: onTap,
        radius: 22.r,
        child: SizedBox(
          width: 38.r,
          height: 38.r,
          child: Icon(icon, color: color, size: 24.sp),
        ),
      ),
    );
  }
}
