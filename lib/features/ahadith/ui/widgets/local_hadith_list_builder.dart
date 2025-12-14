import 'package:flutter/material.dart';
import 'package:mishkat_almasabih/core/widgets/empty_search_state.dart';
import 'package:mishkat_almasabih/features/ahadith/logic/cubit/ahadiths_cubit.dart';
import 'package:mishkat_almasabih/features/ahadith/ui/widgets/local_hadith_card.dart';
import 'package:mishkat_almasabih/features/ahadith/ui/widgets/separator.dart';
import 'package:mishkat_almasabih/features/hadith_details/ui/screens/hadith_details_screen.dart';

class LocalHadithListBuilder extends StatelessWidget {
  final LocalAhadithsSuccess state;
  final String arabicBookName;
  final String arabicWriterName;
  final String arabicChapterName;
  final String? narrator;
  final String? grade;
  final String? authorDeath;
  final String bookSlug;

  const LocalHadithListBuilder({
    super.key,
    required this.state,
    required this.arabicBookName,
    required this.arabicWriterName,
    required this.arabicChapterName,
    required this.bookSlug,
    required this.narrator,
    required this.grade,
    required this.authorDeath,
  });

  @override
  Widget build(BuildContext context) {
    final list = state.hadiths ?? [];

    if (list.isEmpty) {
      return const SliverToBoxAdapter(child: EmptyState());
    }

    return SliverList.separated(
      itemCount: list.length,
      separatorBuilder: (_, __) => const IslamicSeparator(),
      itemBuilder: (context, index) {
        final hadith = list[index];
        return GestureDetector(
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => HadithDetailScreen(
                        authorDeath: authorDeath ?? "",
                        grade: grade ?? "",
                        narrator: narrator ?? "",
                        isLocal: true,
                        chapterNumber: hadith.chapterId.toString(),
                        bookSlug: bookSlug,
                        hadithText: hadith.arabic ?? '',
                        bookName: arabicBookName,
                        author: arabicWriterName,
                        chapter: arabicChapterName,
                        hadithNumber: hadith.id.toString(),
                      ),
                ),
              ),
          child: LocalHadithCard(
            bookName: arabicBookName,
            chapterName: arabicChapterName,
            hadith: hadith,
          ),
        );
      },
    );
  }
}
