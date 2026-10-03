import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/di/dependency_injection.dart';
import 'package:mishkat_almasabih/core/widgets/double_tap_to_exot.dart';
import 'package:mishkat_almasabih/core/widgets/miskat_drawer.dart';

import 'package:mishkat_almasabih/features/hadith_daily/presentation/logic/daily_hadith_cubit.dart';
import 'package:mishkat_almasabih/features/library/presentation/logic/library_statistics/get_library_statistics_cubit.dart';
import 'package:mishkat_almasabih/features/home/presentation/ui/widgets/build_header_app_bar.dart';
import 'package:mishkat_almasabih/features/home/presentation/ui/widgets/daily_hadith_card.dart';
import 'package:mishkat_almasabih/features/library/presentation/ui/screens/library_books_screen.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/widgets/common/quran_entry_card.dart';

import 'package:mishkat_almasabih/features/random_ahadith/presentation/ui/widgets/random_ahadith_bloc_builder.dart';
import 'package:mishkat_almasabih/features/search/search_history/presentation/logic/search_history_cubit.dart';
import 'package:mishkat_almasabih/features/theme/presentation/ui/widgets/theme_toggle_button.dart';
import 'package:mishkat_almasabih/features/home/presentation/ui/widgets/section_divider.dart';
import 'package:mishkat_almasabih/features/home/presentation/ui/widgets/top_books_section.dart';
import 'package:mishkat_almasabih/features/home/presentation/ui/widgets/home_search_bar_section.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
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
            top: true,
            bottom: true,
            child: Scaffold(
              drawer: const MishkatDrawer(),
              backgroundColor: ColorsManager.secondaryBackground,
              floatingActionButton: FloatingActionButton.extended(
                backgroundColor: ColorsManager.primaryGreen,
                foregroundColor: ColorsManager.white,
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
          actions: [ThemeToggleButton()],
        ),
        SliverToBoxAdapter(child: SizedBox(height: 12.h)),

        const HomeSearchBarSection(),
        const SliverToBoxAdapter(child: QuranEntryCard()),
        SliverToBoxAdapter(child: const HadithOfTheDayCard()),
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
}

class _RamadanGreetingBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF6B4FA3).withOpacity(0.1),
            Color(0xFF2D9B9B).withOpacity(0.1),
          ],
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Color(0xFF6B4FA3).withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6B4FA3), Color(0xFF2D9B9B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF6B4FA3).withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.nightlight_round,
              color: Colors.white,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'رمضان مبارك',
                  style: TextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6B4FA3),
                    fontSize: 15.sp,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'بارك الله لك في الشهر الفضيل',
                  style: TextStyles.bodySmall.copyWith(
                    color: ColorsManager.secondaryText,
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.star,
            color: Color(0xFFFFD700).withOpacity(0.7),
            size: 16.sp,
          ),
        ],
      ),
    );
  }
}

class _DecorativeMoon extends StatelessWidget {
  final double size;
  const _DecorativeMoon({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Color(0xFFFFD700).withOpacity(0.15),
            Color(0xFFFFD700).withOpacity(0.05),
            Colors.transparent,
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.nightlight_round,
          color: Colors.white.withOpacity(0.2),
          size: size * 0.5,
        ),
      ),
    );
  }
}

class _DecorativeStar extends StatelessWidget {
  final double size;
  const _DecorativeStar({required this.size});

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.star,
      color: Color(0xFFFFD700).withOpacity(0.4),
      size: size,
    );
  }
}
