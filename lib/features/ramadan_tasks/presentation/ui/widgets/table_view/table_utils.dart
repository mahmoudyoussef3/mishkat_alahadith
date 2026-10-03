import 'package:flutter/material.dart';
import '../../../domain/entities/ramadan_task_entity.dart';

/// Converts an integer to Eastern Arabic numerals.
String toArabicNumerals(int number) {
  const digits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  return number.toString().split('').map((d) => digits[int.parse(d)]).join();
}

/// Returns a spiritual icon for a task based on its title keywords.
IconData taskIconForTitle(RamadanTaskEntity task) {
  final t = task.title;
  if (t.contains('صلاة') || t.contains('صلا')) return Icons.mosque_rounded;
  if (t.contains('قرآن') || t.contains('قران') || t.contains('تلاوة')) {
    return Icons.menu_book_rounded;
  }
  if (t.contains('ذكر') || t.contains('أذكار') || t.contains('تسبيح')) {
    return Icons.auto_awesome_rounded;
  }
  if (t.contains('صيام') || t.contains('إفطار') || t.contains('سحور')) {
    return Icons.restaurant_rounded;
  }
  if (t.contains('صدقة') || t.contains('زكاة') || t.contains('تبرع')) {
    return Icons.volunteer_activism_rounded;
  }
  if (t.contains('دعاء') || t.contains('دعوة')) {
    return Icons.front_hand_rounded;
  }
  if (t.contains('علم') || t.contains('درس') || t.contains('حلقة')) {
    return Icons.school_rounded;
  }
  if (task.type == TaskType.todayOnly) return Icons.event_rounded;
  return Icons.check_circle_outline_rounded;
}
