import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';
import 'package:mishkat_almasabih/features/home/data/models/search_history_models.dart';
import 'package:mishkat_almasabih/features/home/ui/widgets/search_bar_widget.dart';
import 'package:mishkat_almasabih/features/search/search_screen/logic/cubit/search_history_cubit.dart';

class HomeSearchBarSection extends StatefulWidget {
  const HomeSearchBarSection({super.key});

  @override
  State<HomeSearchBarSection> createState() => _HomeSearchBarSectionState();
}

class _HomeSearchBarSectionState extends State<HomeSearchBarSection> {
  late final TextEditingController _controller;
  final GlobalKey _searchKey = GlobalKey();

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

  @override
  Widget build(BuildContext context) {
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
                  (value) => Navigator.of(context).pushNamed(
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
