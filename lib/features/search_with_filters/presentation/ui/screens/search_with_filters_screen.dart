import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/extensions.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/features/home/data/models/search_history_models.dart';
import 'package:mishkat_almasabih/features/home/ui/widgets/search_bar_widget.dart';
import 'package:mishkat_almasabih/features/search/search_screen/logic/cubit/search_history_cubit.dart';
import 'package:mishkat_almasabih/features/search/search_screen/ui/widgets/empty_history.dart';
import 'package:mishkat_almasabih/features/search/search_screen/ui/widgets/history_list.dart';
import 'package:mishkat_almasabih/features/search/search_screen/ui/widgets/history_shimmer.dart';

class SearchWithFiltersScreen extends StatefulWidget {
  const SearchWithFiltersScreen({super.key});

  @override
  State<SearchWithFiltersScreen> createState() =>
      _SearchWithFiltersScreenState();
}

class _SearchWithFiltersScreenState extends State<SearchWithFiltersScreen> {
  final TextEditingController searchController = TextEditingController();
  final TextEditingController chapterController = TextEditingController();
  final TextEditingController narratorController = TextEditingController();

  bool showFilters = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<SearchHistoryCubit>().fetchHistory();
      }
    });
  }

  Future<void> addItemToHistory(String query) async {
    final now = DateTime.now();
    final item = AddSearchRequest(
      title: query.trim(),
      date:
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}",
      time:
          "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}",
    );

    await context.read<SearchHistoryCubit>().addSearchItem(item);
  }

  Future<void> removeItem(int id) async {
    await context.read<SearchHistoryCubit>().deleteSearchItem(id);
  }

  Future<void> clearAll() async {
    await context.read<SearchHistoryCubit>().clearAllHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
          top: true,
        bottom: true,
        child: Scaffold(
          backgroundColor: ColorsManager.secondaryBackground,
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  height: 100.h,
                  width: double.infinity,
                  decoration: BoxDecoration(color: ColorsManager.primaryPurple),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned.fill(
                        child: Opacity(
                          opacity: 0.05,
                          child: Image.asset(
                            'assets/images/islamic_pattern.jpg',
                            repeat: ImageRepeat.repeat,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          "البحث",
                          style: TextStyles.displaySmall.copyWith(
                            color: ColorsManager.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 32.sp,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20.h),

                // Search Bar & Filters
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: Column(
                    children: [
                      SearchBarWidget(
                        hintText: 'ابحث في الأحاديث...',
                        controller: searchController,
                        onSearch: (query) async {
                          await addItemToHistory(query);
                          context.pushNamed(
                            Routes.publicSearchSCreen,
                            arguments: query.trim(),
                          );
                        },
                      ),
                      SizedBox(height: 20.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'البحث الأخير',
                            style: TextStyles.titleMedium.copyWith(
                              color: ColorsManager.primaryText,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: clearAll,
                            child: Text(
                              'مسح الكل',
                              style: TextStyles.bodyMedium.copyWith(
                                color: ColorsManager.primaryPurple,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                BlocBuilder<SearchHistoryCubit, SearchHistoryState>(
                  builder: (context, state) {
                    if (state is SearchHistoryLoading) {
                      return const HistoryShimmer();
                    }  else if (state is SearchHistorySuccess) {
                      final List<SearchHistoryItem> items = List.from(
                        state.historyItems,
                      );
                      return items.isNotEmpty
                          ? HistoryList(
                            items: items,
                            onRemove: (index) => removeItem(items[index].id),
                            onClearAll: clearAll,
                          )
                          : const EmptyHistory();
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
