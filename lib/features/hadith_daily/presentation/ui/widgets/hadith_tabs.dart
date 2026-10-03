import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/daily_hadith_decorations.dart';
import 'package:mishkat_almasabih/core/theming/daily_hadith_styles.dart';

class HadithTabs extends StatelessWidget {
  final String selectedTab;
  final Function(String) onTabSelected;

  const HadithTabs({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = ["شرح", "الدروس المستفادة", "معاني الكلمات"];

    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
      decoration: DailyHadithDecorations.tabsContainer(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children:
            tabs.map((tab) {
              final isSelected = selectedTab == tab;
              return GestureDetector(
                onTap: () => onTabSelected(tab),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  decoration: DailyHadithDecorations.tabPill(
                    isSelected: isSelected,
                  ),
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 250),
                    style: DailyHadithTextStyles.tabLabel(
                      isSelected: isSelected,
                    ),
                    child: Text(tab),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}
