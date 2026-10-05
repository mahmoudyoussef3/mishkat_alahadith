import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/arabic_plurals.dart';
import 'package:mishkat_almasabih/core/helpers/functions.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/widgets/app_icon_button.dart';
import 'package:mishkat_almasabih/core/widgets/detail_header.dart';
import 'package:mishkat_almasabih/core/widgets/search_bar_widget.dart';
import 'package:mishkat_almasabih/features/ahadith/presentation/logic/cubit/ahadiths_cubit.dart';
import 'package:mishkat_almasabih/features/ahadith/presentation/ui/widgets/ahadith_list_bloc_builder.dart';
import 'package:mishkat_almasabih/features/ahadith/presentation/ui/widgets/bookmark_button.dart';
import 'package:mishkat_almasabih/features/ahadith/presentation/ui/widgets/bookmark_listener.dart';
import 'package:mishkat_almasabih/features/ahadith/presentation/ui/widgets/chapter_filters_bar.dart';
import 'package:mishkat_almasabih/features/reading_preferences/presentation/ui/hadith_font_size_sheet.dart';

/// The hadiths of one chapter, loaded page by page, with search, grade
/// filters and a matn-only reading mode.
class ChapterAhadithScreen extends StatefulWidget {
  const ChapterAhadithScreen({
    super.key,
    required this.bookSlug,
    required this.bookId,
    required this.arabicBookName,
    required this.arabicWriterName,
    required this.arabicChapterName,
    required this.narrator,
    required this.grade,
    required this.authorDeath,
    required this.chapterNumber,
    this.chapterHadithsCount,
  });

  final String bookSlug;
  final String arabicBookName;
  final String arabicWriterName;
  final String arabicChapterName;
  final int bookId;
  final String? narrator;
  final String? grade;
  final String? authorDeath;
  final int? chapterNumber;

  /// The chapter's size from the chapter list, shown before it loads.
  final int? chapterHadithsCount;

  @override
  State<ChapterAhadithScreen> createState() => _ChapterAhadithScreenState();
}

class _ChapterAhadithScreenState extends State<ChapterAhadithScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  late final AhadithsCubit _cubit;

  int _page = 1;
  bool _searching = false;
  bool _matnOnly = false;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<AhadithsCubit>();
    _scrollController.addListener(_onScroll);
    _load(1);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load(int page) {
    _page = page;
    return _cubit.emitAhadiths(
      page: page,
      paginate: 10,
      bookSlug: widget.bookSlug,
      chapterId: widget.chapterNumber ?? 1,
      isArbainBooks: checkThreeBooks(widget.bookSlug),
      hadithLocal: checkBookSlug(widget.bookSlug),
    );
  }

  void _onScroll() {
    final state = _cubit.state;
    final loadingMore = state is AhadithsSuccess && state.isLoadingMore;
    final nearEnd =
        _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 400;
    if (nearEnd && !loadingMore && _cubit.hasMore) _load(_page + 1);
  }

  void _toggleSearch() {
    setState(() => _searching = !_searching);
    if (!_searching) {
      _searchController.clear();
      _cubit.filterAhadith('');
    }
  }

  String _subtitle(int? count) => [
    widget.arabicBookName,
    if (count != null && count > 0) arabicCount(count, ArabicNoun.hadith),
  ].join(' · ');

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BookmarkListener(
        child: Scaffold(
          backgroundColor: ColorsManager.secondaryBackground,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                BlocSelector<AhadithsCubit, AhadithsState, int?>(
                  selector:
                      (state) => switch (state) {
                        AhadithsSuccess(:final totalCount) =>
                          totalCount ?? widget.chapterHadithsCount,
                        LocalAhadithsSuccess(:final hadiths) => hadiths.length,
                        _ => widget.chapterHadithsCount,
                      },
                  builder:
                      (context, count) => DetailHeader(
                        title: widget.arabicChapterName,
                        subtitle: _subtitle(count),
                        actions: [
                          AppIconButton(
                            tooltip: _searching ? 'إغلاق البحث' : 'بحث في الباب',
                            icon:
                                _searching
                                    ? Icons.search_off_rounded
                                    : Icons.search_rounded,
                            variant:
                                _searching
                                    ? AppIconButtonVariant.tonal
                                    : AppIconButtonVariant.outlined,
                            onPressed: _toggleSearch,
                          ),
                          AppIconButton(
                            tooltip: 'حجم الخط',
                            icon: Icons.text_increase_rounded,
                            onPressed: () => showHadithFontSizeSheet(context),
                          ),
                          SaveChapterButton(
                            bookSlug: widget.bookSlug,
                            arabicBookName: widget.arabicBookName,
                            arabicChapterName: widget.arabicChapterName,
                            chapterNumber: widget.chapterNumber,
                          ),
                        ],
                        bottom:
                            _searching
                                ? SearchBarWidget(
                                  controller: _searchController,
                                  hintText: 'ابحث في أحاديث الباب…',
                                  onChanged: _cubit.filterAhadith,
                                )
                                : null,
                      ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => _load(1),
                    child: CustomScrollView(
                      controller: _scrollController,
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(child: SizedBox(height: 16.h)),
                        SliverToBoxAdapter(
                          child: ChapterFiltersBar(
                            matnOnly: _matnOnly,
                            onMatnOnlyChanged:
                                (value) => setState(() => _matnOnly = value),
                          ),
                        ),
                        SliverToBoxAdapter(child: SizedBox(height: 6.h)),
                        ChapterHadithList(
                          bookSlug: widget.bookSlug,
                          arabicBookName: widget.arabicBookName,
                          arabicWriterName: widget.arabicWriterName,
                          arabicChapterName: widget.arabicChapterName,
                          showIsnad: !_matnOnly,
                          onRetry: () => _load(1),
                        ),
                        SliverToBoxAdapter(child: SizedBox(height: 24.h)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
