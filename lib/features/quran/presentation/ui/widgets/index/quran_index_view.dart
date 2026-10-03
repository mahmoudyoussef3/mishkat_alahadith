import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/quran_decorations.dart';
import 'package:mishkat_almasabih/core/theming/quran_styles.dart';
import 'package:mishkat_almasabih/core/widgets/snackbars.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_bookmark.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_juz.dart';
import 'package:mishkat_almasabih/features/quran/presentation/logic/quran_index/quran_index_cubit.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/widgets/common/quran_message_view.dart';

import 'juz_tile.dart';
import 'quran_bookmark_tile.dart';
import 'surah_filter_field.dart';
import 'surah_tile.dart';

enum QuranIndexTab {
  surahs('السور', Icons.format_list_numbered_rtl_rounded),
  juz('الأجزاء', Icons.layers_rounded),
  bookmarks('العلامات', Icons.bookmarks_rounded);

  const QuranIndexTab(this.label, this.icon);

  final String label;
  final IconData icon;
}

typedef OpenQuranPage = void Function(int page, {int? ayahId});

/// The surah index, the juz index and the bookmarks behind one switch.
///
/// Used full-screen on the Quran hub and inside a sheet over the mushaf, so it
/// takes its colours, an optional scroll controller and any slivers to show
/// above the switch.
class QuranIndexView extends StatefulWidget {
  final QuranSurfaceColors colors;
  final OpenQuranPage onOpenPage;
  final ScrollController? controller;
  final List<Widget> leadingSlivers;

  /// Marks the surah and juz being read, when shown over the mushaf.
  final int? currentPage;

  const QuranIndexView({
    super.key,
    required this.colors,
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
    final colors = widget.colors;
    return CustomScrollView(
      controller: widget.controller,
      slivers: [
        ...widget.leadingSlivers,
        SliverPadding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 10.h),
          sliver: SliverToBoxAdapter(
            child: _IndexTabSelector(
              colors: colors,
              selected: _tab,
              onSelected: (tab) => setState(() => _tab = tab),
            ),
          ),
        ),
        if (_tab == QuranIndexTab.surahs)
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 10.h),
            sliver: SliverToBoxAdapter(child: SurahFilterField(colors: colors)),
          ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 28.h),
          sliver: BlocBuilder<QuranIndexCubit, QuranIndexState>(
            builder:
                (context, state) => switch (state) {
                  QuranIndexLoading() => const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  QuranIndexFailure(:final message) => SliverToBoxAdapter(
                    child: QuranMessageView(
                      colors: colors,
                      icon: Icons.error_outline_rounded,
                      message: message,
                      actionLabel: 'إعادة المحاولة',
                      onAction: context.read<QuranIndexCubit>().load,
                    ),
                  ),
                  QuranIndexLoaded() => switch (_tab) {
                    QuranIndexTab.surahs => _SurahList(
                      state: state,
                      colors: colors,
                      currentPage: widget.currentPage,
                      onOpenPage: widget.onOpenPage,
                    ),
                    QuranIndexTab.juz => _JuzList(
                      juzList: state.juzList,
                      colors: colors,
                      currentPage: widget.currentPage,
                      onOpenPage: widget.onOpenPage,
                    ),
                    QuranIndexTab.bookmarks => _BookmarkList(
                      bookmarks: state.bookmarks,
                      colors: colors,
                      onOpenPage: widget.onOpenPage,
                    ),
                  },
                },
          ),
        ),
      ],
    );
  }
}

class _IndexTabSelector extends StatelessWidget {
  final QuranSurfaceColors colors;
  final QuranIndexTab selected;
  final ValueChanged<QuranIndexTab> onSelected;

