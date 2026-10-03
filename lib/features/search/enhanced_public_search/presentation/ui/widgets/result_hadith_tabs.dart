import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/enhanced_search_styles.dart';
import 'package:mishkat_almasabih/core/theming/enhanced_search_decorations.dart';

class ResultHadithTabs extends StatelessWidget {
  final String selectedTab;
  final Function(String) onTabSelected;

  const ResultHadithTabs({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = ["شرح", "الدروس المستفادة", "معاني الكلمات"];
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children:
            tabs.map((tab) {
              final isSelected = selectedTab == tab;
              return GestureDetector(
                onTap: () => onTabSelected(tab),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
                  decoration:
                      isSelected
                          ? EnhancedSearchDecorations.selectedTab()
                          : EnhancedSearchDecorations.unselectedTab(),
                  child: Text(
                    tab,
                    style:
                        isSelected
                            ? EnhancedSearchTextStyles.selectedTabText
                            : EnhancedSearchTextStyles.unselectedTabText,
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}
