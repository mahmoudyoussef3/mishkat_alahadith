import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/arabic_digits.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/widgets/screen_title_header.dart';
import 'package:mishkat_almasabih/core/widgets/segmented_tabs.dart';
import 'package:mishkat_almasabih/core/widgets/state_message.dart';
import 'package:mishkat_almasabih/features/authentication/session/presentation/logic/session_cubit.dart';
import 'package:mishkat_almasabih/features/bookmark/presentation/logic/collections/get_collections_bookmark_cubit.dart';
import 'package:mishkat_almasabih/features/bookmark/presentation/logic/get_bookmarks/user_bookmarks_cubit.dart';
import 'package:mishkat_almasabih/features/bookmark/presentation/ui/widgets/book_collections_row.dart';
import 'package:mishkat_almasabih/features/bookmark/presentation/ui/widgets/bookmark_list.dart';
import 'package:mishkat_almasabih/features/home/presentation/ui/widgets/search_bar_widget.dart';

/// Saved hadiths and chapters, with collection folders and a text filter.
class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  final TextEditingController _searchController = TextEditingController();

  /// Selected collection; null shows every collection.
  String? _collection;
  String _query = '';
  bool _showHadiths = true;

  @override
  void initState() {
    super.initState();
    context.read<SessionCubit>().checkSession();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    if (!context.read<SessionCubit>().isSignedIn) return;
    await Future.wait([
      context.read<GetBookmarksCubit>().getUserBookmarks(),
      context.read<GetCollectionsBookmarkCubit>().getBookMarkCollections(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: ColorsManager.secondaryBackground,
        body: SafeArea(
          bottom: false,
          child: BlocBuilder<SessionCubit, SessionState>(
            builder:
                (context, session) => switch (session) {
                  SessionUnknown() => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  SessionSignedIn() => _buildContent(),
                  SessionSignedOut() => const _SignedOutView(),
                },
          ),
        ),
      ),
    );
  }

  /// Clears the collection filter once that collection no longer exists,
  /// since its tile, the only way to clear it, is gone too.
  void _dropMissingCollection(GetCollectionsBookmarkState state) {
    final selected = _collection;
    if (selected == null || state is! GetCollectionsBookmarkSuccess) return;
    if (state.collections.any((c) => c.collection == selected)) return;
    setState(() => _collection = null);
  }

  Widget _buildContent() {
    return BlocListener<
      GetCollectionsBookmarkCubit,
      GetCollectionsBookmarkState
    >(
      listener: (context, state) => _dropMissingCollection(state),
      child: _buildScrollView(),
    );
  }

  Widget _buildScrollView() {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          const SliverToBoxAdapter(
            child: ScreenTitleHeader(title: 'المحفوظات'),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
              child: BlocSelector<
                GetBookmarksCubit,
                GetBookmarksState,
                (int, int)?
              >(
                selector:
                    (state) => switch (state) {
                      UserBookmarksSuccess(:final bookmarks) => (
                        bookmarks.where((b) => b.type == 'hadith').length,
                        bookmarks.where((b) => b.type == 'chapter').length,
                      ),
                      _ => null,
                    },
                builder:
                    (context, counts) => SegmentedTabs(
                      labels: [
                        _withCount('الأحاديث', counts?.$1),
                        _withCount('الأبواب', counts?.$2),
                      ],
                      selectedIndex: _showHadiths ? 0 : 1,
                      onChanged:
                          (index) => setState(() => _showHadiths = index == 0),
                    ),
              ),
            ),
          ),
          if (_showHadiths) ...[
            SliverToBoxAdapter(
              child: BookmarkCollectionsRow(
                selectedCollection: _collection,
                onCollectionSelected:
                    (collection) => setState(() => _collection = collection),
              ),
            ),
            SliverToBoxAdapter(
              // Nothing to filter until a hadith has been saved.
              child: BlocSelector<GetBookmarksCubit, GetBookmarksState, bool>(
                selector:
                    (state) =>
                        state is UserBookmarksSuccess &&
                        state.bookmarks.any((b) => b.type == 'hadith'),
                builder:
                    (context, hasHadiths) =>
                        hasHadiths
                            ? Padding(
                              padding: EdgeInsets.fromLTRB(
                                20.w,
                                14.h,
                                20.w,
                                10.h,
                              ),
                              child: SearchBarWidget(
                                hintText: 'ابحث في نص الحديث أو ملاحظاتك…',
                                controller: _searchController,
                                onChanged:
                                    (value) =>
                                        setState(() => _query = value.trim()),
                              ),
                            )
                            : SizedBox(height: 8.h),
              ),
            ),
          ],
          BookmarkList(
            selectedCollection: _collection,
            query: _query,
            showHadiths: _showHadiths,
          ),
        ],
      ),
    );
  }

  static String _withCount(String label, int? count) =>
      count == null || count == 0
          ? label
          : '$label · ${toArabicDigits('$count')}';
}

class _SignedOutView extends StatelessWidget {
  const _SignedOutView();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ScreenTitleHeader(title: 'المحفوظات'),
        Expanded(
          child: Center(
            child: StateMessage(
              icon: Icons.bookmark_border_rounded,
              title: 'احفظ الأحاديث التي تحبها',
              subtitle:
                  'سجّل الدخول لحفظ الأحاديث وتنظيمها في مجموعات '
                  'والرجوع إليها من أي جهاز',
              actionLabel: 'تسجيل الدخول',
              actionIcon: Icons.login_rounded,
              onAction: () => Navigator.pushNamed(context, Routes.loginScreen),
            ),
          ),
        ),
      ],
    );
  }
}
