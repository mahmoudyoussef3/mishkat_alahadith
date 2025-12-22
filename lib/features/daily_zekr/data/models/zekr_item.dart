import 'package:flutter/foundation.dart';

/// Represents a single Daily Zekr section with its persisted state.
///
/// Sections:
/// - الحديث اليومي
/// - أذكار الصباح
/// - أذكار المساء
/// - الورد اليومي
@immutable
class ZekrItem {
  final ZekrSection section;
  final bool checked;

  const ZekrItem({required this.section, required this.checked});

  ZekrItem copyWith({ZekrSection? section, bool? checked}) {
    return ZekrItem(
      section: section ?? this.section,
      checked: checked ?? this.checked,
    );
  }
}

/// Enum representing the four Daily Zekr sections.
enum ZekrSection {dailyWard, hadithDaily, morningAdhkar, eveningAdhkar }

extension ZekrSectionExt on ZekrSection {
  /// Arabic title for the section
  String get title {
    switch (this) {
      case ZekrSection.dailyWard:
        return 'الورد اليومي';
      case ZekrSection.hadithDaily:
        return 'الحديث اليومي';
      case ZekrSection.morningAdhkar:
        return 'أذكار الصباح';
      case ZekrSection.eveningAdhkar:
        return 'أذكار المساء';

    }
  }

  /// Short Arabic description shown under the title
  String get description {
    switch (this) {
      case ZekrSection.hadithDaily:
        return 'اقرأ حديثًا يُنير يومك ويزيدك علمًا.';
      case ZekrSection.morningAdhkar:
        return 'ابدأ يومك بالأذكار للطمأنينة والبركة.';
      case ZekrSection.eveningAdhkar:
        return 'اختم يومك بأذكار تحفظك وتهدّئ قلبك.';
      case ZekrSection.dailyWard:
        return 'خصّص وردًا يوميًا من القرآن أو الأذكار.';
    }
  }

  /// Unique notification ID per section
  int get notificationId {
    switch (this) {
      case ZekrSection.hadithDaily:
        return 1001;
      case ZekrSection.morningAdhkar:
        return 1002;
      case ZekrSection.eveningAdhkar:
        return 1003;
      case ZekrSection.dailyWard:
        return 1004;
    }
  }

  /// Android channel id used for local notifications
  String get channelId {
    switch (this) {
      case ZekrSection.hadithDaily:
        return 'zekr_hadith_daily';
      case ZekrSection.morningAdhkar:
        return 'zekr_morning';
      case ZekrSection.eveningAdhkar:
        return 'zekr_evening';
      case ZekrSection.dailyWard:
        return 'zekr_daily_ward';
    }
  }

  /// Android channel name used for local notifications
  String get channelName {
    switch (this) {
      case ZekrSection.hadithDaily:
        return 'تذكير الحديث اليومي';
      case ZekrSection.morningAdhkar:
        return 'تذكير أذكار الصباح';
      case ZekrSection.eveningAdhkar:
        return 'تذكير أذكار المساء';
      case ZekrSection.dailyWard:
        return 'تذكير الورد اليومي';
    }
  }

  /// Default notification body shown hourly when unchecked
  String get reminderBody {
    switch (this) {
      case ZekrSection.hadithDaily:
        return 'هل قرأت الحديث اليوم؟ خذ لحظة للتأمل.';
      case ZekrSection.morningAdhkar:
        return 'حان وقت أذكار الصباح، لتبدأ يومك بالطمأنينة.';
      case ZekrSection.eveningAdhkar:
        return 'لا تنسَ أذكار المساء لراحة القلب قبل النوم.';
      case ZekrSection.dailyWard:
        return 'ذكّر نفسك بوردك اليومي. آية، ذكر، أو دعاء.';
    }
  }
}
