import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/functions.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/features/ahadith/logic/cubit/ahadiths_cubit.dart';
import 'package:mishkat_almasabih/features/ahadith/ui/widgets/ahadith_list_bloc_builder.dart';
import 'package:mishkat_almasabih/features/ahadith/ui/widgets/bookmark_listener.dart';
import 'package:mishkat_almasabih/features/ahadith/ui/widgets/chapter_ahadith_search_bar.dart';
import 'package:mishkat_almasabih/features/ahadith/ui/widgets/chapter_appbar.dart';

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

  @override
  State<ChapterAhadithScreen> createState() => _ChapterAhadithScreenState();
}

class _ChapterAhadithScreenState extends State<ChapterAhadithScreen> {
  late final ScrollController _scrollController;
  late final AhadithsCubit _cubit;
  final TextEditingController _searchController = TextEditingController();

  int _page = 1;

  @override
  void initState() {
    super.initState();

    _cubit = context.read<AhadithsCubit>();
    _scrollController = ScrollController()..addListener(_onScroll);

    _fetchInitialData();
  }

  void _fetchInitialData() {
    _page = 1;
    _cubit.emitAhadiths(
      page: _page,
      paginate: 10,
      bookSlug: widget.bookSlug,
      chapterId: widget.chapterNumber ?? 1,
      isArbainBooks: checkThreeBooks(widget.bookSlug),
      hadithLocal: checkBookSlug(widget.bookSlug),
    );
  }

  void _onScroll() {
    final state = _cubit.state;
    final isLoadingMore = state is AhadithsSuccess && state.isLoadingMore;

    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !isLoadingMore &&
        _cubit.hasMore) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    _page++;
    await _cubit.emitAhadiths(
      page: _page,
      paginate: 10,
      bookSlug: widget.bookSlug,
      chapterId: widget.chapterNumber ?? 1,
      isArbainBooks: checkThreeBooks(widget.bookSlug),
      hadithLocal: checkBookSlug(widget.bookSlug),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        top: true,
        bottom: true,
        child: Scaffold(
          backgroundColor: ColorsManager.primaryBackground,
          body: CustomScrollView(
            controller: _scrollController,
            slivers: [
              ChapterAppBar(
                arabicBookName: widget.arabicBookName,
                arabicChapterName: widget.arabicChapterName,
                bookSlug: widget.bookSlug,
                chapterNumber: widget.chapterNumber,
              ),

              SliverToBoxAdapter(child: SizedBox(height: 16.h)),

              AhadithSearchBar(controller: _searchController),

              SliverToBoxAdapter(child: SizedBox(height: 16.h)),

              const SliverToBoxAdapter(child: BookmarkListener()),

              AhadithListBlocBuilder(
                bookSlug: widget.bookSlug,
                arabicBookName: widget.arabicBookName,
                pageNumber: _page,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