  const _IndexTabSelector({
    required this.colors,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.r),
      decoration: QuranDecorations.tabSelector(colors),
      child: Row(
        children: [
          for (final tab in QuranIndexTab.values)
            Expanded(
              child: Semantics(
                selected: tab == selected,
                button: true,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onSelected(tab),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    padding: EdgeInsets.symmetric(vertical: 9.h),
                    decoration:
                        tab == selected
                            ? QuranDecorations.tabSelectorPill(colors)
                            : null,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          tab.icon,
                          size: 16.sp,
                          color:
                              tab == selected
                                  ? colors.background
                                  : colors.subtitle,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          tab.label,
                          style: QuranTextStyles.tabLabel(
                            tab == selected
                                ? colors.background
                                : colors.subtitle,
                            selected: tab == selected,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SurahList extends StatelessWidget {
  final QuranIndexLoaded state;
  final QuranSurfaceColors colors;
  final int? currentPage;
  final OpenQuranPage onOpenPage;

  const _SurahList({
    required this.state,
    required this.colors,
    required this.currentPage,
    required this.onOpenPage,
  });

  @override
  Widget build(BuildContext context) {
    final surahs = state.visibleSurahs;
    if (surahs.isEmpty) {
      return SliverToBoxAdapter(
        child: QuranMessageView(
          colors: colors,
          icon: Icons.search_off_rounded,
          message: 'لا توجد سورة تطابق «${state.query.trim()}»',
        ),
      );
    }
    final page = currentPage;
    return SliverList.separated(
      itemCount: surahs.length,
      separatorBuilder: (_, __) => SizedBox(height: 8.h),
      itemBuilder: (context, i) {
        final surah = surahs[i];
        return SurahTile(
          surah: surah,
          colors: colors,
          isCurrent: page != null && surah.containsPage(page),
          onTap: () => onOpenPage(surah.startPage),
        );
      },
    );
  }
}

class _JuzList extends StatelessWidget {
  final List<QuranJuz> juzList;
  final QuranSurfaceColors colors;
  final int? currentPage;
  final OpenQuranPage onOpenPage;

  const _JuzList({
    required this.juzList,
    required this.colors,
    required this.currentPage,
    required this.onOpenPage,
  });

  @override
  Widget build(BuildContext context) {
    final page = currentPage;
    final current =
        page == null ? null : QuranJuz.containingPage(juzList, page);
    return SliverList.separated(
      itemCount: juzList.length,
      separatorBuilder: (_, __) => SizedBox(height: 8.h),
      itemBuilder: (context, i) {
        final juz = juzList[i];
        return JuzTile(
          juz: juz,
          colors: colors,
          isCurrent: juz.number == current?.number,
          onTap: () => onOpenPage(juz.startPage),
        );
      },
    );
  }
}

class _BookmarkList extends StatelessWidget {
  final List<QuranBookmark>? bookmarks;
  final QuranSurfaceColors colors;
  final OpenQuranPage onOpenPage;

  const _BookmarkList({
    required this.bookmarks,
    required this.colors,
    required this.onOpenPage,
  });

  @override
  Widget build(BuildContext context) {
    final bookmarks = this.bookmarks;
    if (bookmarks == null) {
      return SliverToBoxAdapter(
        child: QuranMessageView(
          colors: colors,
          icon: Icons.error_outline_rounded,
          message: 'تعذر تحميل العلامات المحفوظة',
          actionLabel: 'إعادة المحاولة',
          onAction: context.read<QuranIndexCubit>().refreshReadingData,
        ),
      );
    }
    if (bookmarks.isEmpty) {
      return SliverToBoxAdapter(
        child: QuranMessageView(
          colors: colors,
          icon: Icons.bookmark_add_outlined,
          message:
              'لا توجد علامات بعد.\nاحفظ صفحتك من شريط القراءة، أو آية '
              'بالضغط عليها في المصحف.',
        ),
      );
    }
    return SliverList.separated(
      itemCount: bookmarks.length,
      separatorBuilder: (_, __) => SizedBox(height: 8.h),
      itemBuilder: (context, i) {
        final bookmark = bookmarks[i];
        return QuranBookmarkTile(
          bookmark: bookmark,
          colors: colors,
          onTap: () => onOpenPage(bookmark.page, ayahId: bookmark.ayahId),
          onDelete: () => _delete(context, bookmark),
        );
      },
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
