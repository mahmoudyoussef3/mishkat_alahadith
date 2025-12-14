import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:mishkat_almasabih/core/helpers/functions.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/widgets/error_dialg.dart';
import 'package:mishkat_almasabih/core/widgets/hadith_card_shimer.dart';
import 'package:mishkat_almasabih/features/ahadith/ui/widgets/chapter_ahadith_card.dart';
import 'package:mishkat_almasabih/features/ahadith/ui/widgets/separator.dart';
import 'package:mishkat_almasabih/features/bookmark/data/models/book_mark_model.dart';
import 'package:mishkat_almasabih/features/bookmark/logic/get_cubit/user_bookmarks_cubit.dart';
import 'package:mishkat_almasabih/features/bookmark/ui/widgets/bookmark_empty_state.dart';
import 'package:mishkat_almasabih/features/chapters/ui/widgets/chapters_grid_view.dart';
import 'package:mishkat_almasabih/features/hadith_details/ui/screens/hadith_details_screen.dart';

class BookmarkList extends StatefulWidget {
  final String selectedCollection;
  final String query;
  final bool showHadiht;

  const BookmarkList({
    super.key,
    required this.selectedCollection,
    required this.query,
    required this.showHadiht,
  });

  @override
  State<BookmarkList> createState() => _BookmarkListState();
}

class _BookmarkListState extends State<BookmarkList> {
  String formatDateArabic(String? utcString) {
    if (utcString == null || utcString.isEmpty) return '';
    try {
      final utcTime = DateTime.parse(utcString);
      final localTime = utcTime.toLocal();
      return DateFormat('d MMMM yyyy - h:mm a', 'ar').format(localTime);
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetBookmarksCubit, GetBookmarksState>(
      builder: (context, state) {
        if (state is GetBookmarksLoading) {
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, _) => Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
                child: const HadithCardShimmer(),
              ),
              childCount: 6,
            ),
          );
        }

        if (state is GetBookmarksFailure) {
          return SliverToBoxAdapter(child: ErrorState(error: state.message));
        }

        if (state is UserBookmarksSuccess) {
          final bookmarks = state.bookmarks;

          // ✅ تقسيم الـ bookmarks
          final ahadith = bookmarks.where((b) => b.type == 'hadith').toList();
          final chapters = bookmarks.where((b) => b.type == 'chapter').toList();

          // ✅ فلترة حسب المجموعة
          final filteredCollection = widget.selectedCollection == "الكل"
              ? ahadith
              : ahadith
                  .where((b) => b.collection == widget.selectedCollection)
                  .toList();

          // ✅ فلترة حسب البحث
          final filteredSearch = widget.query.isEmpty
              ? filteredCollection
              : filteredCollection.where((b) {
                  final normalizedText =
                      normalizeArabic(b.hadithText ?? '').toLowerCase();
                  final normalizedNotes =
                      normalizeArabic(b.notes ?? '').toLowerCase();
                  final query = widget.query.toLowerCase();
                  return normalizedText.contains(query) ||
                      normalizedNotes.contains(query);
                }).toList();

          log("✅ Chapters loaded: ${chapters.length}");

          // ✅ لو مفيش نتائج
          if (filteredSearch.isEmpty && widget.showHadiht) {
            return const SliverToBoxAdapter(child: BookmarkEmptyState());
          }

          return SliverToBoxAdapter(
            child: Column(
              children: [
                widget.showHadiht
                    ? _buildHadithList(filteredSearch)
                    : _buildChapterList(chapters),
              ],
            ),
          );
        }

        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }

  /// 🕌 قائمة الأحاديث
  Widget _buildHadithList(List<Bookmark> filteredSearch) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredSearch.length,
      separatorBuilder: (_, __) => const IslamicSeparator(
        
      ),
      itemBuilder: (context, index) {
        final hadith = filteredSearch[index];
        final createdAt = formatDateArabic(hadith.createdAt);

        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => HadithDetailScreen(
                isLocal: false,
                showNavigation: false,
                chapterNumber: hadith.chapterNumber.toString(),
                bookName: hadith.bookName,
                isBookMark: true,
                hadithText: hadith.hadithText,
                chapter: hadith.chapterName,
                hadithNumber: hadith.id.toString(),
                bookSlug: hadith.bookSlug,
                narrator: '',
                grade: '',
                author: '',
                authorDeath: '',
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ChapterAhadithCard(
                grade: convertToArabicNumber(index + 1),
                reference: createdAt,
                number: hadith.hadithNumber ?? '',
                text: hadith.hadithText ?? '',
                bookName: hadith.bookName ?? '',
              ),
              if ((hadith.notes ?? '').isNotEmpty) _buildNotes(hadith.notes!),
            ],
          ),
        );
      },
    );
  }

  /// 📚 قائمة الفصول
  Widget _buildChapterList(List<Bookmark> chapters) {
    final firstChapter = chapters.isNotEmpty ? chapters.first : null;
    return SizedBox(
      height: 600.h,
      child: CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        
        slivers: [
          SliverToBoxAdapter(child: SizedBox(height: 18.h)),
          ResponsiveChapterList(
            items: chapters,
            primaryPurple: ColorsManager.primaryGreen,
            bookName: firstChapter?.bookName ?? '',
            writerName: '',
            bookSlug: firstChapter?.bookSlug ?? '',
          ),
        ],
      ),
    );
  }

  /// 📝 ويدجت الملاحظات
  Widget _buildNotes(String notes) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: ColorsManager.mediumGray.withOpacity(0.4),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Text(
          "📝 الملاحظات: $notes",
          style: TextStyle(
            fontSize: 13.sp,
            color: ColorsManager.secondaryText,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
}
