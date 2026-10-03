import 'package:flutter/material.dart';
import '../../../../core/theming/colors.dart';
import '../../../../core/theming/styles.dart';
import '../../../../core/helpers/spacing.dart';
import 'package:mishkat_almasabih/core/theming/home_decorations.dart';
import 'package:mishkat_almasabih/core/theming/home_styles.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      {
        'title': 'حديث اليوم',
        'subtitle': 'Daily Hadith',
        'icon': Icons.lightbulb_outline,
        'color': ColorsManager.primaryGold,
        'onTap': () {},
      },
      {
        'title': 'المحفوظات',
        'subtitle': 'Bookmarks',
        'icon': Icons.bookmark_outline,
        'color': ColorsManager.primaryPurple,
        'onTap': () {},
      },
      {
        'title': 'البحث المتقدم',
        'subtitle': 'Advanced Search',
        'icon': Icons.search,
        'color': ColorsManager.secondaryPurple,
        'onTap': () {},
      },
      {
        'title': 'الإعدادات',
        'subtitle': 'Settings',
        'icon': Icons.settings_outlined,
        'color': ColorsManager.lightPurple,
        'onTap': () {},
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.flash_on, color: ColorsManager.primaryPurple, size: 24),
            SizedBox(width: Spacing.sm),
            Text(
              'إجراءات سريعة',
              style: TextStyles.headlineMedium.copyWith(
                color: ColorsManager.primaryText,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: Spacing.md),
        Row(
          children:
              actions.map((action) {
                return Expanded(
                  child: GestureDetector(
                    onTap: action['onTap'] as VoidCallback,
                    child: Container(
                      margin: EdgeInsets.only(
                        right:
                            actions.indexOf(action) < actions.length - 1
                                ? Spacing.sm
                                : 0,
                      ),
                      padding: EdgeInsets.all(Spacing.md),
                      decoration: HomeDecorations.quickActionCard(),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(Spacing.sm),
                            decoration: HomeDecorations.quickActionIconBg(
                              action['color'] as Color,
                            ),
                            child: Icon(
                              action['icon'] as IconData,
                              color: action['color'] as Color,
                              size: 24,
                            ),
                          ),
                          SizedBox(height: Spacing.sm),
                          Text(
                            action['title'] as String,
                            style: HomeTextStyles.quickActionsTitle,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: Spacing.xs),
                          Text(
                            action['subtitle'] as String,
                            style: HomeTextStyles.quickActionsSubtitle,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }
}
