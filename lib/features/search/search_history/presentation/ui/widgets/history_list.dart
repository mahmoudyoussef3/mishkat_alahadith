import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/extensions.dart';
import 'package:mishkat_almasabih/core/helpers/spacing.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/features/home/data/models/search_history_models.dart';
import 'package:mishkat_almasabih/features/search/search_screen/data/models/history_search_model.dart';
import 'history_list_item.dart';

class HistoryList extends StatelessWidget {
  final List<SearchHistoryItem> items;
  final Function(int) onRemove;
  final VoidCallback onClearAll;

  const HistoryList({
    super.key,
    required this.items,
    required this.onRemove,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListView.builder(
            itemCount: items.length,
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return HistoryListItem(
                onTap:
                    () => context.pushNamed(
                      Routes.filterResultSearch,
                      arguments: {'search': items[index].title},
                    ),
                item: items[index],
                onRemove: () => onRemove(index),
              );
            },
          ),
          SizedBox(height: Spacing.xl),
        ],
      ),
    );
  }

  Widget buildIslamicSeparator() {
    return Container(
      height: 1.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorsManager.primaryPurple.withOpacity(0.3),
            ColorsManager.primaryGold.withOpacity(0.6),
            ColorsManager.primaryPurple.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(1.r),
      ),
    );
  }
}
