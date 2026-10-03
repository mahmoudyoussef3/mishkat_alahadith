import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/widgets/hadith_card_shimer.dart';
import 'package:mishkat_almasabih/features/ahadith/ui/widgets/chapter_ahadith_card.dart';
import 'package:mishkat_almasabih/features/ahadith/ui/widgets/separator.dart';
import 'package:mishkat_almasabih/features/random_ahadith/logic/cubit/random_ahadith_cubit.dart';
import 'package:mishkat_almasabih/features/search/enhanced_public_search/data/models/enhanced_search_response_model.dart';
import 'package:mishkat_almasabih/features/search/enhanced_public_search/ui/screens/hadith_result_details.dart';

class RandomAhadithBlocBuilder extends StatelessWidget {
  const RandomAhadithBlocBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RandomAhadithCubit, RandomAhadithState>(
      builder: (context, state) {
        if (state is RandomAhadithLoading) {
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => const HadithCardShimmer(),
              childCount: 4,
            ),
          );
        } else if (state is RandomAhadithSuccess) {
          final hadiths = state.randomAhadithResponse.hadiths ?? [];

          return SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final hadith = hadiths[index];
              return Column(
                children: [
                  
                  GestureDetector(
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => HadithResultDetails(
                                  enhancedHadithModel: EnhancedHadithModel(
                                    reference: hadith.reference ?? '',
                                    attribution: hadith.attribution ?? '',
                                    categories: hadith.categories ?? [],
                                    explanation: hadith.explanation ?? "",
                                    grade: hadith.grade ?? "",
                                    hadeeth: hadith.hadith ?? "",
                                    hadeethIntro: hadith.title ?? "",
                                    hints: hadith.hints ?? [],
                                    id: hadith.hadithId ?? '',
                                    title: hadith.title ?? "",
                                    words_meanings: hadith.words_meanings
    ?.map((w) => WordMeaning(
          word: w.word,
          meaning: w.meaning,
        ))
    .toList(),
                                  ),
                                ),
                          ),
                        ),
                    child: ChapterAhadithCard(
                      hadithCategory: hadith.categories?.first ?? "",
                      number: hadith.hadithId ?? '',
                 //     bookName: hadith.reference ?? '',
                      text: hadith.hadith ?? '',
                      narrator: hadith.attribution ?? '',
                      grade:
                          hadith.grade != null
                              ? gradeStringArabic(hadith.grade ?? '')
                              : '${index + 1}',
                      reference: hadith.reference ?? '',
                    ),
                  ),
                  const IslamicSeparator(),
                ],
              );
            }, childCount: hadiths.length),
          );
        } else if (state is RandomAhaditFailure) {
          return SliverToBoxAdapter(
            child: ListTile(title: Text(state.errMessage.toString())),
          );
        }

        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }

  Color getGradeColor(String? g) {
    switch (g?.toLowerCase()) {
      case "sahih":
      case "صحيح":
        return ColorsManager.hadithAuthentic;
      case "hasan":
      case "حسن":
        return ColorsManager.hadithGood;
      case "daif":
      case "ضعيف":
        return ColorsManager.hadithWeak;
      default:
        return ColorsManager.hadithAuthentic;
    }
  }

  String gradeStringArabic(String grade) {
    switch (grade.toLowerCase()) {
      case "sahih":
      case "صحيح":
        return 'صحيح';
      case "hasan":
      case "حسن":
        return "حسن";
      case "daif":
      case "ضعيف":
        return "ضعيف";
      default:
        return '';
    }
  }
}
