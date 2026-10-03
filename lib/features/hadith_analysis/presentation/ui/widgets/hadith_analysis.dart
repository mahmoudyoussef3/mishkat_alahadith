import 'package:flutter/material.dart';
import 'package:mishkat_almasabih/features/authentication/session/presentation/ui/session_builder.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mishkat_almasabih/core/helpers/extensions.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/hadith_analysis_decorations.dart';
import 'package:mishkat_almasabih/core/theming/hadith_analysis_styles.dart';
import 'package:mishkat_almasabih/features/hadith_analysis/presentation/logic/cubit/hadith_analysis_cubit.dart';
import 'package:mishkat_almasabih/features/authentication/session/presentation/logic/session_cubit.dart';
import 'package:shimmer/shimmer.dart';

class HadithAnalysis extends StatefulWidget {
  HadithAnalysis({
    super.key,
    required this.attribution,
    required this.hadith,
    required this.grade,
    required this.reference,
  });

  final String attribution;
  final String hadith;
  final String grade;
  final String reference;

  @override
  State<HadithAnalysis> createState() => _HadithAnalysisState();
}

class _HadithAnalysisState extends State<HadithAnalysis> {
  bool tapped = false;

  @override
  void initState() {
    super.initState();
    context.read<SessionCubit>().checkSession();
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SessionBuilder(
              builder: (context, isSignedIn) => _AnalyzeButton(
              onTap:
                  !isSignedIn
                      ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'يجب تسجيل الدخول أولاً لاستخدام هذه الميزة',
                                  textDirection: TextDirection.rtl,
                                  style: HadithAnalysisTextStyles.snackText,
                                ),
                                IconButton(
                                  onPressed:
                                      () =>
                                          context.pushNamed(Routes.loginScreen),
                                  icon: Icon(
                                    Icons.login,
                                    color: ColorsManager.white,
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: ColorsManager.primaryGreen,
                          ),
                        );
                      }
                      : () {
                        tapped = true;
                        context.read<HadithAnalysisCubit>().analyzeHadith(
                          attribution: widget.attribution,
                          hadith: widget.hadith,
                          grade: widget.grade,
                          reference: widget.reference,
                        );
                      },
            ),
            ),
            SizedBox(height: 20.h),
            BlocConsumer<HadithAnalysisCubit, HadithAnalysisState>(
              listenWhen: (prev, curr) => curr is HadithAnalysisError,
              listener: (context, state) {},
              buildWhen:
                  (prev, curr) =>
                      curr is HadithAnalysisLoading ||
                      curr is HadithAnalysisLoaded ||
                      curr is HadithAnalysisError,
              builder: (context, state) {
                if (state is HadithAnalysisLoading) {
                  return _ShimmerResultCard();
                } else if (state is HadithAnalysisLoaded) {
                  return tapped
                      ? _ResultCard(
                        icon: FontAwesomeIcons.bookOpen,
                        title: "تحليل الحديث",
                        text:
                            state.result.analysis ??
                            "لا يوجد تحليل متاح في الوقت الحالي.",
                      )
                      : _ResultCard(
                        icon: FontAwesomeIcons.lightbulb,
                        title: "معلومة",
                        text:
                            "يمكنك الآن الحصول على تحليل سريع للحديث باستخدام الذكاء الاصطناعي.\nاضغط على الزر أعلاه للبدء.",
                        color: ColorsManager.primarySoft,
                        textColor: ColorsManager.primaryText,
                      );
                } else if (state is HadithAnalysisError) {
                  return tapped
                      ? _ResultCard(
                        icon: FontAwesomeIcons.circleExclamation,
                        title: "خطأ",
                        text: state.message,
                        color: ColorsManager.error.withValues(alpha: 0.1),
                        textColor: ColorsManager.error,
                      )
                      : _ResultCard(
                        icon: FontAwesomeIcons.lightbulb,
                        title: "معلومة",
                        text:
                            "يمكنك الآن الحصول على تحليل سريع للحديث باستخدام الذكاء الاصطناعي.\nاضغط على الزر أعلاه للبدء.",
                        color: ColorsManager.primarySoft,
                        textColor: ColorsManager.primaryText,
                      );
                } else {
                  return _ResultCard(
                    icon: FontAwesomeIcons.lightbulb,
                    title: "معلومة",
                    text:
                        "يمكنك الآن الحصول على تحليل سريع للحديث باستخدام الذكاء الاصطناعي.\nاضغط على الزر أعلاه للبدء.",
                    color: ColorsManager.primarySoft,
                    textColor: ColorsManager.primaryText,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AnalyzeButton extends StatefulWidget {
  const _AnalyzeButton({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_AnalyzeButton> createState() => _AnalyzeButtonState();
}

class _AnalyzeButtonState extends State<_AnalyzeButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 20.w),
        decoration: HadithAnalysisDecorations.analyzeButton(pressed: _pressed),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FontAwesomeIcons.wandMagicSparkles,
              color: ColorsManager.white,
              size: 18.sp,
            ),
            SizedBox(width: 12.w),
            Text(
              "تحليل سريع للحديث",
              style: HadithAnalysisTextStyles.analyzeButtonLabel,
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.icon,
    required this.title,
    required this.text,
    this.color,
    this.textColor,
  });

  final IconData icon;
  final String title;
  final String text;
  final Color? color;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: HadithAnalysisDecorations.resultCard(background: color),
      child: Padding(
        padding: EdgeInsets.all(18.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20.sp, color: ColorsManager.hadithWeak),
                SizedBox(width: 8.w),
                Text(
                  title,
                  style: HadithAnalysisTextStyles.resultTitle(
                    textColor: textColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              text,
              style: HadithAnalysisTextStyles.resultBody(textColor: textColor),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerResultCard extends StatelessWidget {
  const _ShimmerResultCard();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: ColorsManager.shimmerBase,
      highlightColor: ColorsManager.shimmerHighlight,
      child: Container(
        decoration: HadithAnalysisDecorations.shimmerContainer(),
        child: Padding(
          padding: EdgeInsets.all(18.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 20.sp,
                    height: 20.sp,
                    decoration: HadithAnalysisDecorations.shimmerIconSquare(),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    width: 120.w,
                    height: 18.h,
                    decoration: HadithAnalysisDecorations.shimmerLine(),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Container(
                width: double.infinity,
                height: 14.h,
                decoration: HadithAnalysisDecorations.shimmerLine(),
              ),
              SizedBox(height: 8.h),
              Container(
                width: double.infinity,
                height: 14.h,
                decoration: HadithAnalysisDecorations.shimmerLine(),
              ),
              SizedBox(height: 8.h),
              Container(
                width: 200.w,
                height: 14.h,
                decoration: HadithAnalysisDecorations.shimmerLine(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
