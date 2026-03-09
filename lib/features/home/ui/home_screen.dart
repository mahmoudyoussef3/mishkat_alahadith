import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/di/dependency_injection.dart';
import 'package:mishkat_almasabih/core/widgets/double_tap_to_exot.dart';
import 'package:mishkat_almasabih/core/widgets/miskat_drawer.dart';

import 'package:mishkat_almasabih/features/hadith_daily/logic/cubit/daily_hadith_cubit.dart';
import 'package:mishkat_almasabih/features/home/logic/cubit/get_library_statistics_cubit.dart';
import 'package:mishkat_almasabih/features/home/ui/widgets/build_header_app_bar.dart';
import 'package:mishkat_almasabih/features/home/ui/widgets/daily_hadith_card.dart';
import 'package:mishkat_almasabih/features/library_books_screen.dart';

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
        // Ramadan Greeting Banner
      
        SliverToBoxAdapter(child: SizedBox(height: 8.h)),
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

// ══════════════════════════════════════════════════════════════
// Ramadan Greeting Banner - Welcoming message with Islamic decor
// ══════════════════════════════════════════════════════════════

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
          // Decorative moon icon
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
          // Small star decoration
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

// ══════════════════════════════════════════════════════════════
// Ramadan Tasks Card - Main entry with Ramadan theme
// ══════════════════════════════════════════════════════════════

class _RamadanTasksEntry extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, Routes.ramadanTasksScreen),
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.all(isTablet ? 18.w : 16.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            gradient: LinearGradient(
              colors: [
                Color(0xFF1A1A3E), // Deep night blue
                Color(0xFF2D1B4E), // Deep purple
                Color(0xFF1A3E3E), // Deep teal
              ],
              begin: AlignmentDirectional.topStart,
              end: AlignmentDirectional.bottomEnd,
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF6B4FA3).withOpacity(0.25),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Decorative background elements
              Positioned(
                top: -20,
                right: -20,
                child: _DecorativeMoon(size: 80),
              ),
              Positioned(
                bottom: -10,
                left: 10,
                child: _DecorativeStar(size: 24),
              ),
              Positioned(top: 20, left: 30, child: _DecorativeStar(size: 16)),
              Positioned(
                bottom: 30,
                right: 60,
                child: _DecorativeStar(size: 12),
              ),

              // Main content
              Row(
                children: [
                  // Lantern icon with glow
                  Container(
                    width: isTablet ? 60.w : 52.w,
                    height: isTablet ? 60.w : 52.w,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFFFFD700).withOpacity(0.3),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.mosque_outlined,
                      color: Color(0xFFFFD700),
                      size: isTablet ? 32.sp : 28.sp,
                    ),
                  ),
                  SizedBox(width: 14.w),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'مهام رمضان',
                              style: TextStyles.titleLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: isTablet ? 20.sp : 18.sp,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.3),
                                    offset: Offset(0, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Icon(
                              Icons.star,
                              color: Color(0xFFFFD700),
                              size: 14.sp,
                            ),
                          ],
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          'أضف مهامك وتابع تقدّمك اليومي والشهري',
                          style: TextStyles.bodySmall.copyWith(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: isTablet ? 13.sp : 12.sp,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: 8.w),

                  // Arrow with glow
                  Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      color: ColorsManager.secondaryBackground,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: ColorsManager.hadithWeak.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color:  Color(0xFFFFD700),
                      size: 20.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Decorative Elements
// ══════════════════════════════════════════════════════════════

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
