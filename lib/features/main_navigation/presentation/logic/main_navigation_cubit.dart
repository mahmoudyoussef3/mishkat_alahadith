import 'package:flutter_bloc/flutter_bloc.dart';

/// Top-level destinations of the bottom navigation bar, in display order.
enum MainTab {
  home('HomeScreen'),
  search('SearchScreen'),
  library('LibraryScreen'),
  saved('BookmarkScreen'),
  profile('ProfileScreen');

  const MainTab(this.analyticsName);

  /// Screen name reported to analytics, matching the standalone routes.
  final String analyticsName;
}

/// Which bottom-navigation tab is showing.
class MainNavigationCubit extends Cubit<MainTab> {
  MainNavigationCubit() : super(MainTab.home);

  void select(MainTab tab) {
    if (tab != state) emit(tab);
  }
}
