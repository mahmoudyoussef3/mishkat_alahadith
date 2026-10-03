import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/core/di/dependency_injection.dart';
import 'package:mishkat_almasabih/core/widgets/empty_search_state.dart';
import 'package:mishkat_almasabih/features/ahadith/logic/cubit/ahadiths_cubit.dart';
import 'package:mishkat_almasabih/features/ahadith/ui/widgets/chapter_ahadith_card.dart';
import 'package:mishkat_almasabih/features/ahadith/ui/widgets/separator.dart';
import 'package:mishkat_almasabih/core/utils/constants.dart';
import 'package:mishkat_almasabih/features/bookmark/logic/add_cubit/cubit/add_cubit_cubit.dart';
import 'package:mishkat_almasabih/features/bookmark/logic/cubit/get_collections_bookmark_cubit.dart';
import 'package:mishkat_almasabih/features/hadith_details/ui/screens/hadith_details_screen.dart';

class HadithListBuilder extends StatelessWidget {
  final String arabicBookName;
  final String bookSlug;
  final AhadithsSuccess state;

  const HadithListBuilder({
    super.key,
    required this.arabicBookName,
    required this.bookSlug,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    if (state.filteredAhadith.isEmpty) {
      return const SliverToBoxAdapter(child: EmptyState());
    }

    return SliverList.separated(
      itemCount: state.filteredAhadith.length,
      separatorBuilder: (_, __) => const IslamicSeparator(),
      itemBuilder: (context, index) {
        final hadith = state.filteredAhadith[index];
        return GestureDetector(
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => MultiBlocProvider(
                        providers: [
                           BlocProvider(create: (_) => getIt<GetCollectionsBookmarkCubit>()),
        BlocProvider(create: (_) => getIt<AddCubitCubit>()),
                        ],
                        child: HadithDetailScreen(
                          isLocal: false,
                          chapterNumber: hadith.chapterId.toString(),
                          bookSlug: bookSlug,
                          authorDeath: hadith.book?.writerDeath ?? '',
                          hadithText: hadith.hadithArabic ?? '',
                          narrator: bookWriters[hadith.book?.writerName] ?? '',
                          grade: hadith.status ?? '',
                          bookName: arabicBookName,
                          author: bookWriters[hadith.book?.writerName] ?? '',
                          chapter: hadith.chapter?.chapterArabic ?? '',
                          hadithNumber: hadith.hadithNumber.toString(),
                        ),
                      ),
                ),
              ),
          child: ChapterAhadithCard(
            bookName: arabicBookName,
            number: hadith.hadithNumber.toString(),
            text: hadith.hadithArabic ?? "",
            narrator: hadith.book?.writerName ?? '',
            grade: _gradeStringArabic(hadith.status),
            reference: hadith.chapter?.chapterArabic ?? '',
          ),
        );
      },
    );
  }

  String _gradeStringArabic(String? grade) {
    switch (grade?.toLowerCase()) {
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
