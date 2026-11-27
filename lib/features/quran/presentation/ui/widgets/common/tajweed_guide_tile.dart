import 'package:flutter/material.dart';
import 'package:mishkat_almasabih/core/helpers/arabic_plurals.dart';
import 'package:mishkat_almasabih/core/helpers/extensions.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';
import 'package:mishkat_almasabih/core/widgets/settings_group.dart';
import 'package:mushaf_text/mushaf_text.dart' show TajweedRule;

/// Opens the full guide to the tajweed rules, as a settings row.
class TajweedGuideTile extends StatelessWidget {
  const TajweedGuideTile({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsGroup(
      title: 'تعلّم',
      children: [
        SettingsTile(
          icon: Icons.school_rounded,
          title: 'دليل أحكام التجويد',
          subtitle:
              '${arabicCount(TajweedRule.values.length, ArabicNoun.ruling)} '
              'بشرحها ومراجعها',
          onTap: () => context.pushNamed(Routes.tajweedGuide),
        ),
      ],
    );
  }
}
