import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/app_palette_override.dart';
import 'package:mishkat_almasabih/core/theming/mushaf_palette.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/core/widgets/app_icon_button.dart';
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
  const TajweedFocusBar({super.key});

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
  final TajweedRule rule;
  final int position;
  final int total;

  const _FocusBarContent({
    super.key,
    required this.rule,
    required this.position,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MushafReaderCubit>();
    final palette = AppPaletteOverride.of(context);
    final ruleColor = MushafPalette.of(palette).tajweedColor(rule);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      padding: EdgeInsets.all(6.r),
      decoration: BoxDecoration(
        color: palette.elevatedSurface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: ruleColor.withValues(alpha: 0.45)),
        boxShadow: [
          BoxShadow(
            color: palette.shadow,
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppIconButton(
            tooltip: 'إنهاء التتبع',
            icon: Icons.close_rounded,
            onPressed: cubit.clearFocus,
          ),
          SizedBox(width: 10.w),
          RuleSwatch(color: ruleColor, size: 12),
          SizedBox(width: 6.w),
          Flexible(
            child: Text(
              rule.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyles.titleSmall.copyWith(
                fontWeight: FontWeight.w800,
                color: palette.primaryText,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Semantics(
            liveRegion: true,
            child: Text(
              '${toArabicNumerals(position)} من ${toArabicNumerals(total)}',
              style: TextStyles.caption.copyWith(
                fontWeight: FontWeight.w600,
                color: palette.secondaryText,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          // The eye moves right to left along the line, so "previous" points
          // right and "next" points left. Pinned LTR so neither icon mirrors.
          Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppIconButton(
                  tooltip: 'الموضع التالي',
                  icon: Icons.chevron_left_rounded,
                  variant: AppIconButtonVariant.tonal,
                  onPressed: cubit.focusNext,
                ),
                SizedBox(width: 6.w),
                AppIconButton(
                  tooltip: 'الموضع السابق',
                  icon: Icons.chevron_right_rounded,
                  variant: AppIconButtonVariant.tonal,
                  onPressed: cubit.focusPrevious,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
