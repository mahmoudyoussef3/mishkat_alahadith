import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/widgets/segmented_tabs.dart';
import 'package:mishkat_almasabih/core/widgets/snackbars.dart';
import 'package:mishkat_almasabih/core/widgets/state_message.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_bookmark.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_juz.dart';
import 'package:mishkat_almasabih/features/quran/presentation/logic/quran_index/quran_index_cubit.dart';
import 'package:mushaf_text/mushaf_text.dart' show toArabicNumerals;

import 'juz_tile.dart';
import 'quran_bookmark_tile.dart';
import 'quran_index_row.dart';
import 'surah_filter_field.dart';
import 'surah_tile.dart';

enum QuranIndexTab {
  surahs('السور'),
  juz('الأجزاء'),
  bookmarks('العلامات');

  const QuranIndexTab(this.label);

  final String label;
}

typedef OpenQuranPage =
    void Function(int page, {int? ayahId, int? surahNumber});

/// The surah index, the juz index and the bookmarks behind one switch.
///
/// Used full-screen on the Quran home and inside a sheet over the mushaf, so
/// it takes an optional scroll controller and any slivers to show above the
/// switch. Its colours come from the palette around it.
class QuranIndexView extends StatefulWidget {
  final OpenQuranPage onOpenPage;
  final ScrollController? controller;
  final List<Widget> leadingSlivers;

  /// Marks the surah and juz being read, when shown over the mushaf.
  final int? currentPage;

  const QuranIndexView({
    super.key,
    required this.onOpenPage,
    this.controller,
    this.leadingSlivers = const [],
    this.currentPage,
  });

  @override
  State<QuranIndexView> createState() => _QuranIndexViewState();
}

class _QuranIndexViewState extends State<QuranIndexView> {
  QuranIndexTab _tab = QuranIndexTab.surahs;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: widget.controller,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        ...widget.leadingSlivers,
        SliverPadding(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 12.h),
          sliver: SliverToBoxAdapter(
            child: SegmentedTabs(
              labels: [for (final tab in QuranIndexTab.values) tab.label],
              selectedIndex: _tab.index,
              onChanged:
                  (index) =>
                      setState(() => _tab = QuranIndexTab.values[index]),
            ),
          ),
        ),
        if (_tab == QuranIndexTab.surahs)
          SliverPadding(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
            sliver: const SliverToBoxAdapter(child: SurahFilterField()),
          ),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          sliver: BlocBuilder<QuranIndexCubit, QuranIndexState>(
            builder:
                (context, state) => switch (state) {
                  QuranIndexLoading() => const QuranIndexShimmer(),
                  QuranIndexFailure(:final message) => SliverToBoxAdapter(
                    child: StateMessage.error(
                      message: message,
                      onRetry: context.read<QuranIndexCubit>().load,
                    ),
                  ),
                  QuranIndexLoaded() => switch (_tab) {
                    QuranIndexTab.surahs => _SurahList(
                      state: state,
                      currentPage: widget.currentPage,
                      onOpenPage: widget.onOpenPage,
                    ),
                    QuranIndexTab.juz => _JuzList(
                      juzList: state.juzList,
                      currentPage: widget.currentPage,
                      onOpenPage: widget.onOpenPage,
                    ),
                    QuranIndexTab.bookmarks => _BookmarkList(
                      bookmarks: state.bookmarks,
                      onOpenPage: widget.onOpenPage,
                    ),
                  },
                },
          ),
        ),
        SliverSafeArea(
          top: false,
          sliver: SliverToBoxAdapter(child: SizedBox(height: 28.h)),
        ),
      ],
    );
  }
}

class _SurahList extends StatelessWidget {
  final QuranIndexLoaded state;
  final int? currentPage;
  final OpenQuranPage onOpenPage;

  const _SurahList({
    required this.state,
    required this.currentPage,
    required this.onOpenPage,
  });

