import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/arabic_digits.dart';
import 'package:mishkat_almasabih/core/helpers/arabic_time_format.dart';
import 'package:mishkat_almasabih/core/helpers/functions.dart';
import 'package:mishkat_almasabih/core/helpers/hadith_text.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/core/widgets/app_badge.dart';
import 'package:mishkat_almasabih/core/widgets/state_message.dart';
import 'package:mishkat_almasabih/features/ahadith/presentation/ui/widgets/chapter_hadith_tile.dart';
import 'package:mishkat_almasabih/features/bookmark/domain/entities/user_bookmark.dart';
import 'package:mishkat_almasabih/features/bookmark/presentation/logic/get_bookmarks/user_bookmarks_cubit.dart';
import 'package:mishkat_almasabih/features/chapters/domain/entities/book_chapter.dart';
import 'package:mishkat_almasabih/features/chapters/presentation/ui/helpers/open_chapter.dart';
import 'package:mishkat_almasabih/features/chapters/presentation/ui/models/book_chapters_args.dart';
import 'package:mishkat_almasabih/features/hadith_details/presentation/ui/screens/hadith_details_screen.dart';
import 'package:mishkat_almasabih/features/reading_preferences/presentation/ui/hadith_text.dart';

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
              itemBuilder: (_, _) => const ChapterHadithTileShimmer(),
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
        separatorBuilder: (_, _) => SizedBox(height: 12.h),
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
          subtitle: 'احفظ الأبواب من صفحة الباب للرجوع إليها بسرعة',
        ),
      );
    }
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
      sliver: SliverList.separated(
        itemCount: chapters.length,
        separatorBuilder: (_, _) => SizedBox(height: 10.h),
        itemBuilder: (context, index) => _SavedChapterTile(chapters[index]),
      ),
    );
  }
}

/// Asks before removing [bookmark], then removes it.
Future<void> _confirmRemove(BuildContext context, UserBookmark bookmark) async {
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
            content: const Text('يمكنك حفظه مرة أخرى في أي وقت.'),
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

class _SavedHadithTile extends StatelessWidget {
  const _SavedHadithTile(this.bookmark);

  final UserBookmark bookmark;

  String get _source => [
    bookmark.bookName,
    if (bookmark.hadithNumber case final number? when number.trim().isNotEmpty)
      toArabicDigits('حديث $number'),
  ].where((part) => part != null && part.trim().isNotEmpty).join(' · ');

  String? get _savedWhen {
    final saved = DateTime.tryParse(bookmark.createdAt ?? '');
    if (saved == null) return null;
    return formatArabicRelativeDay(saved.toLocal(), now: DateTime.now());
  }

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
              hadithNumber: bookmark.hadithNumber ?? bookmark.hadithId ?? '',
              bookSlug: bookmark.bookSlug,
              narrator: '',
              grade: '',
              author: '',
              authorDeath: '',
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final source = _source;
    final notes = bookmark.notes?.trim() ?? '';
    final collection = bookmark.collection?.trim() ?? '';
    final savedWhen = _savedWhen;
    final text = bookmark.hadithText ?? '';

    return Material(
      color: ColorsManager.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22.r),
        side: BorderSide(color: ColorsManager.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _open(context),
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(16.w, 8.h, 6.w, 14.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  if (collection.isNotEmpty) ...[
                    Flexible(
                      child: AppBadge(
                        label: collection,
                        icon: Icons.folder_rounded,
                        background: ColorsManager.primarySoft,
                        foreground: ColorsManager.purpleText,
                      ),
                    ),
                    SizedBox(width: 6.w),
                  ],
                  if (savedWhen != null)
                    Text(
                      savedWhen,
                      style: TextStyles.labelSmall.copyWith(color: ColorsManager.gray),
                    ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'إزالة من المحفوظات',
                    visualDensity: VisualDensity.compact,
                    onPressed: () => _confirmRemove(context, bookmark),
                    icon: Icon(
                      Icons.bookmark_rounded,
                      size: 21.r,
                      color: ColorsManager.purpleText,
                    ),
                  ),
                  PopupMenuButton<VoidCallback>(
                    tooltip: 'المزيد',
                    icon: Icon(
                      Icons.more_vert_rounded,
                      size: 21.r,
                      color: ColorsManager.gray,
                    ),
                    onSelected: (action) => action(),
                    itemBuilder:
                        (menuContext) => [
                          PopupMenuItem(
                            value: () => _open(context),
                            child: const Text('فتح الحديث'),
                          ),
                          PopupMenuItem(
                            value: () => copyHadithText(context, HadithTextParts.typeset(text)),
                            child: const Text('نسخ النص'),
                          ),
                          PopupMenuItem(
                            value:
                                () => shareHadithText(
                                  context,
                                  text: HadithTextParts.typeset(text),
                                  source: source,
                                ),
                            child: const Text('مشاركة'),
                          ),
                          PopupMenuItem(
                            value: () => _confirmRemove(context, bookmark),
                            child: Text(
                              'إزالة من المحفوظات',
                              style: TextStyle(color: ColorsManager.error),
                            ),
                          ),
                        ],
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsetsDirectional.only(end: 10.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    HadithText(
                      HadithTextParts.split(text).matn,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyles.readingMedium.copyWith(
                        fontWeight: FontWeight.w700,
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
            ],
          ),
        ),
      ),
    );
  }
}

class _SavedChapterTile extends StatelessWidget {
  const _SavedChapterTile(this.bookmark);

  final UserBookmark bookmark;

  void _open(BuildContext context) => openChapter(
    context,
    book: BookChaptersArgs(
      bookSlug: bookmark.bookSlug ?? '',
      bookName: bookmark.bookName ?? '',
    ),
    chapter: BookChapter(
      chapterNumber: bookmark.chapterNumber,
      chapterArabic: bookmark.chapterName,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final number = bookmark.chapterNumber;
    return Material(
      color: ColorsManager.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18.r),
        side: BorderSide(color: ColorsManager.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _open(context),
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(14.w, 12.h, 4.w, 12.h),
          child: Row(
            children: [
              Container(
                width: 38.r,
                height: 38.r,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: ColorsManager.primarySoft,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  number == null ? '' : toArabicDigits('$number'),
                  style: TextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.w800,
                    color: ColorsManager.purpleText,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bookmark.chapterName ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.5,
                      ),
                    ),
                    if ((bookmark.bookName ?? '').isNotEmpty)
                      Text(bookmark.bookName!, style: TextStyles.caption),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'إزالة من المحفوظات',
                onPressed: () => _confirmRemove(context, bookmark),
                icon: Icon(
                  Icons.bookmark_rounded,
                  size: 21.r,
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
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: ColorsManager.goldSoft,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.edit_note_rounded,
            size: 18.r,
            color: ColorsManager.primaryGold,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              notes,
              style: TextStyles.caption.copyWith(
                fontSize: 13.sp,
                color: ColorsManager.goldInk,
                height: 1.7,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
