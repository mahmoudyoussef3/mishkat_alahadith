import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/di/dependency_injection.dart';
import 'package:mishkat_almasabih/core/helpers/arabic_digits.dart';
import 'package:mishkat_almasabih/core/helpers/functions.dart';
import 'package:mishkat_almasabih/core/helpers/hadith_grade.dart';
import 'package:mishkat_almasabih/core/helpers/hadith_text.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/core/utils/constants.dart';
import 'package:mishkat_almasabih/core/widgets/state_message.dart';
import 'package:mishkat_almasabih/features/ahadith/presentation/logic/cubit/ahadiths_cubit.dart';
import 'package:mishkat_almasabih/features/ahadith/presentation/ui/widgets/chapter_hadith_tile.dart';
import 'package:mishkat_almasabih/features/bookmark/presentation/logic/add_bookmark/add_cubit_cubit.dart';
import 'package:mishkat_almasabih/features/bookmark/presentation/logic/collections/get_collections_bookmark_cubit.dart';
import 'package:mishkat_almasabih/features/hadith_details/presentation/ui/screens/hadith_details_screen.dart';

/// The chapter's hadiths, from the API or the bundled books, with loading,
/// empty, error and end-of-chapter states.
class ChapterHadithList extends StatelessWidget {
  const ChapterHadithList({
    super.key,
    required this.bookSlug,
    required this.arabicBookName,
    required this.arabicWriterName,
    required this.arabicChapterName,
    required this.showIsnad,
    required this.onRetry,
  });

  final String bookSlug;
  final String arabicBookName;
  final String arabicWriterName;
  final String arabicChapterName;
  final bool showIsnad;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AhadithsCubit, AhadithsState>(
      builder:
          (context, state) => switch (state) {
            AhadithsSuccess(:final filteredAhadith) when filteredAhadith.isEmpty =>
              const _NoMatches(),
            AhadithsSuccess() => _RemoteList(
              state: state,
              bookSlug: bookSlug,
              arabicBookName: arabicBookName,
              showIsnad: showIsnad,
            ),
            LocalAhadithsSuccess(:final filteredHadiths)
                when filteredHadiths.isEmpty =>
              const _NoMatches(),
            LocalAhadithsSuccess(:final filteredHadiths) => SliverList.builder(
              itemCount: filteredHadiths.length,
              itemBuilder: (context, index) {
                final hadith = filteredHadiths[index];
                final text = hadith.arabic ?? '';
                return ChapterHadithTile(
                  number: '${hadith.idInBook ?? hadith.id ?? index + 1}',
                  parts: HadithTextParts.split(text),
                  showIsnad: showIsnad,
                  onShare:
                      () => _share(
                        context,
                        text,
                        toArabicDigits(
                          '$arabicBookName · حديث ${hadith.idInBook ?? hadith.id ?? ''}',
                        ),
                      ),
                  onTap:
                      () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (_) => HadithDetailScreen(
                                authorDeath: '',
                                grade: '',
                                narrator: '',
                                isLocal: true,
                                chapterNumber: hadith.chapterId.toString(),
                                bookSlug: bookSlug,
                                hadithText: text,
                                bookName: arabicBookName,
                                author: arabicWriterName,
                                chapter: arabicChapterName,
                                hadithNumber: hadith.id.toString(),
                              ),
                        ),
                      ),
                );
              },
            ),
            AhadithsFailure(:final error) => SliverToBoxAdapter(
              child: StateMessage.error(message: error, onRetry: onRetry),
            ),
            _ => SliverList.builder(
              itemCount: 4,
              itemBuilder: (_, _) => const ChapterHadithTileShimmer(),
            ),
          },
    );
  }

  static void _share(BuildContext context, String text, String source) =>
      shareHadithAsImage(context, text: text, source: source);
}

class _RemoteList extends StatelessWidget {
  const _RemoteList({
    required this.state,
    required this.bookSlug,
    required this.arabicBookName,
    required this.showIsnad,
  });

  final AhadithsSuccess state;
  final String bookSlug;
  final String arabicBookName;
  final bool showIsnad;

  @override
  Widget build(BuildContext context) {
    final ahadith = state.filteredAhadith;
    return SliverMainAxisGroup(
      slivers: [
        SliverList.builder(
          itemCount: ahadith.length,
          itemBuilder: (context, index) {
            final hadith = ahadith[index];
            final text = hadith.hadithArabic ?? '';
            return ChapterHadithTile(
              number: hadith.hadithNumber,
              parts: HadithTextParts.split(text),
              grade: HadithGrade.tryParse(hadith.status),
              heading: hadith.headingArabic,
              showIsnad: showIsnad,
              onShare:
                  () => ChapterHadithList._share(
                    context,
                    text,
                    toArabicDigits(
                      '$arabicBookName · حديث ${hadith.hadithNumber ?? ''}',
                    ),
                  ),
              onTap:
                  () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (_) => MultiBlocProvider(
                            providers: [
                              BlocProvider(
                                create:
                                    (_) => getIt<GetCollectionsBookmarkCubit>(),
                              ),
                              BlocProvider(
                                create: (_) => getIt<AddCubitCubit>(),
                              ),
                            ],
                            child: HadithDetailScreen(
                              isLocal: false,
                              chapterNumber: hadith.chapterId.toString(),
                              bookSlug: bookSlug,
                              authorDeath: hadith.book?.writerDeath ?? '',
                              hadithText: text,
                              narrator:
                                  bookWriters[hadith.book?.writerName] ?? '',
                              grade: hadith.status ?? '',
                              bookName: arabicBookName,
                              author: bookWriters[hadith.book?.writerName] ?? '',
                              chapter: hadith.chapter?.chapterArabic ?? '',
                              hadithNumber: hadith.hadithNumber.toString(),
                            ),
                          ),
                    ),
                  ),
            );
          },
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Center(
              child:
                  state.isLoadingMore
                      ? SizedBox.square(
                        dimension: 24.r,
                        child: const CircularProgressIndicator(strokeWidth: 2.5),
                      )
                      : !state.hasMoreData
                      ? Text(
                        'نهاية الباب',
                        style: TextStyles.caption.copyWith(
                          color: ColorsManager.gray,
                        ),
                      )
                      : const SizedBox.shrink(),
            ),
          ),
        ),
      ],
    );
  }
}

class _NoMatches extends StatelessWidget {
  const _NoMatches();

  @override
  Widget build(BuildContext context) {
    return const SliverToBoxAdapter(
      child: StateMessage(
        icon: Icons.search_off_rounded,
        title: 'لا توجد أحاديث مطابقة',
        subtitle: 'جرّب كلمة أخرى أو اعرض كل الدرجات',
      ),
    );
  }
}
