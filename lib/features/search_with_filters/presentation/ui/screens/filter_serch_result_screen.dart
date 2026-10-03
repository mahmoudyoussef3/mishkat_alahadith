import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/widgets/empty_search_state.dart';
import 'package:mishkat_almasabih/core/widgets/error_dialg.dart';
import 'package:mishkat_almasabih/core/widgets/hadith_card_shimer.dart';
import 'package:mishkat_almasabih/features/ahadith/ui/widgets/chapter_ahadith_card.dart';
import 'package:mishkat_almasabih/features/ahadith/ui/widgets/emoty_chapter_ahadith.dart';
import 'package:mishkat_almasabih/features/ahadith/ui/widgets/separator.dart';
import 'package:mishkat_almasabih/features/hadith_details/ui/screens/hadith_details_screen.dart';
import 'package:mishkat_almasabih/features/home/ui/widgets/build_header_app_bar.dart';
import 'package:mishkat_almasabih/features/search_with_filters/logic/cubit/search_with_filters_cubit.dart';

class FilterSerchResultScreen extends StatelessWidget {
  const FilterSerchResultScreen({super.key, required this.searchQuery});
  final String? searchQuery;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: ColorsManager.primaryBackground,
        body: CustomScrollView(
          slivers: [
            BuildHeaderAppBar(
              title: "نتائج البحث عن",
              description: searchQuery ?? "",
            ),
            SliverToBoxAdapter(child: SizedBox(height: 12.h)),
            BlocBuilder<SearchWithFiltersCubit, SearchWithFiltersState>(
              builder: (context, state) {
                if (state is SearchWithFiltersLoading) {
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => const HadithCardShimmer(),
                      childCount: 6,
                    ),
                  );
                } else if (state is SearchWithFiltersSuccess) {
                  final hadiths =
                      state.searchWithFiltersModel.search?.results?.data ?? [];
                  if (hadiths.isEmpty) {
                    return EmptySliverState();
                  }
      
                  return SliverList.separated(
                    itemCount: hadiths.length,
                    separatorBuilder: (_, __) => IslamicSeparator(),
                    itemBuilder: (context, index) {
                      final hadith = hadiths[index];
                      return GestureDetector(
                        onTap:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => HadithDetailScreen(
                                      isBookMark: false,
                                      showNavigation: false,
      
                                      isLocal: false,
                                      chapterNumber:
                                          hadith.chapter?.chapterNumber ?? '',
                                      bookSlug: hadith.book?.bookSlug ?? '',
                                      bookName: hadith.book?.bookName ?? '',
                                      author: hadith.book?.writerName ?? '',
                                      chapter:
                                          hadith.chapter?.chapterArabic ?? '',
                                      hadithNumber: hadith.hadithNumber ?? '',
                                      hadithText: hadith.hadithArabic ?? '',
                                      narrator: hadith.book?.aboutWriter ?? '',
                                      grade: hadith.status ?? '',
                                      authorDeath:
                                          hadith.book?.writerDeath ?? '',
                                    ),
                              ),
                            ),
                        child: ChapterAhadithCard(
                          bookName: hadith.book?.bookName ?? '',
                          number: hadith.hadithNumber ?? '',
                          text: hadith.hadithArabic ?? '',
                          narrator: hadith.book?.writerName ?? '',
                          grade:
                              hadith.status != null
                                  ? gradeStringArabic(hadith.status ?? '')
                                  : '${index + 1}',
                          reference: hadith.chapter?.chapterArabic ?? '',
                        ),
                      );
                    },
                  );
                } else if (state is SearchWithFiltersFailure) {
                  return SliverToBoxAdapter(
                    child: ErrorState(error: state.errMessage),
                  );
                }
      
                return SliverToBoxAdapter(child: SizedBox.shrink());
              },
            ),
          ],
        ),
      ),
    );
  }

  Color gradeColor(String? g) {
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
