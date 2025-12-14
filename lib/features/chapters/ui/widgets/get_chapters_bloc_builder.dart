// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/spacing.dart';
import 'package:mishkat_almasabih/core/widgets/error_dialg.dart';
import 'package:mishkat_almasabih/features/chapters/ui/widgets/build_statistics_container.dart';
import 'package:mishkat_almasabih/features/chapters/ui/widgets/chapters_grid_view.dart';
import 'package:mishkat_almasabih/features/home/ui/widgets/search_bar_widget.dart';
import '../../../../core/theming/colors.dart';
import '../../../home/ui/widgets/build_header_app_bar.dart';
import '../../logic/cubit/chapters_cubit.dart';

class GetBookChaptersBlocBuilder extends StatelessWidget {
  const GetBookChaptersBlocBuilder({
    super.key,
    required this.bookSlug,
    required this.bookData,
  });

  final String bookSlug;
  final Map<String, dynamic> bookData;

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();

    return BlocBuilder<ChaptersCubit, ChaptersState>(
      builder: (context, state) {
        if (state is ChaptersLoading) {
          return CustomScrollView(
            slivers: [
              BuildHeaderAppBar(
                title: bookData['bookName'],
                description: bookData['writerName'],
              ),
              SliverToBoxAdapter(child: SizedBox(height: 12.h)),
              _buildStatsCards(),
              _buildSearchBar(context, controller),
              SliverToBoxAdapter(child: SizedBox(height: 12.h)),

        
              ResponsiveChapterList(
                isLoading: true,
                items: [],
                primaryPurple: ColorsManager.primaryGreen,
                bookName: '',
                writerName: '',
                bookSlug: '',
              ),
            ],
          );
        }

        if (state is ChaptersFailure) {
          return Center(
            child: ErrorState(
            
              error: state.errorMessage??'حدث خطأ. حاول مرة أخري'),
          );

        
        }

        if (state is ChaptersSuccess) {
          return RefreshIndicator(
            color: ColorsManager.primaryGreen,
            onRefresh: () async {
              context.read<ChaptersCubit>().emitGetBookChapters(
         
                bookSlug:  bookSlug);
            },
            child: CustomScrollView(
              slivers: [
                BuildHeaderAppBar(
                  title: bookData['bookName'],
                  description: bookData['writerName'],
                ),
                SliverToBoxAdapter(child: SizedBox(height: 12.h)),
                _buildStatsCards(),
                SliverToBoxAdapter(
                  child: Divider(
                    color: ColorsManager.primaryNavy,
                    endIndent: 30.h,
                    indent: 30.h,
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 12.h)),
                _buildSearchBar(context, controller),

                SliverToBoxAdapter(child: SizedBox(height: 22.h)),
                state.filteredChapters.isEmpty
                    ? SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Card(
                          color: Colors.white,
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 60,
                                  color: ColorsManager.primaryNavy,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'لا توجد نتائج',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: ColorsManager.primaryNavy,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'حاول بكلمة أبسط أو مختلفة',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                    : ResponsiveChapterList(
                      items: state.filteredChapters,
                      primaryPurple: ColorsManager.primaryGreen,
                      bookName: bookData['bookName'],
                      writerName: bookData['writerName'],
                      bookSlug: bookSlug,
                    ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  SliverToBoxAdapter _buildStatsCards() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(Spacing.screenHorizontal),
        child: Row(
          children: [
            Expanded(
              child: BuildStatisticsContainer(
                icon: Icons.folder,
                title: 'الأبواب',
                value: '${bookData['noOfChapters']}',
                color: ColorsManager.primaryGreen.withOpacity(0.7),
              ),
            ),

            SizedBox(width: Spacing.md),
            Expanded(
              child: BuildStatisticsContainer(
                icon: Icons.auto_stories,
                title: 'الأحاديث',
                value: '${bookData['noOfHadith']}',
                color: ColorsManager.primaryGreen.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildSearchBar(
    BuildContext context,
    TextEditingController controller,
  ) {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 12.w),
        padding: EdgeInsets.all(0.w),
        decoration: BoxDecoration(
       
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Card(
          elevation: 0,
                  margin: EdgeInsets.zero,

          color: ColorsManager.secondaryBackground,
          child: SearchBarWidget(
            hintText: 'ابحث في الكتب...',
            controller: controller,
            onSearch: (query) {
              context.read<ChaptersCubit>().filterChapters(query);
            },
          ),
        ),
      ),
    );
  }
}
