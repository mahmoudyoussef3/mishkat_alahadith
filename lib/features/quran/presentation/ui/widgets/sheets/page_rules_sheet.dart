import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/quran_decorations.dart';
import 'package:mishkat_almasabih/core/theming/quran_styles.dart';
import 'package:mishkat_almasabih/core/widgets/snackbars.dart';
import 'package:mishkat_almasabih/features/quran/presentation/logic/mushaf_reader/mushaf_reader_cubit.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/helpers/quran_ui_helpers.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/widgets/common/quran_message_view.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/widgets/common/quran_sheet.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/widgets/common/rule_swatch.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/widgets/common/tajweed_guide_link.dart';
import 'package:mushaf_text/mushaf_text.dart';

/// The rules on this page, most frequent first. Resolves to the key of the
/// rule the reader chose to follow, or null.
Future<String?> showPageRulesSheet(
  BuildContext context, {
  required MushafReaderCubit readerCubit,
  required MushafColors mushafColors,
}) {
  final colors = QuranSurfaceColors.mushaf(mushafColors);
  return showQuranSheet<String>(
    context: context,
    colors: colors,
    initialChildSize: 0.62,
    builder:
        (context, controller) => BlocProvider.value(
          value: readerCubit,
          child: _PageRulesContent(controller: controller, colors: colors),
        ),
  );
}

class _PageRulesContent extends StatelessWidget {
  final ScrollController controller;
  final QuranSurfaceColors colors;

  const _PageRulesContent({required this.controller, required this.colors});

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
        return ListView(
          controller: controller,
          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 28.h),
          children: [
            QuranSheetHandle(colors: colors),
            SizedBox(height: 6.h),
            Text(
              'أحكام الصفحة ${toArabicNumerals(state.page)}',
              style: QuranTextStyles.sheetTitle(colors.title),
            ),
            SizedBox(height: 2.h),
            Text(
              'اضغط على حكم ليؤطّر لك مواضعه في الصفحة واحدًا بعد الآخر، '
              'أو المس أي حرف ملوّن في الصفحة لمعرفة حكمه.',
              style: QuranTextStyles.sectionHint(colors.subtitle),
            ),
            SizedBox(height: 12.h),
            if (!state.settings.tajweedEnabled)
              _EnableTajweedPrompt(colors: colors)
            else if (state.ruleCountsFailed)
              QuranMessageView(
                colors: colors,
                icon: Icons.error_outline_rounded,
                message: 'تعذر حساب أحكام هذه الصفحة',
                actionLabel: 'إعادة المحاولة',
                onAction: context.read<MushafReaderCubit>().retryRuleCounts,
              )
            else if (state.ruleCounts.isEmpty)
              QuranMessageView(
                colors: colors,
                icon: Icons.auto_awesome_outlined,
                message: 'لا توجد أحكام لعرضها في هذه الصفحة',
              )
            else
              for (final count in state.ruleCounts)
                if (tajweedRuleOf(count.ruleKey) case final rule?)
                  _RuleCountTile(
                    rule: rule,
                    count: count.count,
                    colors: colors,
                    onTap: () => Navigator.of(context).pop(count.ruleKey),
                  ),
            Divider(color: colors.border, height: 28.h),
            TajweedGuideLink(colors: colors),
          ],
        );
      },
    );
  }
}

class _EnableTajweedPrompt extends StatelessWidget {
  final QuranSurfaceColors colors;

  const _EnableTajweedPrompt({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: QuranDecorations.evidenceBox(colors),
      child: Column(
        children: [
          Text(
            'فعّل تلوين التجويد لترى أحكام هذه الصفحة وعدد مواضع كل حكم.',
            textAlign: TextAlign.center,
            style: QuranTextStyles.message(colors.subtitle),
          ),
          SizedBox(height: 12.h),
          FilledButton.icon(
            onPressed: () => _enable(context),
            style: FilledButton.styleFrom(
              backgroundColor: colors.accent,
              foregroundColor: colors.background,
            ),
            icon: const Icon(Icons.palette_rounded),
            label: const Text('تلوين أحكام التجويد'),
          ),
        ],
      ),
    );
  }

  Future<void> _enable(BuildContext context) async {
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

class _RuleCountTile extends StatelessWidget {
  final TajweedRule rule;
  final int count;
  final QuranSurfaceColors colors;
  final VoidCallback onTap;

  const _RuleCountTile({
    required this.rule,
    required this.count,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      onTap: onTap,
      leading: RuleSwatch(color: colors.ruleColor(rule), size: 14),
      minLeadingWidth: 14.w,
      title: Text(rule.label, style: QuranTextStyles.tileTitle(colors.title)),
      subtitle: Text(
        rule.family.label,
        style: QuranTextStyles.tileMeta(colors.subtitle),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${toArabicNumerals(count)} ${count == 1 ? 'موضع' : 'مواضع'}',
            style: QuranTextStyles.tileTrailing(colors.accent),
          ),
          SizedBox(width: 4.w),
          Icon(Icons.travel_explore_rounded, size: 18.sp, color: colors.accent),
        ],
      ),
    );
  }
}
