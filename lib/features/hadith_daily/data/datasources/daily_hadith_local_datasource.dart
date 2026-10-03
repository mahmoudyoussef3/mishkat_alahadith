import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:mishkat_almasabih/core/data/models/new_daily_hadith_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DailyHadithLocalDataSource {
  static const String _key = "dailyHadith";
  static const String _widgetTextKey = 'hadith_text';
  static const String _androidWidgetName = 'HadithWidgetProvider';
  static const String _iOSWidgetName = 'HadithWidget';

  Future<void> saveHadith(NewDailyHadithModel model) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(model.toJson());

    await prefs.setString(_key, jsonString);
    debugPrint("💾 Hadith saved");

    await _updateHomeWidget(model.hadeeth);
  }

  Future<void> _updateHomeWidget(String? hadithText) async {
    if (hadithText == null || hadithText.isEmpty) return;
    try {
      await HomeWidget.saveWidgetData<String>(_widgetTextKey, hadithText);
      await HomeWidget.updateWidget(
        name: _androidWidgetName,
        iOSName: _iOSWidgetName,
      );
      debugPrint('⬆️ Hadith home widget updated');
    } catch (e) {
      debugPrint('❌ Error updating hadith home widget: $e');
    }
  }

  Future<NewDailyHadithModel?> getHadith() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return null;

    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    return NewDailyHadithModel.fromJson(jsonMap);
  }
}
