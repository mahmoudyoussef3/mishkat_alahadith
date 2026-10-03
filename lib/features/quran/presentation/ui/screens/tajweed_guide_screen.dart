import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/quran_decorations.dart';
import 'package:mishkat_almasabih/core/theming/quran_styles.dart';
import 'package:mishkat_almasabih/features/home/presentation/ui/widgets/build_header_app_bar.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/helpers/quran_ui_helpers.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/widgets/common/rule_swatch.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/widgets/common/tajweed_rule_details.dart';
import 'package:mushaf_text/mushaf_text.dart';

/// Every tajweed rule the mushaf colours, grouped by family, each with its
/// colour, definition, letters and the verse it is taken from.
class TajweedGuideScreen extends StatelessWidget {
  const TajweedGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = QuranSurfaceColors.app();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: ColorsManager.secondaryBackground,
        body: SafeArea(
          bottom: false,
          child: CustomScrollView(
            slivers: [
              BuildHeaderAppBar(
                title: 'دليل أحكام التجويد',
                description:
                    '${toArabicNumerals(TajweedRule.values.length)} حكمًا '
                    'برواية حفص عن عاصم',
                pinned: true,
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
                sliver: const SliverToBoxAdapter(child: _GuideIntro()),
              ),
              for (final family in TajweedFamily.values) ...[
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 8.h),
                  sliver: SliverToBoxAdapter(
                    child: _FamilyHeader(family: family),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  sliver: SliverList.separated(
                    itemCount: _rulesOf(family).length,
                    separatorBuilder: (_, __) => SizedBox(height: 8.h),
                    itemBuilder:
                        (context, i) => _GuideRuleCard(
                          rule: _rulesOf(family)[i],
                          colors: colors,
                        ),
                  ),
                ),
              ],
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 32.h),
                sliver: const SliverToBoxAdapter(child: _GuideLimitations()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static List<TajweedRule> _rulesOf(TajweedFamily family) =>
      TajweedRule.values.where((r) => r.family == family).toList();
}

class _GuideIntro extends StatelessWidget {
  const _GuideIntro();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: QuranDecorations.guideIntroCard(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.menu_book_rounded, color: ColorsManager.primaryPurple),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'مواضع الأحكام في المصحف مستخرجة من رسم مصحف المدينة نفسه، '
              'ولكل حكم مرجعه: تحفة الأطفال للجمزوري، والمقدمة الجزرية لابن '
              'الجزري، ودليل ضبط مجمّع الملك فهد. فعّل التلوين في المصحف، '
              'ثم المس أي حرف ملوّن لترى حكمه.',
              style: QuranTextStyles.guideIntro,
            ),
          ),
        ],
      ),
    );
  }
}

class _FamilyHeader extends StatelessWidget {
  final TajweedFamily family;

  const _FamilyHeader({required this.family});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(family.label, style: QuranTextStyles.guideFamilyTitle),
        Text(family.englishName, style: QuranTextStyles.guideFamilySubtitle),
      ],
    );
  }
}

class _GuideRuleCard extends StatelessWidget {
  final TajweedRule rule;
  final QuranSurfaceColors colors;

  const _GuideRuleCard({required this.rule, required this.colors});

  @override
  Widget build(BuildContext context) {
    final ruleColor = colors.ruleColor(rule);
    return Container(
      decoration: QuranDecorations.guideRuleCard(),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Theme(
            // ExpansionTile draws dividers above and below itself by default.
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: EdgeInsetsDirectional.only(start: 18.w, end: 14.w),
              childrenPadding: EdgeInsetsDirectional.fromSTEB(
                18.w,
                0,
                14.w,
                16.h,
              ),
              iconColor: colors.accent,
              collapsedIconColor: colors.subtitle,
              leading: RuleSwatch(color: ruleColor, size: 14),
              title: Text(
                rule.label,
                style: QuranTextStyles.tileTitle(ruleColor),
              ),
              subtitle: Text(
                '${ltrIsolate(rule.englishName)} · ${rule.amount}',
                style: QuranTextStyles.tileMeta(colors.subtitle),
              ),
              children: [TajweedRuleDetails(rule: rule, colors: colors)],
            ),
          ),
          PositionedDirectional(
            start: 0,
            top: 0,
            bottom: 0,
            width: 4,
            child: ColoredBox(color: ruleColor),
          ),
        ],
      ),
    );
  }
}

class _GuideLimitations extends StatelessWidget {
  const _GuideLimitations();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: QuranDecorations.guideNoteCard(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: ColorsManager.warning,
            size: 20.sp,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'لا يُلوَّن بعدُ: السكت والإمالة والتسهيل والإشمام، ولا علامات '
              'الوقف (تظهر دون لون). والألوان اجتهاد في العرض وليست نقلًا عن '
              'مصحف ملوّن مطبوع، ويُستحسن مراجعة الأحكام مع معلّم مُجاز.',
              style: QuranTextStyles.guideNote,
            ),
          ),
        ],
      ),
    );
  }
}
