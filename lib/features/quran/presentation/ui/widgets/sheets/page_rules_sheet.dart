import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/arabic_plurals.dart';
import 'package:mishkat_almasabih/core/theming/app_palette_override.dart';
import 'package:mishkat_almasabih/core/theming/mushaf_palette.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/core/widgets/app_badge.dart';
import 'package:mishkat_almasabih/core/widgets/snackbars.dart';
import 'package:mishkat_almasabih/core/widgets/state_message.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/tajweed_info.dart';
import 'package:mishkat_almasabih/features/quran/presentation/logic/mushaf_reader/mushaf_reader_cubit.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/helpers/quran_ui_helpers.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/widgets/common/quran_sheet.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/widgets/common/rule_swatch.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/widgets/common/tajweed_guide_tile.dart';
import 'package:mushaf_text/mushaf_text.dart';

/// The rules on this page, most frequent first. Resolves to the key of the
/// rule the reader chose to follow, or null.
Future<String?> showPageRulesSheet(
  BuildContext context, {
  required MushafReaderCubit readerCubit,
}) {
  return showQuranSheet<String>(
    context: context,
    initialChildSize: 0.62,
    builder:
        (context, controller) => BlocProvider.value(
          value: readerCubit,
          child: _PageRulesContent(controller: controller),
        ),
  );
}

class _PageRulesContent extends StatelessWidget {
  final ScrollController controller;

  const _PageRulesContent({required this.controller});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MushafReaderCubit, MushafReaderState>(
      buildWhen:
          (previous, current) =>
              current is MushafReaderReady &&
              (previous is! MushafReaderReady ||
                  previous.page != current.page ||
                  previous.settings != current.settings ||
                  previous.ruleCounts != current.ruleCounts ||
                  previous.ruleCountsFailed != current.ruleCountsFailed),
      builder: (context, state) {
        if (state is! MushafReaderReady) return const SizedBox.shrink();
        // Only rules this mushaf can colour are listed, so emptiness is
        // judged on those.
        final rules = [
          for (final count in state.ruleCounts)
            if (tajweedRuleOf(count.ruleKey) case final rule?)
              (rule: rule, count: count),
        ];
        return ListView(
          controller: controller,
          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
          children: [
            const QuranSheetHandle(),
            QuranSheetHeader(
              title: 'أحكام الصفحة ${toArabicNumerals(state.page)}',
              subtitle:
                  'اختر حكمًا لتؤطَّر مواضعه في الصفحة واحدًا بعد الآخر، '
                  'أو المس أي حرف ملوّن لمعرفة حكمه.',
            ),
            SizedBox(height: 16.h),
            if (!state.settings.tajweedEnabled)
              StateMessage(
                icon: Icons.palette_outlined,
                title: 'تلوين التجويد متوقف',
                subtitle:
                    'فعّله لترى أحكام هذه الصفحة وعدد مواضع كل حكم.',
                actionLabel: 'تلوين أحكام التجويد',
                actionIcon: Icons.palette_rounded,
                onAction: () => _enableTajweed(context),
              )
            else if (state.ruleCountsFailed)
              StateMessage.error(
                message: 'تعذر حساب أحكام هذه الصفحة',
                onRetry: context.read<MushafReaderCubit>().retryRuleCounts,
              )
            else if (rules.isEmpty)
              const StateMessage(
                icon: Icons.auto_awesome_outlined,
                title: 'لا توجد أحكام ملوّنة في هذه الصفحة',
              )
            else
              _RuleCountList(
                rules: rules,
                onSelect: (key) => Navigator.of(context).pop(key),
              ),
            SizedBox(height: 22.h),
            const TajweedGuideTile(),
          ],
        );
      },
    );
  }

  Future<void> _enableTajweed(BuildContext context) async {
    final saved = await context.read<MushafReaderCubit>().setTajweedEnabled(
      true,
    );
    if (!saved && context.mounted) {
      showErrorSnackbar(
        context,
        'تعذر حفظ الإعداد، سيُطبَّق في هذه الجلسة فقط',
      );
    }
  }
}

/// The page's rules as rows of one card, each with how often it occurs.
class _RuleCountList extends StatelessWidget {
  final List<({TajweedRule rule, TajweedRuleCount count})> rules;
  final ValueChanged<String> onSelect;

  const _RuleCountList({required this.rules, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final palette = AppPaletteOverride.of(context);
    return Material(
      color: palette.cardBackground,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
        side: BorderSide(color: palette.border),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rules.length; i++) ...[
            if (i > 0) Divider(height: 1, color: palette.lightGray),
            _RuleCountRow(
              rule: rules[i].rule,
              count: rules[i].count.count,
              onTap: () => onSelect(rules[i].count.ruleKey),
            ),
          ],
        ],
      ),
    );
  }
}

class _RuleCountRow extends StatelessWidget {
  final TajweedRule rule;
  final int count;
  final VoidCallback onTap;

  const _RuleCountRow({
    required this.rule,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = AppPaletteOverride.of(context);
    final ruleColor = MushafPalette.of(palette).tajweedColor(rule);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        child: Row(
          children: [
            RuleWell(color: ruleColor),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rule.label,
                    style: TextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.5,
                      color: palette.primaryText,
                    ),
                  ),
                  Text(
                    rule.family.label,
                    style: TextStyles.caption.copyWith(
                      color: palette.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            AppBadge(
              label: arabicCount(count, ArabicNoun.occurrence),
              background: palette.lightGray,
              foreground: palette.primaryText,
            ),
            SizedBox(width: 4.w),
            Icon(
              Icons.chevron_right_rounded,
              size: 20.r,
              color: palette.gray,
            ),
          ],
        ),
      ),
    );
  }
}
