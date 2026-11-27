import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/widgets/app_icon_button.dart';
import 'package:mishkat_almasabih/core/widgets/search_bar_widget.dart';
import 'package:mishkat_almasabih/core/widgets/state_message.dart';
import 'package:mishkat_almasabih/features/chapters/domain/entities/book_chapter.dart';
import 'package:mishkat_almasabih/features/chapters/presentation/logic/cubit/chapters_cubit.dart';
import 'package:mishkat_almasabih/features/chapters/presentation/ui/helpers/open_chapter.dart';
import 'package:mishkat_almasabih/features/chapters/presentation/ui/models/book_chapters_args.dart';
import 'package:mishkat_almasabih/features/chapters/presentation/ui/widgets/book_header.dart';
import 'package:mishkat_almasabih/features/chapters/presentation/ui/widgets/chapter_list.dart';
import 'package:mishkat_almasabih/features/chapters/presentation/ui/widgets/continue_reading_card.dart';

/// A book's cover and size, where the reader left off, and its chapters
/// with an inline filter.
class BookChaptersScreen extends StatefulWidget {
  const BookChaptersScreen({super.key, required this.book});

  final BookChaptersArgs book;

  @override
  State<BookChaptersScreen> createState() => _BookChaptersScreenState();
}

class _BookChaptersScreenState extends State<BookChaptersScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _open(BookChapter chapter) async {
    final cubit = context.read<ChaptersCubit>();
    FocusManager.instance.primaryFocus?.unfocus();
    await cubit.markChapterOpened(chapter);
    if (!mounted) return;
    await openChapter(context, book: widget.book, chapter: chapter);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ChaptersCubit>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: ColorsManager.secondaryBackground,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 8.h),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: AppIconButton(
                    tooltip: 'رجوع',
                    icon: Icons.arrow_back_rounded,
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh:
                      () => cubit.emitGetBookChapters(
                        bookSlug: widget.book.bookSlug,
                      ),
                  child: BlocBuilder<ChaptersCubit, ChaptersState>(
                    builder:
                        (context, state) => CustomScrollView(
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          physics: const AlwaysScrollableScrollPhysics(),
                          slivers: [
                            SliverPadding(
                              padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 0),
                              sliver: SliverList.list(
                                children: [
                                  BookHeader(book: widget.book),
                                  if (state case ChaptersSuccess(
                                    lastRead: final lastRead?,
                                    :final allChapters,
                                  )) ...[
                                    SizedBox(height: 16.h),
                                    ContinueReadingCard(
                                      lastRead: lastRead,
                                      chapters: allChapters,
                                      onTap: _open,
                                    ),
                                  ],
                                  SizedBox(height: 16.h),
                                  SearchBarWidget(
                                    controller: _searchController,
                                    hintText: 'ابحث في أبواب الكتاب…',
                                    onChanged: cubit.filterChapters,
                                  ),
                                  SizedBox(height: 16.h),
                                ],
                              ),
                            ),
                            ..._body(state),
                            SliverToBoxAdapter(child: SizedBox(height: 28.h)),
                          ],
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _body(ChaptersState state) => switch (state) {
    ChaptersSuccess(:final filteredChapters, :final allChapters, :final lastRead)
        when filteredChapters.isNotEmpty =>
      [
        ChapterListHeader(
          shown: filteredChapters.length,
          total: allChapters.length,
        ),
        ChapterList(
          chapters: filteredChapters,
          lastReadNumber: lastRead?.chapterNumber,
          onTap: _open,
        ),
      ],
    ChaptersSuccess() => [
      const SliverToBoxAdapter(
        child: StateMessage(
          icon: Icons.search_off_rounded,
          title: 'لا توجد أبواب مطابقة',
          subtitle: 'جرّب كلمة أبسط أو مختلفة',
        ),
      ),
    ],
    ChaptersFailure(:final errorMessage) => [
      SliverToBoxAdapter(
        child: StateMessage.error(
          message: errorMessage ?? 'حدث خطأ، حاول مرة أخرى',
          onRetry:
              () => context.read<ChaptersCubit>().emitGetBookChapters(
                bookSlug: widget.book.bookSlug,
              ),
        ),
      ),
    ],
    _ => [const ChapterListShimmer()],
  };
}
