import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/extensions.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/core/widgets/screen_title_header.dart';
import 'package:mishkat_almasabih/core/widgets/state_message.dart';
import 'package:mishkat_almasabih/features/home/presentation/ui/widgets/search_bar_widget.dart';
import 'package:mishkat_almasabih/features/search/search_history/domain/entities/search_history_entry.dart';
import 'package:mishkat_almasabih/features/search/search_history/presentation/logic/search_history_cubit.dart';
import 'package:shimmer/shimmer.dart';

/// Search tab: the query field, recent searches, and suggested topics for
/// people with no history yet.
class SearchWithFiltersScreen extends StatefulWidget {
  const SearchWithFiltersScreen({super.key});

  @override
  State<SearchWithFiltersScreen> createState() =>
      _SearchWithFiltersScreenState();
}

class _SearchWithFiltersScreenState extends State<SearchWithFiltersScreen> {
  static const _suggestions = [
    'الصبر',
    'بر الوالدين',
    'الصدقة',
    'صلاة الليل',
    'النية',
    'حسن الخلق',
  ];

  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _search(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    unawaited(
      context.read<SearchHistoryCubit>().addSearchItem(
        NewSearchHistoryEntry.forQuery(trimmed, DateTime.now()),
      ),
    );
    context.pushNamed(Routes.publicSearchSCreen, arguments: trimmed);
  }

  void _searchSuggestion(String query) {
    _controller.text = query;
    _search(query);
  }

  void _openHistoryEntry(SearchHistoryEntry entry) => context.pushNamed(
    Routes.filterResultSearch,
    arguments: {'search': entry.title},
  );

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: ColorsManager.secondaryBackground,
        body: SafeArea(
          bottom: false,
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.only(bottom: 24.h),
            children: [
              const ScreenTitleHeader(title: 'البحث'),
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
                child: SearchBarWidget(
                  controller: _controller,
                  hintText: 'ابحث بكلمة أو بجزء من حديث…',
                  onSearch: _search,
                ),
              ),
              BlocBuilder<SearchHistoryCubit, SearchHistoryState>(
                builder:
                    (context, state) => switch (state) {
                      SearchHistorySuccess(:final historyItems)
                          when historyItems.isNotEmpty =>
                        _RecentSearches(
                          items: historyItems,
                          onOpen: _openHistoryEntry,
                          onRemove:
                              (entry) => context
                                  .read<SearchHistoryCubit>()
                                  .deleteSearchItem(entry.id),
                          onClearAll:
                              () =>
                                  context
                                      .read<SearchHistoryCubit>()
                                      .clearAllHistory(),
                        ),
                      SearchHistoryLoading() => const _RecentSearchesShimmer(),
                      _ => _Suggestions(
                        suggestions: _suggestions,
                        onSelected: _searchSuggestion,
                      ),
                    },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentSearches extends StatelessWidget {
  const _RecentSearches({
    required this.items,
    required this.onOpen,
    required this.onRemove,
    required this.onClearAll,
  });

  final List<SearchHistoryEntry> items;
  final ValueChanged<SearchHistoryEntry> onOpen;
  final ValueChanged<SearchHistoryEntry> onRemove;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'عمليات البحث الأخيرة',
                  style: TextStyles.actionLabel.copyWith(
                    color: ColorsManager.secondaryText,
                  ),
                ),
              ),
              TextButton(
                onPressed: onClearAll,
                style: TextButton.styleFrom(
                  minimumSize: Size(0, 32.h),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text('مسح الكل', style: TextStyles.actionLabel),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              for (final entry in items)
                _QueryChip(
                  label: entry.title,
                  icon: Icons.history_rounded,
                  onTap: () => onOpen(entry),
                  onRemove: () => onRemove(entry),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Suggestions extends StatelessWidget {
  const _Suggestions({required this.suggestions, required this.onSelected});

  final List<String> suggestions;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const StateMessage(
          icon: Icons.manage_search_rounded,
          title: 'ابحث في آلاف الأحاديث',
          subtitle: 'اكتب كلمة أو جزءاً من حديث، أو جرّب أحد هذه المواضيع',
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              for (final suggestion in suggestions)
                _QueryChip(
                  label: suggestion,
                  icon: Icons.north_west_rounded,
                  onTap: () => onSelected(suggestion),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QueryChip extends StatelessWidget {
  const _QueryChip({
    required this.label,
    required this.icon,
    required this.onTap,
    this.onRemove,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final onRemove = this.onRemove;
    return Material(
      color: ColorsManager.lightGray,
      borderRadius: BorderRadius.circular(12.r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(
            12.w,
            6.h,
            onRemove == null ? 12.w : 4.w,
            6.h,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16.r, color: ColorsManager.gray),
              SizedBox(width: 4.w),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 220.w),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyles.bodyMedium.copyWith(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (onRemove != null)
                InkResponse(
                  onTap: onRemove,
                  radius: 16.r,
                  child: Padding(
                    padding: EdgeInsets.all(4.r),
                    child: Semantics(
                      label: 'حذف "$label" من السجل',
                      button: true,
                      child: Icon(
                        Icons.close_rounded,
                        size: 16.r,
                        color: ColorsManager.gray,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentSearchesShimmer extends StatelessWidget {
  const _RecentSearchesShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 28.h, 20.w, 0),
      child: Shimmer.fromColors(
        baseColor: ColorsManager.shimmerBase,
        highlightColor: ColorsManager.shimmerHighlight,
        child: Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: [
            for (final width in [92.0, 70.0, 110.0, 84.0])
              Container(
                width: width.w,
                height: 32.h,
                decoration: BoxDecoration(
                  color: ColorsManager.shimmerBase,
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
