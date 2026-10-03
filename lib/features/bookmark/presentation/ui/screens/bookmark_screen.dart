import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';
import 'package:mishkat_almasabih/features/bookmark/presentation/logic/collections/get_collections_bookmark_cubit.dart';
import 'package:mishkat_almasabih/features/bookmark/presentation/logic/get_bookmarks/user_bookmarks_cubit.dart';
import 'package:mishkat_almasabih/features/authentication/session/presentation/logic/session_cubit.dart';
import 'package:mishkat_almasabih/core/helpers/spacing.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/core/theming/bookmark_styles.dart';
import 'package:mishkat_almasabih/core/theming/bookmark_decorations.dart';
import 'package:mishkat_almasabih/features/bookmark/presentation/ui/widgets/book_collections_row.dart';
import 'package:mishkat_almasabih/features/bookmark/presentation/ui/widgets/bookmark_list.dart';
import 'package:mishkat_almasabih/features/home/presentation/ui/widgets/build_header_app_bar.dart';
import 'package:mishkat_almasabih/features/home/presentation/ui/widgets/search_bar_widget.dart';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  String selectedCollection = "الكل";
  final TextEditingController _searchController = TextEditingController();
  String _query = "";
  bool showHadith = true;

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

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        if (!context.read<SessionCubit>().isSignedIn) return;
        await Future.wait([
          BlocProvider.of<GetBookmarksCubit>(context).getUserBookmarks(),
          BlocProvider.of<GetCollectionsBookmarkCubit>(
            context,
          ).getBookMarkCollections(),
        ]);
      },
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          top: true,
          bottom: true,
          child: Scaffold(
            backgroundColor: ColorsManager.secondaryBackground,
            body: BlocBuilder<SessionCubit, SessionState>(
              builder:
                  (context, session) => switch (session) {
                    SessionUnknown() => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    SessionSignedIn() => _buildBookmarkContent(),
                    SessionSignedOut() => _buildLoginPrompt(context),
                  },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookmarkContent() {
    return CustomScrollView(
      slivers: [
        BuildHeaderAppBar(bottomNav: true, title: "العلامات المرجعية"),

        SliverToBoxAdapter(child: SizedBox(height: 16.h)),

        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Row(
              children: [
                _buildTabButton(
                  "الأحاديث",
                  isActive: showHadith,
                  isHadith: true,
                ),
                SizedBox(width: 12.w),
                _buildTabButton(
                  "الأبواب",
                  isActive: !showHadith,
                  isHadith: false,
                ),
              ],
            ),
          ),
        ),

        if (showHadith)
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: _buildSearchField(),
            ),
          ),

        if (showHadith)
          SliverToBoxAdapter(
            child: BookmarkCollectionsRow(
              selectedCollection: selectedCollection,
              onCollectionSelected: (collection) {
                setState(() => selectedCollection = collection);
              },
            ),
          ),

        BookmarkList(
          selectedCollection: selectedCollection,
          query: _query,
          showHadiht: showHadith,
        ),
      ],
    );
  }

  Widget _buildTabButton(
    String title, {
    required bool isActive,
    required bool isHadith,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => showHadith = isHadith),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BookmarkDecorations.tabContainer(isActive: isActive),
          alignment: Alignment.center,
          child: Text(
            title,
            style: BookmarkTextStyles.tabLabel(isActive: isActive),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return SearchBarWidget(
      hintText: 'ابحث بنص الحديث أو الملاحظات...',
      controller: _searchController,
      onChanged: (value) => setState(() => _query = value),
    );
  }

  Widget _buildLoginPrompt(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline,
              size: 90.r,
              color: ColorsManager.primaryGreen,
            ),
            SizedBox(height: 20.h),
            Text(
              "يجب تسجيل الدخول للوصول إلى العلامات المرجعية",
              textAlign: TextAlign.center,
              style: TextStyles.bodyLarge.copyWith(
                color: ColorsManager.darkGray,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 30.h),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorsManager.primaryGreen,
                padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
              onPressed: () => Navigator.pushNamed(context, Routes.loginScreen),
              icon: const Icon(Icons.login, color: Colors.white),
              label: Text(
                "تسجيل الدخول",
                style: TextStyles.bodyLarge.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
