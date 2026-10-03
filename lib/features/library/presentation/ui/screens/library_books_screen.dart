import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/features/hadith_daily/data/repos/save_hadith_daily_repo.dart';
import 'package:mishkat_almasabih/features/home/logic/cubit/get_library_statistics_cubit.dart';
import 'package:mishkat_almasabih/features/home/ui/widgets/build_book_data_state_card.dart';
import 'package:mishkat_almasabih/features/home/ui/widgets/build_header_app_bar.dart';
import 'package:mishkat_almasabih/features/home/ui/widgets/build_main_category_card.dart';
import 'package:mishkat_almasabih/features/home/ui/widgets/home_screen_shimmer.dart';
import 'package:mishkat_almasabih/features/library/ui/screens/library_screen.dart';

import '../../../core/theming/library_decorations.dart';
import '../../../core/theming/library_styles.dart';
import '../../../core/helpers/spacing.dart';

class LibraryBooksScreen extends StatefulWidget {
  const LibraryBooksScreen({super.key});

  @override
  State<LibraryBooksScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<LibraryBooksScreen> {
  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    await context.read<GetLibraryStatisticsCubit>().emitGetStatisticsCubit();
  }

  @override
  Widget build(BuildContext context) {
    SaveHadithDailyRepo().getHadith();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: LibraryDecorations.scaffoldBackground,
          body: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<GetLibraryStatisticsCubit, GetLibraryStatisticsState>(
      builder: (context, state) {
        if (state is GetLivraryStatisticsLoading) {
          return _buildLoadingState();
        } else if (state is GetLivraryStatisticsSuccess) {
          return _buildSuccessState(state);
        }
        return _buildEmptyState();
      },
    );
  }

  Widget _buildLoadingState() {
    return const Directionality(
      textDirection: TextDirection.rtl,
      child: HomeScreenShimmer(),
    );
  }

  Widget _buildSuccessState(GetLivraryStatisticsSuccess state) {
    return CustomScrollView(
      slivers: [
        _buildHeaderSection(),
        SliverToBoxAdapter(child: SizedBox(height: 8.h)),
        _buildStatisticsSection(state),
        _buildDividerSection(),
        _buildCategoriesSection(state),
        SliverToBoxAdapter(child: SizedBox(height: 32.h)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const SizedBox.shrink();
  }

  Widget _buildHeaderSection() {
    return BuildHeaderAppBar(
      home: false,
      bottomNav: true,

      //     title: 'مشكاة المصابيح',
      title: 'مشكاة الأحاديث',
      description: 'مصادر الأحاديث النبوية الشريفة',
    );
  }

  Widget _buildStatisticsSection(GetLivraryStatisticsSuccess state) {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          children: [
            _buildStatisticsHeader(),
            SizedBox(height: 16.h),
            _buildStatisticsCards(state),
          ],
        ),
      ),
    );
  }

