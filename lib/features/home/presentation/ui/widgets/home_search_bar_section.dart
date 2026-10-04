import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';
import 'package:mishkat_almasabih/core/widgets/app_icon_button.dart';
import 'package:mishkat_almasabih/features/main_navigation/presentation/logic/main_navigation_cubit.dart';
import 'package:mishkat_almasabih/features/search/search_history/domain/entities/search_history_entry.dart';
import 'package:mishkat_almasabih/features/home/presentation/ui/widgets/search_bar_widget.dart';
import 'package:mishkat_almasabih/features/search/search_history/presentation/logic/search_history_cubit.dart';

/// Search field with a shortcut to the full search tab.
class HomeSearchBarSection extends StatefulWidget {
  const HomeSearchBarSection({super.key});

  @override
  State<HomeSearchBarSection> createState() => _HomeSearchBarSectionState();
}

class _HomeSearchBarSectionState extends State<HomeSearchBarSection> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _search(String query) {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) return;

    // Saving to history must not delay the results.
    unawaited(
      context.read<SearchHistoryCubit>().addSearchItem(
        NewSearchHistoryEntry.forQuery(trimmedQuery, DateTime.now()),
      ),
    );
    Navigator.of(
      context,
    ).pushNamed(Routes.publicSearchSCreen, arguments: trimmedQuery);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SearchBarWidget(
            controller: _controller,
            hintText: 'ابحث في الأحاديث والكتب…',
            onSearch: _search,
          ),
        ),
        SizedBox(width: 8.w),
        AppIconButton(
          tooltip: 'البحث المتقدم',
          icon: Icons.tune_rounded,
          variant: AppIconButtonVariant.filled,
          size: 52.h,
          onPressed:
              () => context.read<MainNavigationCubit>().select(MainTab.search),
        ),
      ],
    );
  }
}
