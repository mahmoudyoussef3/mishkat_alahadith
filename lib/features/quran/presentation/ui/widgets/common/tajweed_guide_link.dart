import 'package:flutter/material.dart';
import 'package:mishkat_almasabih/core/helpers/extensions.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';
import 'package:mishkat_almasabih/core/theming/quran_decorations.dart';
import 'package:mishkat_almasabih/core/theming/quran_styles.dart';

/// Opens the full guide to the twenty-six rules.
class TajweedGuideLink extends StatelessWidget {
  final QuranSurfaceColors colors;

  const TajweedGuideLink({super.key, required this.colors});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: () => context.pushNamed(Routes.tajweedGuide),
      leading: Icon(Icons.school_outlined, color: colors.accent),
      title: Text(
        'دليل أحكام التجويد',
        style: QuranTextStyles.tileTitle(colors.title),
      ),
      subtitle: Text(
        'الأحكام الستة والعشرون بشرحها ومراجعها',
        style: QuranTextStyles.tileMeta(colors.subtitle),
      ),
      trailing: Icon(Icons.chevron_left_rounded, color: colors.subtitle),
    );
  }
}
