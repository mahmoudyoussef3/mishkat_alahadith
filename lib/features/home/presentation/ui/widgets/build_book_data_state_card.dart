import 'package:flutter/material.dart';
import 'package:mishkat_almasabih/core/helpers/spacing.dart';
import 'package:mishkat_almasabih/core/theming/home_decorations.dart';
import 'package:mishkat_almasabih/core/theming/home_styles.dart';

class BuildBookDataStateCard extends StatelessWidget {
  const BuildBookDataStateCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Spacing.md),
      decoration: HomeDecorations.statsCard(color),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          SizedBox(height: Spacing.sm),
          Text(value, style: HomeTextStyles.statsValue),
          Text(
            title,
            style: HomeTextStyles.statsTitle,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
