/// One day's "آية اليوم" notification, ready to schedule.
class DailyAyahNotification {
  final int id;
  final String title;
  final String body;

  /// Where the ayah is from, shown next to the title.
  final String subtitle;
  final String payload;
  final DateTime fireAt;

  const DailyAyahNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.subtitle,
    required this.payload,
    required this.fireAt,
  });
}
