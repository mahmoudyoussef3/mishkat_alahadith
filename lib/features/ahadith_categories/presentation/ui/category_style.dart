import 'package:flutter/material.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/domain/entities/category_entity.dart';

/// Icon and tint that identify a topic across the categories screens.
class CategoryStyle {
  const CategoryStyle(this.icon, this.background, this.foreground);

  final IconData icon;
  final Color background;
  final Color foreground;

  /// Recognises the main topics by the words in their title; anything else
  /// gets a neutral tag.
  factory CategoryStyle.of(String title) {
    final purple = (ColorsManager.primarySoft, ColorsManager.purpleText);
    final gold = (ColorsManager.goldSoft, ColorsManager.primaryGold);
    final green = (ColorsManager.successSoft, ColorsManager.success);
    final (icon, tone) = switch (title) {
      _ when title.contains('فقه') => (Icons.balance_rounded, purple),
      _ when title.contains('عقيدة') => (Icons.brightness_5_rounded, purple),
      _ when title.contains('فضائل') || title.contains('آداب') => (
        Icons.volunteer_activism_rounded,
        gold,
      ),
      _ when title.contains('سيرة') || title.contains('تاريخ') => (
        Icons.history_edu_rounded,
        green,
      ),
      _ when title.contains('قرآن') => (Icons.menu_book_rounded, gold),
      _ when title.contains('دعوة') || title.contains('حسبة') => (
        Icons.campaign_rounded,
        purple,
      ),
      _ when title.contains('أخرى') => (
        Icons.more_horiz_rounded,
        (ColorsManager.lightGray, ColorsManager.secondaryText),
      ),
      _ => (Icons.sell_rounded, purple),
    };
    return CategoryStyle(icon, tone.$1, tone.$2);
  }
}

/// Which category's hadiths to list, and its sub-topics for filtering.
class CategoryHadithsArgs {
  const CategoryHadithsArgs({
    required this.categoryId,
    required this.title,
    this.hadithsCount,
    this.subcategories = const [],
  });

  final String categoryId;
  final String title;
  final int? hadithsCount;
  final List<CategoryEntity> subcategories;
}
