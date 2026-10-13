import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/hadith_text.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/core/widgets/answer_view.dart';
import 'package:mishkat_almasabih/core/widgets/app_icon_button.dart';
import 'package:mishkat_almasabih/core/widgets/detail_header.dart';
import 'package:mishkat_almasabih/core/widgets/state_message.dart';
import 'package:mishkat_almasabih/features/hadith_analysis/presentation/logic/cubit/hadith_analysis_cubit.dart';
import 'package:mishkat_almasabih/features/hadith_analysis/presentation/ui/siraj_analysis_args.dart';
import 'package:mishkat_almasabih/features/serag/domain/entities/serag_hadith_context.dart';
import 'package:mishkat_almasabih/features/serag/presentation/ui/open_siraj.dart';
import 'package:mishkat_almasabih/features/serag/presentation/ui/widgets/siraj_composer.dart';
import 'package:shimmer/shimmer.dart';

/// Siraj's structured reading of one hadith, with a bar to carry on the
/// conversation about it.
class SirajAnalysisScreen extends StatelessWidget {
  const SirajAnalysisScreen({super.key, required this.args});

  final SirajAnalysisArgs args;

  void _analyze(BuildContext context) =>
      context.read<HadithAnalysisCubit>().analyzeHadith(
        hadith: args.hadith,
        attribution: args.attribution,
        grade: args.grade,
        reference: args.reference,
      );

  void _ask(BuildContext context, String question) => openSiraj(
    context,
    hadith: SeragHadithContext(
      hadeeth: args.hadith,
      gradeAr: args.grade,
      source: args.reference,
      takhrijAr: args.attribution,
    ),
    title: args.title,
    question: question,
  );

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
              BlocBuilder<HadithAnalysisCubit, HadithAnalysisState>(
                builder: (context, state) {
                  final analysis =
                      state is HadithAnalysisLoaded ? state.result.analysis : null;
                  return DetailHeader(
                    title: 'تحليل سراج',
                    subtitle: args.title,
                    actions: [
                      AppIconButton(
                        tooltip: 'نسخ التحليل',
                        icon: Icons.content_copy_rounded,
                        onPressed:
                            analysis == null || analysis.isEmpty
                                ? null
                                : () => _copy(context, analysis),
                      ),
                    ],
                  );
                },
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
                  children: [
                    _QuotedHadith(text: args.hadith),
                    SizedBox(height: 16.h),
                    BlocBuilder<HadithAnalysisCubit, HadithAnalysisState>(
                      builder:
                          (context, state) => switch (state) {
                            HadithAnalysisLoaded(:final result)
                                when (result.analysis ?? '').trim().isNotEmpty =>
                              AnswerView(
                                text: result.analysis!,
                                accentFirstHeading: true,
                                fallbackHeading: 'المعنى الإجمالي',
                              ),
                            HadithAnalysisLoaded() => const StateMessage(
                              icon: Icons.auto_awesome_outlined,
                              title: 'لا يوجد تحليل لهذا الحديث بعد',
                              subtitle: 'اسأل سراج مباشرة من الشريط بالأسفل',
                            ),
                            HadithAnalysisError(:final message) =>
                              StateMessage.error(
                                message: message,
                                onRetry: () => _analyze(context),
                              ),
                            _ => const _AnalysisLoading(),
                          },
                    ),
                    SizedBox(height: 16.h),
                    const _Disclaimer(),
                  ],
                ),
              ),
              SirajComposer(
                hint: 'اسأل سراج عن هذا الحديث…',
                suggestions: const [
                  'ما فوائد هذا الحديث؟',
                  'اشرح الكلمات الغريبة',
                  'أحاديث في المعنى نفسه',
                ],
                onSend: (question) => _ask(context, question),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> _copy(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('تم نسخ التحليل')));
  }
}

class _QuotedHadith extends StatelessWidget {
  const _QuotedHadith({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: ColorsManager.lightGray,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Text(
        HadithTextParts.split(text).matn,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyles.readingMedium.copyWith(
          fontSize: 17.sp,
          fontWeight: FontWeight.w700,
          color: ColorsManager.primaryText.withValues(alpha: 0.85),
        ),
      ),
    );
  }
}

class _Disclaimer extends StatelessWidget {
  const _Disclaimer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: ColorsManager.goldSoft,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 18.r,
            color: ColorsManager.primaryGold,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'تحليل آلي للاستئناس؛ يُرجع إلى الشروح المعتمدة وأهل العلم.',
              style: TextStyles.caption.copyWith(
                height: 1.7,
                color: ColorsManager.goldInk,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalysisLoading extends StatelessWidget {
  const _AnalysisLoading();

  @override
  Widget build(BuildContext context) {
    Widget line(double widthFactor) => FractionallySizedBox(
      alignment: AlignmentDirectional.centerStart,
      widthFactor: widthFactor,
      child: Container(
        height: 14.h,
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: ColorsManager.shimmerBase,
          borderRadius: BorderRadius.circular(6.r),
        ),
      ),
    );

    return Semantics(
      label: 'سراج يحلل الحديث',
      child: Shimmer.fromColors(
        baseColor: ColorsManager.shimmerBase,
        highlightColor: ColorsManager.shimmerHighlight,
        child: Column(
          children: [
            line(0.4),
            line(1),
            line(1),
            line(0.7),
            SizedBox(height: 12.h),
            line(0.35),
            line(0.95),
            line(0.85),
          ],
        ),
      ),
    );
  }
}
