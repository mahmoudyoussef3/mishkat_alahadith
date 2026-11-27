import 'dart:convert';
import 'dart:io';

import 'package:home_widget/home_widget.dart';

/// The data behind the Android "آية اليوم" home screen widget. iOS has no
/// such widget, so there is nothing to write there.
class DailyAyahWidgetDataSource {
  /// Read by `DailyAyahWidgetProvider.kt`: a JSON list, one entry per day.
  static const String entriesKey = 'daily_ayah_entries';

  /// Fully qualified, so it still resolves if a flavour suffixes the
  /// application id.
  static const String _androidWidget =
      'com.mishkat_almasabih.app.DailyAyahWidgetProvider';

  Future<void> save(List<Map<String, Object>> entries) async {
    if (!Platform.isAndroid) return;
    await HomeWidget.saveWidgetData<String>(entriesKey, jsonEncode(entries));
    await HomeWidget.updateWidget(qualifiedAndroidName: _androidWidget);
  }
}
