import 'package:flutter/material.dart';

/// A single predefined worship item the user can tap to create a task.
class WorshipTemplate {
  final String title;
  final IconData icon;

  const WorshipTemplate({required this.title, required this.icon});
}

/// A labelled group of worship templates.
class WorshipSection {
  final String title;
  final IconData icon;
  final Color accentColor;
  final List<WorshipTemplate> items;

  const WorshipSection({
    required this.title,
    required this.icon,
    required this.accentColor,
    required this.items,
  });

  /// Returns a copy with only items whose titles are NOT in [exclude].
  WorshipSection withoutTitles(Set<String> exclude) {
    final filtered = items.where((i) => !exclude.contains(i.title)).toList();
    return WorshipSection(
      title: title,
      icon: icon,
      accentColor: accentColor,
      items: filtered,
    );
  }
}

/// All predefined Ramadan worship sections.
const List<WorshipSection> kWorshipSections = [
  // ── الصلاة ──
  WorshipSection(
    title: 'الصلاة',
    icon: Icons.mosque_rounded,
    accentColor: Color(0xFF7440E9),
    items: [
      WorshipTemplate(title: 'صلاة الفجر', icon: Icons.wb_twilight_rounded),
      WorshipTemplate(title: 'صلاة الظهر', icon: Icons.wb_sunny_outlined),
      WorshipTemplate(title: 'صلاة العصر', icon: Icons.sunny_snowing),
      WorshipTemplate(title: 'صلاة المغرب', icon: Icons.wb_twilight),
      WorshipTemplate(title: 'صلاة العشاء', icon: Icons.nights_stay_outlined),
      WorshipTemplate(title: 'سنة الفجر', icon: Icons.auto_awesome_outlined),
      WorshipTemplate(title: 'سنة الظهر', icon: Icons.auto_awesome_outlined),
      WorshipTemplate(title: 'سنة المغرب', icon: Icons.auto_awesome_outlined),
      WorshipTemplate(title: 'سنة العشاء', icon: Icons.auto_awesome_outlined),
      WorshipTemplate(title: 'قيام الليل', icon: Icons.dark_mode_outlined),
    ],
  ),

  // ── الأذكار ──
  WorshipSection(
    title: 'الأذكار',
    icon: Icons.auto_awesome_rounded,
    accentColor: Color(0xFF00897B),
    items: [
      WorshipTemplate(title: 'أذكار الصباح', icon: Icons.wb_sunny_rounded),
      WorshipTemplate(title: 'أذكار المساء', icon: Icons.nights_stay_rounded),
      WorshipTemplate(
        title: 'أذكار بعد الصلاة',
        icon: Icons.front_hand_rounded,
      ),
    ],
  ),

  // ── القرآن ──
  WorshipSection(
    title: 'القرآن الكريم',
    icon: Icons.menu_book_rounded,
    accentColor: Color(0xFF6D4C41),
    items: [
      WorshipTemplate(title: 'ورد التلاوة', icon: Icons.auto_stories_rounded),
      WorshipTemplate(title: 'ورد التدبّر', icon: Icons.psychology_rounded),
      WorshipTemplate(title: 'ورد الاستماع', icon: Icons.headphones_rounded),
    ],
  ),

  // ── الخيرات ──
  WorshipSection(
    title: 'الخيرات',
    icon: Icons.volunteer_activism_rounded,
    accentColor: Color(0xFFE65100),
    items: [
      WorshipTemplate(title: 'الصدقة', icon: Icons.handshake_rounded),
      WorshipTemplate(title: 'صلة الرحم', icon: Icons.groups_rounded),
      WorshipTemplate(
        title: 'إدخال السرور على مسلم',
        icon: Icons.sentiment_satisfied_alt_rounded,
      ),
      WorshipTemplate(title: 'إفطار صائم', icon: Icons.restaurant_rounded),
    ],
  ),
];
