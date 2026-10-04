import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/functions.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/core/widgets/hadith_card_shimer.dart';
import 'package:mishkat_almasabih/core/widgets/state_message.dart';
import 'package:mishkat_almasabih/features/bookmark/domain/entities/user_bookmark.dart';
import 'package:mishkat_almasabih/features/bookmark/presentation/logic/get_bookmarks/user_bookmarks_cubit.dart';
import 'package:mishkat_almasabih/features/chapters/presentation/ui/widgets/chapters_grid_view.dart';
import 'package:mishkat_almasabih/features/hadith_details/presentation/ui/screens/hadith_details_screen.dart';

/// Saved hadiths (filtered by collection and text) or saved chapters, as a
/// sliver.
class BookmarkList extends StatelessWidget {
  /// Collection to show; null shows every collection.
  final String? selectedCollection;
  final String query;
  final bool showHadiths;

  const BookmarkList({
    super.key,
    required this.selectedCollection,
    required this.query,
    required this.showHadiths,
  });

  List<UserBookmark> _visibleHadiths(List<UserBookmark> bookmarks) {
    final normalizedQuery = normalizeArabic(query).toLowerCase();
    return [
      for (final bookmark in bookmarks)
        if (bookmark.type == 'hadith' &&
            (selectedCollection == null ||
                bookmark.collection == selectedCollection) &&
            (normalizedQuery.isEmpty ||
                normalizeArabic(
                  '${bookmark.hadithText ?? ''} ${bookmark.notes ?? ''}',
                ).toLowerCase().contains(normalizedQuery)))
          bookmark,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetBookmarksCubit, GetBookmarksState>(
      builder: (context, state) {
        switch (state) {
          case UserBookmarksSuccess(:final bookmarks):
            return showHadiths
                ? _hadiths(_visibleHadiths(bookmarks))
                : _chapters([
                  for (final bookmark in bookmarks)
                    if (bookmark.type == 'chapter') bookmark,
                ]);
          case GetBookmarksFailure(:final message):
            return SliverToBoxAdapter(
              child: StateMessage.error(
                message: message,
                onRetry:
                    () => context.read<GetBookmarksCubit>().getUserBookmarks(),
              ),
            );
          default:
            return SliverList.builder(
              itemCount: 4,
              itemBuilder: (_, __) => const HadithCardShimmer(),
            );
        }
      },
    );
  }

  Widget _hadiths(List<UserBookmark> hadiths) {
    if (hadiths.isEmpty) {
      return SliverToBoxAdapter(
        child: StateMessage(
          icon: Icons.bookmark_border_rounded,
          title:
              query.isNotEmpty
                  ? 'لا توجد نتائج مطابقة'
                  : selectedCollection != null
                  ? 'لا توجد أحاديث في هذه المجموعة'
                  : 'لم تحفظ أي حديث بعد',
          subtitle:
              query.isEmpty && selectedCollection == null
                  ? 'اضغط على أيقونة الحفظ في أي حديث ليظهر هنا'
                  : null,
        ),
      );
    }
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 24.h),
      sliver: SliverList.separated(
        itemCount: hadiths.length,
        separatorBuilder: (_, __) => SizedBox(height: 10.h),
        itemBuilder: (context, index) => _SavedHadithTile(hadiths[index]),
      ),
    );
  }

  Widget _chapters(List<UserBookmark> chapters) {
    if (chapters.isEmpty) {
      return const SliverToBoxAdapter(
        child: StateMessage(
          icon: Icons.bookmarks_outlined,
          title: 'لم تحفظ أي باب بعد',
          subtitle: 'احفظ الأبواب من صفحة الكتاب للرجوع إليها بسرعة',
        ),
      );
    }
    final first = chapters.first;
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 24.h),
      sliver: ResponsiveChapterList(
        items: chapters,
        primaryPurple: ColorsManager.primaryPurple,
        bookName: first.bookName ?? '',
        writerName: '',
        bookSlug: first.bookSlug ?? '',
      ),
    );
  }
}

class _SavedHadithTile extends StatelessWidget {
  const _SavedHadithTile(this.bookmark);

  final UserBookmark bookmark;

  void _open(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => HadithDetailScreen(
              isLocal: false,
              showNavigation: false,
              chapterNumber: bookmark.chapterNumber.toString(),
              bookName: bookmark.bookName,
              isBookMark: true,
              hadithText: bookmark.hadithText,
              chapter: bookmark.chapterName,
              hadithNumber: bookmark.id.toString(),
              bookSlug: bookmark.bookSlug,
              narrator: '',
              grade: '',
              author: '',
              authorDeath: '',
            ),
      ),
    );
  }

  Future<void> _confirmRemove(BuildContext context) async {
    final id = bookmark.id;
    if (id == null) return;
    final cubit = context.read<GetBookmarksCubit>();
    final remove = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              title: const Text('إزالة من المحفوظات؟'),
              content: const Text('يمكنك حفظ الحديث مرة أخرى في أي وقت.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('إلغاء'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: ColorsManager.error,
                  ),
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text('إزالة'),
                ),
              ],
            ),
          ),
    );
    if (remove ?? false) await cubit.deleteBookmark(id);
  }

  @override
  Widget build(BuildContext context) {
    final source = [
      bookmark.bookName,
      bookmark.hadithNumber,
    ].where((part) => part != null && part.trim().isNotEmpty).join(' · ');
    final notes = bookmark.notes?.trim() ?? '';

    return Material(
      color: ColorsManager.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
        side: BorderSide(color: ColorsManager.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _open(context),
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(16.w, 14.h, 6.w, 14.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bookmark.hadithText ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyles.hadithPreview.copyWith(
                        fontSize: 17.sp,
                        height: 1.9,
                      ),
                    ),
                    if (source.isNotEmpty) ...[
                      SizedBox(height: 4.h),
                      Text(
                        source,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyles.caption.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    if (notes.isNotEmpty) ...[
                      SizedBox(height: 10.h),
                      _Notes(notes),
                    ],
                  ],
                ),
              ),
              IconButton(
                tooltip: 'إزالة من المحفوظات',
                onPressed: () => _confirmRemove(context),
                icon: Icon(
                  Icons.bookmark_rounded,
                  size: 22.r,
                  color: ColorsManager.purpleText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Notes extends StatelessWidget {
  const _Notes(this.notes);

  final String notes;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: ColorsManager.goldSoft,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.edit_note_rounded,
            size: 18.r,
            color: ColorsManager.goldInk,
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(
              notes,
              style: TextStyles.caption.copyWith(
                color: ColorsManager.goldInk,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
