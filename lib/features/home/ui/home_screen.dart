import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/di/dependency_injection.dart';
// import 'package:mishkat_almasabih/core/helpers/extensions.dart';
import 'package:mishkat_almasabih/core/widgets/double_tap_to_exot.dart';
import 'package:mishkat_almasabih/core/widgets/miskat_drawer.dart';
// import 'package:mishkat_almasabih/features/book_data/data/models/book_data_model.dart';
// import 'package:mishkat_almasabih/features/hadith_daily/data/repos/save_hadith_daily_repo.dart';
import 'package:mishkat_almasabih/features/hadith_daily/logic/cubit/daily_hadith_cubit.dart';
import 'package:mishkat_almasabih/features/home/logic/cubit/get_library_statistics_cubit.dart';
import 'package:mishkat_almasabih/features/home/ui/widgets/build_header_app_bar.dart';
import 'package:mishkat_almasabih/features/home/ui/widgets/daily_hadith_card.dart';
// import 'package:mishkat_almasabih/features/home/ui/widgets/search_bar_widget.dart';
import 'package:mishkat_almasabih/features/library_books_screen.dart';
// import 'package:mishkat_almasabih/features/library/ui/widgets/book_card.dart';
// import 'package:mishkat_almasabih/features/library/ui/widgets/book_card_shimmer.dart';
import 'package:mishkat_almasabih/features/random_ahadith/ui/widgets/random_ahadith_bloc_builder.dart';
import 'package:mishkat_almasabih/features/search/search_screen/logic/cubit/search_history_cubit.dart';
import 'package:mishkat_almasabih/features/home/ui/widgets/section_divider.dart';
import 'package:mishkat_almasabih/features/home/ui/widgets/top_books_section.dart';
import 'package:mishkat_almasabih/features/home/ui/widgets/home_search_bar_section.dart';
import '../../../core/theming/colors.dart';
import '../../../core/theming/styles.dart';
import 'package:mishkat_almasabih/core/theming/home_styles.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';

class HomeScreenWrapper extends StatelessWidget {
  const HomeScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<SearchHistoryCubit>()),
        BlocProvider(create: (_) => getIt<GetLibraryStatisticsCubit>()),
        BlocProvider(create: (_) => getIt<DailyHadithCubit>()..load()),
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
  // Moved search bar to its own widget; no longer need this key here.
  // final GlobalKey _searchKey = GlobalKey();

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
          onRefresh: () => context.read<DailyHadithCubit>().load(),
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
                    Text('المكتبة', style: HomeTextStyles.fabLibraryLabel),
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
        const HomeSearchBarSection(),
        SliverToBoxAdapter(child: const HadithOfTheDayCard()),
        const SectionDivider(),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: _RamadanTasksEntry(),
          ),
        ),
        const SectionDivider(),
        const TopBooksSection(),
        const SectionDivider(),
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

  // Section widgets extracted into separate files for better structure and fewer rebuilds.
}

class _RamadanTasksEntry extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, Routes.ramadanTasksScreen),
        child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: ColorsManager.cardBackground,
            borderRadius: BorderRadius.circular(12.w),
            boxShadow: [
              BoxShadow(
                color: ColorsManager.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: ColorsManager.primaryPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.w),
                ),
                child: Icon(
                  Icons.nightlight_round,
                  color: ColorsManager.primaryPurple,
                  size: 28.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مهام رمضان',
                      style: TextStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'أضف مهامك وتابع تقدّمك اليومي والشهري',
                      style: TextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_left, color: ColorsManager.secondaryText),
            ],
          ),
        ),
      ),
    );
  }
}
