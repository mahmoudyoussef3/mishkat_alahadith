import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/di/dependency_injection.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/widgets/empty_search_state.dart';
import 'package:mishkat_almasabih/core/widgets/hadith_card_shimer.dart';
import 'package:mishkat_almasabih/features/ahadith/ui/widgets/chapter_ahadith_card.dart';
import 'package:mishkat_almasabih/features/ahadith/ui/widgets/separator.dart';
import 'package:mishkat_almasabih/features/bookmark/logic/add_cubit/cubit/add_cubit_cubit.dart';
import 'package:mishkat_almasabih/features/bookmark/logic/cubit/get_collections_bookmark_cubit.dart';
import 'package:mishkat_almasabih/features/home/ui/widgets/build_header_app_bar.dart';
import 'package:mishkat_almasabih/features/search/enhanced_public_search/logic/cubit/enhanced_search_cubit.dart';
import 'package:mishkat_almasabih/features/search/enhanced_public_search/ui/screens/hadith_result_details.dart';

class PublicSearchResult extends StatelessWidget {
  const PublicSearchResult({super.key, required this.searchQuery});
  final String? searchQuery;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child:SafeArea(
          top: true,
        bottom: true,
            child: Scaffold(
              backgroundColor: ColorsManager.primaryBackground,
              body: CustomScrollView(
                slivers: [
                  BuildHeaderAppBar(
                    title: "نتائج البحث عن",
                    description: searchQuery ?? "",
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: 12.h)),
                  BlocBuilder<EnhancedSearchCubit, EnhancedSearchState>(
                    builder: (context, state) {
                      if (state is EnhancedSearchLoading) {
                        return SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => const HadithCardShimmer(),
                            childCount: 6,
                          ),
                        );
                      } else if (state is EnhancedSearchLoaded) {
                        final hadiths = state.enhancedSearch.results ?? [];
                        if (hadiths.isEmpty) {
                          return SliverToBoxAdapter(
                            child: Center(
                              child: EmptyState(
                                subtitle: 'حاول تغيير كلمات البحث',
                              ),
                            ),
                          );
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
                                          (context) => MultiBlocProvider(
                                            providers: [
                                              BlocProvider(
                                                create:
                                                    (context) =>
                                                        getIt<
                                                            GetCollectionsBookmarkCubit
                                                          >()
                                                          ..getBookMarkCollections(),
                                              ),
                                              BlocProvider(
                                                create:
                                                    (context) =>
                                                        getIt<AddCubitCubit>(),
                                              ),
                                            ],
                                            child: HadithResultDetails(
                                              enhancedHadithModel: hadith,
                                            ),
                                          ),
                                    ),
                                  ),
            
                              child: ChapterAhadithCard(
                                number: hadith.id ?? '',
            
                                //bookName:  '',
                                text: hadith.hadeeth ?? '',
                                narrator: hadith.attribution ?? '',
                                grade:
                                    hadith.grade != null
                                        ? gradeStringArabic(hadith.grade ?? '')
                                        : '${index + 1}',
                                reference: hadith.reference ?? '',
                              ),
                            );
                          },
                        );
                      } else if (state is EnhancedSearchError) {
                        return SliverToBoxAdapter(
                          child: Center(child: Text("خطأ: ${state.message}")),
                        );
                      }
            
                      return SliverToBoxAdapter(child: SizedBox.shrink());
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