  @override
  Widget build(BuildContext context) {
    final surahs = state.visibleSurahs;
    if (surahs.isEmpty) {
      return SliverToBoxAdapter(
        child: StateMessage(
          icon: Icons.search_off_rounded,
          title: 'لا توجد سورة مطابقة',
          subtitle: 'لا توجد سورة تطابق «${state.query.trim()}»',
        ),
      );
    }
    final page = currentPage;
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: QuranIndexHeader(
            title: 'السور',
            shown: toArabicNumerals(surahs.length),
            total: toArabicNumerals(state.surahs.length),
          ),
        ),
        QuranIndexCard(
          sliver: SliverList.builder(
            itemCount: surahs.length,
            itemBuilder: (context, i) {
              final surah = surahs[i];
              return SurahTile(
                surah: surah,
                isFirst: i == 0,
                isLast: i == surahs.length - 1,
                isCurrent: page != null && surah.containsPage(page),
                onTap:
                    () => onOpenPage(
                      surah.startPage,
                      surahNumber: surah.number,
                    ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _JuzList extends StatelessWidget {
  final List<QuranJuz> juzList;
  final int? currentPage;
  final OpenQuranPage onOpenPage;

  const _JuzList({
    required this.juzList,
    required this.currentPage,
    required this.onOpenPage,
  });

  @override
  Widget build(BuildContext context) {
    final page = currentPage;
    final current =
        page == null ? null : QuranJuz.containingPage(juzList, page);
    final total = toArabicNumerals(juzList.length);
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: QuranIndexHeader(title: 'الأجزاء', shown: total, total: total),
        ),
        QuranIndexCard(
          sliver: SliverList.builder(
            itemCount: juzList.length,
            itemBuilder: (context, i) {
              final juz = juzList[i];
              return JuzTile(
                juz: juz,
                isFirst: i == 0,
                isLast: i == juzList.length - 1,
                isCurrent: juz.number == current?.number,
                onTap: () => onOpenPage(juz.startPage),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _BookmarkList extends StatelessWidget {
  final List<QuranBookmark>? bookmarks;
  final OpenQuranPage onOpenPage;

  const _BookmarkList({required this.bookmarks, required this.onOpenPage});

  @override
  Widget build(BuildContext context) {
    final bookmarks = this.bookmarks;
    if (bookmarks == null) {
      return SliverToBoxAdapter(
        child: StateMessage.error(
          message: 'تعذر تحميل العلامات المحفوظة',
          onRetry: context.read<QuranIndexCubit>().refreshReadingData,
        ),
      );
    }
    if (bookmarks.isEmpty) {
      return const SliverToBoxAdapter(
        child: StateMessage(
          icon: Icons.bookmark_add_outlined,
          title: 'لا توجد علامات بعد',
          subtitle:
              'احفظ صفحتك من شريط القراءة، أو آية بالضغط عليها في المصحف.',
        ),
      );
    }
    final total = toArabicNumerals(bookmarks.length);
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: QuranIndexHeader(
            title: 'العلامات المحفوظة',
            shown: total,
            total: total,
          ),
        ),
        QuranIndexCard(
          sliver: SliverList.builder(
            itemCount: bookmarks.length,
            itemBuilder: (context, i) {
              final bookmark = bookmarks[i];
              return QuranBookmarkTile(
                bookmark: bookmark,
                isFirst: i == 0,
                isLast: i == bookmarks.length - 1,
                onTap:
                    () => onOpenPage(
                      bookmark.page,
                      ayahId: bookmark.ayahId,
                      surahNumber: bookmark.surahNumber,
                    ),
                onDelete: () => _delete(context, bookmark),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _delete(BuildContext context, QuranBookmark bookmark) async {
    final removed = await context.read<QuranIndexCubit>().removeBookmark(
      bookmark,
    );
    if (!removed && context.mounted) {
      showErrorSnackbar(context, 'تعذر حذف العلامة، حاول مرة أخرى');
    }
  }
}
