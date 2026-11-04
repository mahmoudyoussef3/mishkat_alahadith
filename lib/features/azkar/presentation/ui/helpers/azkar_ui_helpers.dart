import 'package:flutter/material.dart';
import 'package:mishkat_almasabih/core/helpers/arabic_plurals.dart';
import 'package:mishkat_almasabih/features/azkar/domain/entities/azkar_category.dart';
import 'package:mishkat_almasabih/features/azkar/domain/entities/azkar_collection.dart';
import 'package:mishkat_almasabih/features/azkar/domain/entities/azkar_settings.dart';
import 'package:mishkat_almasabih/features/azkar/domain/entities/azkar_suggestion.dart';
import 'package:mishkat_almasabih/features/azkar/domain/entities/zikr.dart';

const String kHisnAlMuslim = 'حصن المسلم';
const String kAzkarReciter = 'بصوت حمد الدريهم';

extension AzkarCollectionLabel on AzkarCollection {
  String get label => switch (this) {
    AzkarCollection.dayAndNight => 'اليوم والليلة',
    AzkarCollection.prayer => 'الطهارة والصلاة',
    AzkarCollection.homeAndClothing => 'المنزل واللباس',
    AzkarCollection.distress => 'الكرب والتحصين',
    AzkarCollection.illness => 'المرض والجنائز',
    AzkarCollection.nature => 'المطر والطبيعة',
    AzkarCollection.food => 'الطعام والصيام',
    AzkarCollection.social => 'الأسرة والمجتمع',
    AzkarCollection.travel => 'السفر',
    AzkarCollection.hajj => 'الحج والعمرة',
    AzkarCollection.remembrance => 'الذكر والاستغفار',
  };
}

extension AzkarTimeOfDayLabel on AzkarTimeOfDay {
  String get label => switch (this) {
    AzkarTimeOfDay.morning => 'حان وقت أذكار الصباح',
    AzkarTimeOfDay.midday => 'أذكار ما بعد الصلاة',
    AzkarTimeOfDay.evening => 'حان وقت أذكار المساء',
    AzkarTimeOfDay.night => 'قبل أن تنام',
  };

  IconData get icon => switch (this) {
    AzkarTimeOfDay.morning => Icons.wb_sunny_rounded,
    AzkarTimeOfDay.midday => Icons.light_mode_rounded,
    AzkarTimeOfDay.evening => Icons.wb_twilight_rounded,
    AzkarTimeOfDay.night => Icons.bedtime_rounded,
  };
}

extension AzkarTranslationLabel on AzkarTranslation {
  String get label => switch (this) {
    AzkarTranslation.none => 'بدون',
    AzkarTranslation.english => 'English',
  };
}

extension AzkarFontScaleLabel on AzkarFontScale {
  String get label => switch (this) {
    AzkarFontScale.small => 'صغير',
    AzkarFontScale.medium => 'متوسط',
    AzkarFontScale.large => 'كبير',
    AzkarFontScale.extraLarge => 'أكبر',
  };
}

/// A chapter offered as a shortcut, under a short name of its own.
class AzkarShortcut {
  final int categoryId;
  final String label;
  final IconData icon;

  const AzkarShortcut(this.categoryId, this.label, this.icon);
}

/// The chapters said every day, for quick access.
const List<AzkarShortcut> kDailyAzkarShortcuts = [
  AzkarShortcut(
    AzkarCategoryIds.morningEvening,
    'الصباح والمساء',
    Icons.wb_twilight_rounded,
  ),
  AzkarShortcut(AzkarCategoryIds.sleep, 'النوم', Icons.bedtime_rounded),
  AzkarShortcut(AzkarCategoryIds.waking, 'الاستيقاظ', Icons.alarm_rounded),
  AzkarShortcut(
    AzkarCategoryIds.afterPrayer,
    'بعد الصلاة',
    Icons.mosque_rounded,
  ),
  AzkarShortcut(AzkarCategoryIds.adhan, 'الأذان', Icons.campaign_rounded),
  AzkarShortcut(
    AzkarCategoryIds.istighfar,
    'الاستغفار',
    Icons.volunteer_activism_rounded,
  ),
  AzkarShortcut(
    AzkarCategoryIds.tasbeeh,
    'التسبيح',
    Icons.auto_awesome_rounded,
  ),
  AzkarShortcut(AzkarCategoryIds.worry, 'الهم والحزن', Icons.spa_rounded),
];

/// «٣ مرات», for a zikr said more than once.
String repetitionLabel(int count) => arabicCount(count, ArabicNoun.time);

/// The zikr as text to copy or share: the words, how often, the meaning
/// when one is shown, and where it comes from.
String formatZikrForSharing(AzkarCategory category, Zikr zikr) {
  final translation = zikr.translation;
  return [
    zikr.text,
    if (zikr.isRepeated) '(${repetitionLabel(zikr.count)})',
    if (translation != null) '\n$translation',
    '\n— ${category.title} · $kHisnAlMuslim',
  ].join('\n');
}
