import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mishkat_almasabih/core/helpers/spacing.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/core/theming/bookmark_styles.dart';
import 'package:mishkat_almasabih/core/theming/bookmark_decorations.dart';
import 'package:mishkat_almasabih/features/bookmark/ui/widgets/book_collections_row.dart';
import 'package:mishkat_almasabih/features/bookmark/ui/widgets/bookmark_list.dart';
import 'package:mishkat_almasabih/features/home/ui/widgets/build_header_app_bar.dart';

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
  bool _isLoggedIn = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    setState(() {
      _isLoggedIn = token != null;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        top: false,
        bottom: true,
        child: Scaffold(
          backgroundColor: ColorsManager.secondaryBackground,
          body:
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _isLoggedIn
                  ? _buildBookmarkContent()
                  : _buildLoginPrompt(context),
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
    return Card(
      color: ColorsManager.secondaryBackground,
      margin: EdgeInsets.zero,
      elevation: 0,
      child: Container(
        decoration: BookmarkDecorations.searchCard(),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _query = value),
          decoration: InputDecoration(
            hintText: 'ابحث بنص الحديث أو الملاحظات...',
            hintStyle: BookmarkTextStyles.searchHint,
            prefixIcon: Icon(
              Icons.search,
              color: ColorsManager.primaryPurple,
              size: 24,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: Spacing.md,
              vertical: Spacing.md,
            ),
          ),
          style: TextStyles.bodyMedium,
          textInputAction: TextInputAction.search,
        ),
      ),
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
