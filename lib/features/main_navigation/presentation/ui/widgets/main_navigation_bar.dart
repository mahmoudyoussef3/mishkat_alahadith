import 'package:flutter/material.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/features/main_navigation/presentation/logic/main_navigation_cubit.dart';

/// Bottom navigation: an outlined icon per tab, filled inside a soft pill
/// when selected. Styling comes from the theme's NavigationBarThemeData.
class MainNavigationBar extends StatelessWidget {
  const MainNavigationBar({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final MainTab selected;
  final ValueChanged<MainTab> onSelected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: ColorsManager.border)),
      ),
      child: NavigationBar(
        selectedIndex: selected.index,
        onDestinationSelected: (index) => onSelected(MainTab.values[index]),
        destinations: [
          for (final tab in MainTab.values)
            NavigationDestination(
              icon: Icon(_icons(tab).$1),
              selectedIcon: Icon(_icons(tab).$2),
              label: _label(tab),
            ),
        ],
      ),
    );
  }

  static (IconData, IconData) _icons(MainTab tab) => switch (tab) {
    MainTab.home => (Icons.home_outlined, Icons.home_rounded),
    MainTab.search => (Icons.search_rounded, Icons.search_rounded),
    MainTab.library => (
      Icons.local_library_outlined,
      Icons.local_library_rounded,
    ),
    MainTab.saved => (Icons.bookmark_border_rounded, Icons.bookmark_rounded),
    MainTab.profile => (Icons.person_outline_rounded, Icons.person_rounded),
  };

  static String _label(MainTab tab) => switch (tab) {
    MainTab.home => 'الرئيسية',
    MainTab.search => 'البحث',
    MainTab.library => 'المكتبة',
    MainTab.saved => 'المحفوظات',
    MainTab.profile => 'حسابي',
  };
}
