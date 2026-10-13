import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/arabic_plurals.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/mushaf_palette.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/core/widgets/detail_header.dart';
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: ColorsManager.secondaryBackground,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              DetailHeader(
                title: 'دليل أحكام التجويد',
                subtitle: [
                  arabicCount(TajweedRule.values.length, ArabicNoun.ruling),
                  'برواية حفص عن عاصم',
                ].join(' '),
              ),
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
                      sliver: const SliverToBoxAdapter(child: _GuideIntro()),
                    ),
                    for (final family in TajweedFamily.values) ...[
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 10.h),
                        sliver: SliverToBoxAdapter(
                          child: _FamilyHeader(
                            family: family,
                            count: _rulesOf(family).length,
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        sliver: SliverToBoxAdapter(
                          child: _FamilyCard(rules: _rulesOf(family)),
                        ),
                      ),
                    ],
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 0),
                      sliver: const SliverToBoxAdapter(
                        child: _GuideLimitations(),
                      ),
                    ),
                    SliverSafeArea(
                      top: false,
                      sliver: SliverToBoxAdapter(
                        child: SizedBox(height: 32.h),
                      ),
                    ),
                  ],
                ),
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
      decoration: BoxDecoration(
        color: ColorsManager.primarySoft,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(
              color: ColorsManager.cardBackground,
              borderRadius: BorderRadius.circular(13.r),
            ),
            child: Icon(
              Icons.menu_book_rounded,
              size: 21.r,
              color: ColorsManager.purpleText,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'مواضع الأحكام في المصحف مستخرجة من رسم مصحف المدينة نفسه، '
              'ولكل حكم مرجعه: تحفة الأطفال للجمزوري، والمقدمة الجزرية لابن '
              'الجزري، ودليل ضبط مجمّع الملك فهد. فعّل التلوين في المصحف، '
              'ثم المس أي حرف ملوّن لترى حكمه.',
              style: TextStyles.bodyMedium.copyWith(height: 1.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _FamilyHeader extends StatelessWidget {
  final TajweedFamily family;
  final int count;

  const _FamilyHeader({required this.family, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(
                  family.label,
                  style: TextStyles.sectionTitle.copyWith(fontSize: 16.sp),
                ),
              ),
              Text(ltrIsolate(family.englishName), style: TextStyles.caption),
            ],
          ),
        ),
        Text(
          toArabicNumerals(count),
          style: TextStyles.caption.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

/// A family's rules as expandable rows of one card.
class _FamilyCard extends StatelessWidget {
  final List<TajweedRule> rules;

  const _FamilyCard({required this.rules});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ColorsManager.cardBackground,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
        side: BorderSide(color: ColorsManager.border),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rules.length; i++) ...[
            if (i > 0) Divider(height: 1, color: ColorsManager.lightGray),
            _GuideRuleTile(rule: rules[i]),
          ],
        ],
      ),
    );
  }
}

class _GuideRuleTile extends StatelessWidget {
  final TajweedRule rule;

  const _GuideRuleTile({required this.rule});

  @override
  Widget build(BuildContext context) {
    final ruleColor = MushafPalette.of(
      ColorsManager.palette,
    ).tajweedColor(rule);
    return ExpansionTile(
      // The card draws the dividers between rows.
      shape: const Border(),
      collapsedShape: const Border(),
      tilePadding: EdgeInsetsDirectional.fromSTEB(14.w, 4.h, 10.w, 4.h),
      childrenPadding: EdgeInsetsDirectional.fromSTEB(14.w, 0, 14.w, 16.h),
      expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
      iconColor: ColorsManager.purpleText,
      collapsedIconColor: ColorsManager.gray,
      leading: RuleWell(color: ruleColor),
      title: Text(
        rule.label,
        style: TextStyles.titleMedium.copyWith(
          fontWeight: FontWeight.w700,
          height: 1.5,
        ),
      ),
      subtitle: Text(
        '${ltrIsolate(rule.englishName)} · ${rule.amount}',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyles.caption.copyWith(height: 1.6),
      ),
      children: [TajweedRuleDetails(rule: rule)],
    );
  }
}

class _GuideLimitations extends StatelessWidget {
  const _GuideLimitations();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: ColorsManager.goldSoft,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: ColorsManager.goldInk,
            size: 20.r,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'لا يُلوَّن بعدُ: السكت والإمالة والتسهيل والإشمام، ولا علامات '
              'الوقف (تظهر دون لون). والألوان اجتهاد في العرض وليست نقلًا عن '
              'مصحف ملوّن مطبوع، ويُستحسن مراجعة الأحكام مع معلّم مُجاز.',
              style: TextStyles.bodySmall.copyWith(
                height: 1.8,
                color: ColorsManager.goldInk,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
