import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/core/di/dependency_injection.dart';
import 'package:mishkat_almasabih/core/helpers/functions.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/widgets/miskat_drawer.dart';
import 'package:mishkat_almasabih/core/widgets/screen_title_header.dart';
import 'package:mishkat_almasabih/features/authentication/session/presentation/logic/session_cubit.dart';
import 'package:mishkat_almasabih/features/bookmark/presentation/logic/add_bookmark/add_cubit_cubit.dart';
import 'package:mishkat_almasabih/features/bookmark/presentation/logic/collections/get_collections_bookmark_cubit.dart';
import 'package:mishkat_almasabih/features/bookmark/presentation/logic/delete_bookmark/delete_cubit_cubit.dart';
import 'package:mishkat_almasabih/features/bookmark/presentation/logic/get_bookmarks/user_bookmarks_cubit.dart';
import 'package:mishkat_almasabih/features/bookmark/presentation/ui/screens/bookmark_screen.dart';
import 'package:mishkat_almasabih/features/hadith_daily/presentation/logic/daily_hadith_cubit.dart';
import 'package:mishkat_almasabih/features/home/presentation/ui/home_screen.dart';
import 'package:mishkat_almasabih/features/library/presentation/logic/library_books/library_books_cubit.dart';
import 'package:mishkat_almasabih/features/library/presentation/ui/screens/library_books_screen.dart';
import 'package:mishkat_almasabih/features/main_navigation/presentation/logic/main_navigation_cubit.dart';
import 'package:mishkat_almasabih/features/main_navigation/presentation/ui/widgets/main_navigation_bar.dart';
import 'package:mishkat_almasabih/features/prayer_times/presentation/logic/prayer_times_cubit.dart';
import 'package:mishkat_almasabih/features/profile/presentation/logic/profile/profile_cubit.dart';
import 'package:mishkat_almasabih/features/profile/presentation/logic/user_stats/user_stats_cubit.dart';
import 'package:mishkat_almasabih/features/profile/presentation/ui/profile_screen.dart';
import 'package:mishkat_almasabih/features/random_ahadith/presentation/logic/random_ahadith_cubit.dart';
import 'package:mishkat_almasabih/features/search_with_filters/presentation/ui/screens/search_with_filters_screen.dart';

/// App shell: the top-level tabs behind a bottom navigation bar.
///
/// Expects [MainNavigationCubit] and the cubits shared between tabs
/// (library statistics, search history) from the route. A tab is built the
/// first time it is opened and then kept alive, so switching back restores
/// its scroll position and state.
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key, this.onTabChanged});

  /// Called after the user switches tabs, e.g. to log a screen view.
  final ValueChanged<MainTab>? onTabChanged;

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  static const _exitWindow = Duration(seconds: 2);

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  /// Tabs built so far. Each is built once and the same widget is reused,
  /// so switching tabs never rebuilds a tab's subtree.
  final Map<MainTab, Widget> _tabs = {};
  DateTime? _lastBackPress;

  Widget _tab(MainTab tab) => _tabs.putIfAbsent(
    tab,
    () => KeyedSubtree(
      key: ValueKey(tab),
      child: EmbeddedScreenScope(child: _buildTab(tab)),
    ),
  );

  void _onTabChanged(BuildContext context, MainTab tab) {
    // A field focused in the tab being left must not keep the keyboard.
    FocusManager.instance.primaryFocus?.unfocus();

    // Bookmarks change on other screens; refresh when coming back.
    if (tab == MainTab.saved &&
        _tabs.containsKey(tab) &&
        context.read<SessionCubit>().isSignedIn) {
      context.read<GetBookmarksCubit>().getUserBookmarks();
      context.read<GetCollectionsBookmarkCubit>().getBookMarkCollections();
    }
    widget.onTabChanged?.call(tab);
  }

  /// Back closes the drawer, then returns to Home, then exits on a second
  /// press within [_exitWindow].
  void _onBack(BuildContext context) {
    final scaffold = _scaffoldKey.currentState;
    if (scaffold != null && scaffold.isDrawerOpen) {
      scaffold.closeDrawer();
      return;
    }

    final navigation = context.read<MainNavigationCubit>();
    if (navigation.state != MainTab.home) {
      navigation.select(MainTab.home);
      return;
    }

    final now = DateTime.now();
    final last = _lastBackPress;
    if (last != null && now.difference(last) < _exitWindow) {
      SystemNavigator.pop();
      return;
    }
    _lastBackPress = now;
    showToast('اضغط مرة أخرى للخروج من التطبيق', ColorsManager.darkGray);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<GetBookmarksCubit>()..getUserBookmarks(),
        ),
        BlocProvider(
          create:
              (_) =>
                  getIt<GetCollectionsBookmarkCubit>()
                    ..getBookMarkCollections(),
        ),
        BlocProvider(create: (_) => getIt<DeleteCubitCubit>()),
      ],
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: BlocListener<MainNavigationCubit, MainTab>(
          listener: _onTabChanged,
          child: PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, _) {
              if (!didPop) _onBack(context);
            },
            child: Scaffold(
              key: _scaffoldKey,
              drawer: const MishkatDrawer(),
              body: BlocBuilder<MainNavigationCubit, MainTab>(
                builder:
                    (context, current) => IndexedStack(
                      index: current.index,
                      children: [
                        for (final tab in MainTab.values)
                          TickerMode(
                            enabled: tab == current,
                            child:
                                tab == current || _tabs.containsKey(tab)
                                    ? _tab(tab)
                                    : const SizedBox.shrink(),
                          ),
                      ],
                    ),
              ),
              bottomNavigationBar: BlocBuilder<MainNavigationCubit, MainTab>(
                builder:
                    (context, current) => MainNavigationBar(
                      selected: current,
                      onSelected: context.read<MainNavigationCubit>().select,
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTab(MainTab tab) => switch (tab) {
    MainTab.home => MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<DailyHadithCubit>()),
        BlocProvider(
          create: (_) => getIt<RandomAhadithCubit>()..emitRandomStats(),
        ),
        BlocProvider(create: (_) => getIt<PrayerTimesCubit>()..init()),
        // Saves the hadith of the day from its card.
        BlocProvider(create: (_) => getIt<AddCubitCubit>()),
      ],
      child: const HomeScreen(),
    ),
    MainTab.search => const SearchWithFiltersScreen(),
    MainTab.library => BlocProvider(
      create: (_) => getIt<LibraryBooksCubit>(),
      child: const LibraryBooksScreen(),
    ),
    MainTab.saved => const BookmarkScreen(),
    MainTab.profile => MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<ProfileCubit>()),
        BlocProvider(create: (_) => getIt<UserStatsCubit>()),
      ],
      child: const ProfileScreen(),
    ),
  };
}
