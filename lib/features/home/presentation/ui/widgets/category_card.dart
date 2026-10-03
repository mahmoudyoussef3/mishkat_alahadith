import 'package:flutter/material.dart';

import '../../../../core/helpers/spacing.dart';
import 'package:mishkat_almasabih/core/theming/home_decorations.dart';
import 'package:mishkat_almasabih/core/theming/home_styles.dart';

class CategoryCard extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.name,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: HomeDecorations.categoryCard(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon container with gradient background
            Container(
              width: 60,
              height: 60,
              decoration: HomeDecorations.categoryIconContainer(color),
              child: Icon(icon, color: color, size: 28),
            ),
            SizedBox(height: Spacing.md),
            // Category name
            Text(
              name,
              style: HomeTextStyles.categoryName,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: Spacing.sm),
            // Subtle indicator
            Container(
              width: 20,
              height: 3,
              decoration: HomeDecorations.categoryIndicatorBar(color),
            ),
          ],
        ),
      ),
    );
  }
}
