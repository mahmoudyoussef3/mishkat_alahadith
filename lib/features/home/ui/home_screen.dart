import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/di/dependency_injection.dart';
import 'package:mishkat_almasabih/core/helpers/extensions.dart';
import 'package:mishkat_almasabih/core/networking/api_constants.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';
import 'package:mishkat_almasabih/core/widgets/double_tap_to_exot.dart';
import 'package:mishkat_almasabih/core/widgets/miskat_drawer.dart';
import 'package:mishkat_almasabih/features/book_data/data/models/book_data_model.dart';
import 'package:mishkat_almasabih/features/hadith_daily/data/repos/save_hadith_daily_repo.dart';
import 'package:mishkat_almasabih/features/hadith_daily/logic/cubit/daily_hadith_cubit.dart';
import 'package:mishkat_almasabih/features/home/data/models/search_history_models.dart';
import 'package:mishkat_almasabih/features/home/logic/cubit/get_library_statistics_cubit.dart';
import 'package:mishkat_almasabih/features/home/ui/widgets/build_header_app_bar.dart';
import 'package:mishkat_almasabih/features/home/ui/widgets/daily_hadith_card.dart';
import 'package:mishkat_almasabih/features/home/ui/widgets/search_bar_widget.dart';
import 'package:mishkat_almasabih/features/library_books_screen.dart';
import 'package:mishkat_almasabih/features/library/ui/widgets/book_card.dart';
import 'package:mishkat_almasabih/features/library/ui/widgets/book_card_shimmer.dart';
import 'package:mishkat_almasabih/features/random_ahadith/ui/widgets/random_ahadith_bloc_builder.dart';
import 'package:mishkat_almasabih/features/search/search_screen/logic/cubit/search_history_cubit.dart';
import '../../../core/theming/colors.dart';
import '../../../core/theming/styles.dart';

class HomeScreenWrapper extends StatelessWidget {
  const HomeScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<SearchHistoryCubit>()),
        BlocProvider(create: (_) => getIt<GetLibraryStatisticsCubit>()),
      ],
      child: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey _searchKey = GlobalKey();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DoubleTapToExitApp(
      myScaffoldScreen: Directionality(
        textDirection: TextDirection.rtl,
        child: RefreshIndicator(
          onRefresh: () => SaveHadithDailyRepo().getHadith(),
          child: SafeArea(
              top: false,
        bottom: true,
            child: Scaffold(
              drawer: const MishkatDrawer(),
              backgroundColor: ColorsManager.secondaryBackground,
              floatingActionButton: FloatingActionButton.extended(
                backgroundColor: ColorsManager.primaryGreen,
                foregroundColor: ColorsManager.secondaryBackground,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => BlocProvider(
                            create: (_) => getIt<GetLibraryStatisticsCubit>(),
                            child: const LibraryBooksScreen(),
                          ),
                    ),
                  );
                },
                label: Row(
                  children: [
                    Icon(Icons.local_library_sharp),
                    SizedBox(width: 4.w),
                    Text('المكتبة', style: TextStyle(fontSize: 16.sp)),
                  ],
                ),
              ),
              body: _buildBody(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return CustomScrollView(
      slivers: [
        const BuildHeaderAppBar(
          home: true,
          bottomNav: true,
          title: 'مشكاة الأحاديث',
          description: 'نُحْيِي السُّنَّةَ... فَتُحْيِينَا',
        ),
        SliverToBoxAdapter(child: SizedBox(height: 12.h)),
        _buildSearchBarSection(),
        SliverToBoxAdapter(
          child: HadithOfTheDayCard(repo: SaveHadithDailyRepo()),
        ),

        _buildDividerSection(),
        _buildBooksSection(),
        _buildDividerSection(),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 12.h),
                Text(
                  'أحاديث عامة',
                  style: TextStyles.headlineMedium.copyWith(
                    color: ColorsManager.primaryText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const RandomAhadithBlocBuilder(),
      ],
    );
  }

  Widget _buildDividerSection() => SliverToBoxAdapter(
    child: Container(
      margin: EdgeInsets.symmetric(horizontal: 30.w, vertical: 12.h),
      height: 2.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorsManager.primaryPurple.withOpacity(0.3),
            ColorsManager.primaryGold.withOpacity(0.6),
            ColorsManager.primaryPurple.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(1.r),
      ),
    ),
  );

  Widget _buildBooksSection() {
    return SliverToBoxAdapter(
      child: BlocBuilder<GetLibraryStatisticsCubit, GetLibraryStatisticsState>(
        builder: (context, state) {
          if (state is GetLivraryStatisticsLoading) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
              child: SizedBox(
                height: 240.h, // ارتفاع مناسب للكاردات
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  separatorBuilder: (context, index) => SizedBox(width: 12.w),
                  itemBuilder: (context, index) {
                    return SizedBox(
                      width: 140.w,
                      child: const BookCardShimmer(),
                    );
                  },
                ),
              ),
            );
          } else if (state is GetLivraryStatisticsSuccess) {
            var books = state.statisticsResponse.statistics.topBooks;
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الكتب الأكثر رواجا',

                    style: TextStyles.headlineMedium.copyWith(
                      color: ColorsManager.primaryText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  SizedBox(
                    height: 240.h, // ارتفاع مناسب للكاردات
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: books.length,
                      separatorBuilder:
                          (context, index) => SizedBox(width: 8.w),
                      itemBuilder: (context, index) {
                        final book = books[index];

                        return SizedBox(
                          width: 170.w,
                          child: BookCard(
                            book: Book(
                              bookName: book.name,
                              bookSlug:
                                  booksMap[bookNamesArabic[book.name]] ?? '',
                              writerName: book.name,
                              chapters_count: book.chapters,
                              hadiths_count: book.hadiths,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }
          return SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSearchBarSection() {
    return SliverToBoxAdapter(
      child: Container(
        key: _searchKey,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: SearchBarWidget(
          controller: _controller,

          onSearch: (query) {
            final now = DateTime.now();

            final trimmedQuery = query.trim();
            if (trimmedQuery.isEmpty) return;

            context
                .read<SearchHistoryCubit>()
                .addSearchItem(
                  AddSearchRequest(
                    title: trimmedQuery,
                    date:
                        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}",
                    time:
                        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}",
                  ),
                )
                .then(
                  (value) => context.pushNamed(
                    Routes.publicSearchSCreen,
                    arguments: trimmedQuery,
                  ),
                );
          },
        ),
      ),
    );
  }
}