  Widget _buildDividerSection() {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 30.w, vertical: 12.h),
        child: _buildIslamicSeparator(),
      ),
    );
  }

  Widget _buildCategoriesSection(GetLivraryStatisticsSuccess state) {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategoriesHeader(),
            SizedBox(height: 24.h),
            _buildCategoryCards(state),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: LibraryDecorations.sectionHeaderContainer(),
      child: Row(
        children: [
          _buildStatisticsHeaderIcon(),
          SizedBox(width: 16.w),
          _buildStatisticsHeaderText(),
        ],
      ),
    );
  }

  Widget _buildStatisticsHeaderIcon() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: LibraryDecorations.sectionHeaderIconContainer(
        LibraryDecorations.booksColor.withOpacity(0.1),
      ),
      child: Icon(
        Icons.analytics,
        color: LibraryDecorations.booksColor,
        size: 24.sp,
      ),
    );
  }

  Widget _buildStatisticsHeaderText() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('إحصائيات المكتبة', style: LibraryTextStyles.headerTitleStyle),
          SizedBox(height: 4.h),
          Text(
            'نظرة عامة على محتويات المكتبة الإسلامية',
            style: LibraryTextStyles.headerDescriptionStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards(GetLivraryStatisticsSuccess state) {
    return Row(
      children: [
        _buildStatisticsCard(
          icon: Icons.book,
          title: 'إجمالي الكتب',
          value: state.statisticsResponse.statistics.totalBooks.toString(),
          color: LibraryDecorations.booksColor,
        ),
        SizedBox(width: Spacing.md),
        _buildStatisticsCard(
          icon: Icons.folder,
          title: 'الأبواب',
          value: state.statisticsResponse.statistics.totalChapters.toString(),
          color: LibraryDecorations.chaptersColor,
        ),
        SizedBox(width: Spacing.md),
        _buildStatisticsCard(
          icon: Icons.auto_stories,
          title: 'الأحاديث',
          value: state.statisticsResponse.statistics.totalHadiths.toString(),
          color: LibraryDecorations.hadithsColor,
        ),
      ],
    );
  }

  Widget _buildStatisticsCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: BuildBookDataStateCard(
        icon: icon,
        title: title,
        value: value,
        color: color,
      ),
    );
  }

  Widget _buildCategoriesHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: LibraryDecorations.sectionHeaderContainer(),
      child: Row(
        children: [
          _buildCategoriesHeaderIcon(),
          SizedBox(width: 16.w),
          _buildCategoriesHeaderText(),
        ],
      ),
    );
  }

  Widget _buildCategoriesHeaderIcon() {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: LibraryDecorations.sectionHeaderIconContainer(
        LibraryDecorations.hadithsColor.withOpacity(0.1),
      ),
      child: Icon(
        Icons.library_books,
        color: LibraryDecorations.hadithsColor,
        size: 24.sp,
      ),
    );
  }

  Widget _buildCategoriesHeaderText() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('الكتب الرئيسية', style: LibraryTextStyles.headerTitleStyle),
          SizedBox(height: 4.h),
          Text(
            'مصادر الأحاديث النبوية الشريفة',
            style: LibraryTextStyles.headerDescriptionStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCards(GetLivraryStatisticsSuccess state) {
    return Column(
      children: [
        _buildCategoryCard(
          state: state,
          categoryKey: 'kutub_tisaa',
          subtitle: '11 كتاب',
          description: 'المجاميع الكبيرة للأحاديث الصحيحة',
          icon: Icons.library_books,
          gradient: _buildKutubTisaaGradient(),
          screenName: "كتب الأحاديث الكبيرة",
          screenId: 'kutub_tisaa',
        ),
        SizedBox(height: 20.h),
        _buildCategoryCard(
          state: state,
          categoryKey: 'arbaain',
          subtitle: '3 كتب',
          description: 'مجموعات الأربعين حديثاً',
          icon: Icons.format_list_numbered,
          gradient: _buildArbaainGradient(),
          screenName: 'كتب الأربعينات',
          screenId: 'arbaain',
        ),
        SizedBox(height: 20.h),
        _buildCategoryCard(
          state: state,
          categoryKey: 'adab',
          subtitle: '3 كتب',
          description: 'كتب الآداب والأخلاق الإسلامية',
          icon: Icons.psychology,
          gradient: _buildAdabGradient(),
          screenName: 'كتب الأدب و الآداب',
          screenId: 'adab',
        ),
      ],
    );
  }

  Widget _buildCategoryCard({
    required GetLivraryStatisticsSuccess state,
    required String categoryKey,
    required String subtitle,
    required String description,
    required IconData icon,
    required Gradient gradient,
    required String screenName,
    required String screenId,
  }) {
    final category =
        state.statisticsResponse.statistics.booksByCategory[categoryKey]!;

    return BuildMainCategoryCard(
      title: category.name,
      subtitle: subtitle,
      description: description,
      icon: icon,
      bookCount: category.count,
      gradient: gradient,
      onTap: () => _navigateToLibrary(screenName, screenId),
    );
  }

  LinearGradient _buildKutubTisaaGradient() {
    return LibraryDecorations.kutubTisaaGradient();
  }

  LinearGradient _buildArbaainGradient() {
    return LibraryDecorations.arbaainGradient();
  }

  LinearGradient _buildAdabGradient() {
    return LibraryDecorations.adabGradient();
  }

  Widget _buildIslamicSeparator() {
    return Container(
      height: 2.h,
      decoration: LibraryDecorations.islamicSeparator(),
    );
  }

  void _navigateToLibrary(String screenName, String screenId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LibraryScreen(name: screenName, id: screenId),
      ),
    );
  }
}
