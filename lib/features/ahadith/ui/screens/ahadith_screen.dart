import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/features/ahadith/logic/cubit/ahadiths_cubit.dart';
import 'package:mishkat_almasabih/features/ahadith/ui/widgets/bookmark_listener.dart';
import 'package:mishkat_almasabih/features/ahadith/ui/widgets/chapter_ahadith_search_bar.dart';
import 'package:mishkat_almasabih/features/ahadith/ui/widgets/chapter_appbar.dart';
import 'package:mishkat_almasabih/features/ahadith/ui/widgets/hadith_list_builder.dart';
import 'package:mishkat_almasabih/core/widgets/hadith_card_shimer.dart';
import 'package:mishkat_almasabih/core/widgets/error_dialg.dart';
import 'package:mishkat_almasabih/features/ahadith/ui/widgets/local_hadith_list_builder.dart';

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
  final _scrollController = ScrollController();

  int _page = 1;

  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      final cubit = context.read<AhadithsCubit>();
      if (_scrollController.position.pixels >=
                  _scrollController.position.maxScrollExtent - 200 &&
              !_isLoadingMore &&
              cubit.state is AhadithsSuccess ||
          cubit.state is LocalAhadithsSuccess) {
        _loadMore();
      }
    });
  }

  final _controller = TextEditingController();
  bool checkBookSlug(String bookSlug) {
    if (bookSlug == 'sahih-bukhari' ||
        bookSlug == 'sahih-muslim' ||
        bookSlug == 'al-tirmidhi' ||
        bookSlug == 'abu-dawood' ||
        bookSlug == 'ibn-e-majah' ||
        bookSlug == 'sunan-nasai' ||
        bookSlug == 'mishkat') {
      return false;
    } else {
      return true;
    }
  }

  bool checkThreeBooks(String bookSlug) {
    if (bookSlug == 'qudsi40' ||
        bookSlug == 'nawawi40' ||
        bookSlug == 'riyadiah40' ||
        bookSlug == 'shahwaliullah40') {
      return true;
    } else {
      return false;
    }
  }

  Future<void> _loadMore() async {
    setState(() => _isLoadingMore = true);
    _page++;

    final cubit = context.read<AhadithsCubit>();

    await cubit.emitAhadiths(
      page: _page,
      paginate: 10,
      bookSlug: widget.bookSlug,
      chapterId: widget.chapterNumber ?? 1,
      isArbainBooks: checkThreeBooks(widget.bookSlug),
      hadithLocal: checkBookSlug(widget.bookSlug),
    );

    setState(() => _isLoadingMore = false);
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
              AhadithSearchBar(controller: _controller),
              SliverToBoxAdapter(child: SizedBox(height: 16.h)),
              const SliverToBoxAdapter(child: BookmarkListener()),

              BlocBuilder<AhadithsCubit, AhadithsState>(
                builder: (context, state) {
                  if (state is AhadithsSuccess) {
                    return HadithListBuilder(
                      arabicBookName: widget.arabicBookName,
                      bookSlug: widget.bookSlug,
                      state: state,
                    );
                  } else if (state is LocalAhadithsSuccess) {
                    return LocalHadithListBuilder(
                      arabicChapterName: '',
                      arabicWriterName: '',
                      authorDeath: '',
                      grade: '',

                      narrator: '',
                      arabicBookName: widget.arabicBookName,
                      bookSlug: widget.bookSlug,
                      state: state,
                    );
                  } else if (state is AhadithsLoading && _page == 1) {
                    return SliverList.builder(
                      itemCount: 6,
                      itemBuilder:
                          (context, index) => const HadithCardShimmer(),
                    );
                  } else if (state is AhadithsFailure) {
                    return SliverToBoxAdapter(
                      child: ErrorState(error: state.error),
                    );
                  }
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                },
              ),

              if (_isLoadingMore)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    child: Center(
                      child: Text(
                        'جاري تحميل المزيد...',
                        style: TextStyle(
                          color: ColorsManager.primaryGreen,
                          fontSize: 16.sp,
                        ),
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
}
