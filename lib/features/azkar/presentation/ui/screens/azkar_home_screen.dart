import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/arabic_plurals.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/widgets/screen_title_header.dart';
import 'package:mishkat_almasabih/core/widgets/state_message.dart';
import 'package:mishkat_almasabih/features/azkar/presentation/logic/azkar_home/azkar_home_cubit.dart';
import 'package:mishkat_almasabih/features/azkar/presentation/ui/helpers/azkar_ui_helpers.dart';
import 'package:mishkat_almasabih/features/azkar/presentation/ui/widgets/home/azkar_home_sections.dart';
import 'package:mishkat_almasabih/features/azkar/presentation/ui/widgets/home/azkar_search_field.dart';
import 'package:mishkat_almasabih/features/azkar/presentation/ui/widgets/home/azkar_search_results_view.dart';

/// The azkar's front door: the chapter for the hour, the daily ones, the
/// favourites, every chapter of Hisn Al-Muslim by theme, and search.
class AzkarHomeScreen extends StatefulWidget {
  const AzkarHomeScreen({super.key});

  @override
  State<AzkarHomeScreen> createState() => _AzkarHomeScreenState();
}

class _AzkarHomeScreenState extends State<AzkarHomeScreen> {
  /// Back from the background: the hour's suggestion and today's counts may
  /// have moved on.
  late final AppLifecycleListener _lifecycle = AppLifecycleListener(
    onResume: () {
      if (mounted) context.read<AzkarHomeCubit>().refresh();
    },
  );

  @override
  void initState() {
    super.initState();
    _lifecycle;
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: ColorsManager.secondaryBackground,
        body: SafeArea(
          bottom: false,
          child: CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              const SliverToBoxAdapter(child: _Header()),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
                sliver: const SliverToBoxAdapter(child: AzkarSearchField()),
              ),
              BlocBuilder<AzkarHomeCubit, AzkarHomeState>(
                buildWhen:
                    (previous, current) =>
                        previous.runtimeType != current.runtimeType ||
                        (previous is AzkarHomeLoaded &&
                            current is AzkarHomeLoaded &&
                            previous.isSearching != current.isSearching),
                builder:
                    (context, state) => switch (state) {
                      AzkarHomeLoading() => const AzkarHomeShimmer(),
                      AzkarHomeFailure(:final message) => SliverToBoxAdapter(
                        child: StateMessage.error(
                          message: message,
                          onRetry: context.read<AzkarHomeCubit>().load,
                        ),
                      ),
                      AzkarHomeLoaded(isSearching: true) => SliverPadding(
                        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
                        sliver: const AzkarSearchResultsView(),
                      ),
                      AzkarHomeLoaded() => const AzkarHomeSections(),
                    },
              ),
              SliverSafeArea(
                top: false,
                sliver: SliverToBoxAdapter(child: SizedBox(height: 28.h)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<AzkarHomeCubit, AzkarHomeState, int?>(
      selector:
          (state) => state is AzkarHomeLoaded ? state.categories.length : null,
      builder:
          (context, chapters) => ScreenTitleHeader(
            title: 'الأذكار',
            subtitle:
                chapters == null
                    ? kHisnAlMuslim
                    : '$kHisnAlMuslim · ${arabicCount(chapters, ArabicNoun.chapter)}',
          ),
    );
  }
}
