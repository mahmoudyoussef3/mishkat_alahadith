import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/features/hadith_daily/presentation/logic/daily_hadith_cubit.dart';
import 'package:mishkat_almasabih/features/home/presentation/ui/widgets/daily_hadith_card.dart';
import 'package:mishkat_almasabih/features/home/presentation/ui/widgets/home_header.dart';
import 'package:mishkat_almasabih/features/home/presentation/ui/widgets/home_prayer_strip.dart';
import 'package:mishkat_almasabih/features/home/presentation/ui/widgets/home_search_bar_section.dart';
import 'package:mishkat_almasabih/features/home/presentation/ui/widgets/home_shortcuts.dart';
import 'package:mishkat_almasabih/features/home/presentation/ui/widgets/top_books_section.dart';
import 'package:mishkat_almasabih/features/library/presentation/logic/library_statistics/get_library_statistics_cubit.dart';
import 'package:mishkat_almasabih/features/random_ahadith/presentation/logic/random_ahadith_cubit.dart';
import 'package:mishkat_almasabih/features/random_ahadith/presentation/ui/widgets/random_ahadith_bloc_builder.dart';

/// Home tab. Lives inside the app shell, which supplies the Scaffold (and
/// its drawer) and the cubits this screen reads.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _refresh(BuildContext context) => Future.wait([
    context.read<DailyHadithCubit>().load(),
    context.read<RandomAhadithCubit>().emitRandomStats(),
    context.read<GetLibraryStatisticsCubit>().emitGetStatisticsCubit(),
  ]);

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: ColorsManager.secondaryBackground,
      child: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () => _refresh(context),
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 0),
                sliver: SliverList.list(
                  children: [
                    const HomeHeader(),
                    SizedBox(height: 16.h),
                    const HomeSearchBarSection(),
                    SizedBox(height: 16.h),
                    const HomePrayerStrip(),
                    SizedBox(height: 16.h),
                    const HomeShortcuts(),
                    SizedBox(height: 16.h),
                    const HadithOfTheDayCard(),
                  ],
                ),
              ),
              const TopBooksSection(),
              const RandomAhadithBlocBuilder(),
              SliverToBoxAdapter(child: SizedBox(height: 24.h)),
            ],
          ),
        ),
      ),
    );
  }
}
