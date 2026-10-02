import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:mishkat_almasabih/features/hadith_daily/data/models/new_daily_hadith_model.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

class SaveHadithDailyRepo {
  static const String _key = "dailyHadith";
  static const String _widgetTextKey = 'hadith_text';
  static const String _androidWidgetName = 'HadithWidgetProvider';
  static const String _iOSWidgetName = 'HadithWidget';

 static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "https://hadeethenc.com/api/v1/",
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
    ),
  )..interceptors.add(
      PrettyDioLogger(
        requestBody: true,
        requestHeader: true,
        responseHeader: true,
      ),
    );

  static Dio get dio => _dio;
  /// حفظ الحديث في SharedPreferences وتحديث ويدجت الشاشة الرئيسية
  Future<void> saveHadith(NewDailyHadithModel model) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(model.toJson());

    await prefs.setString(_key, jsonString);
    debugPrint("💾 Hadith saved");

    await _updateHomeWidget(model.hadeeth);
  }

  /// Pushes the hadith to the home screen widget on every save — including
  /// saves from the FCM background isolate — so the widget refreshes even when
  /// the app is never opened. A widget failure must never fail the save itself.
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

  /// جلب الحديث المخزن
  Future<NewDailyHadithModel?> getHadith() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return null;

    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    return NewDailyHadithModel.fromJson(jsonMap);
  }

  /// حذف الحديث
  Future<void> deleteHadith() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    debugPrint('🗑️ Hadith deleted');
  }

  /// جلب حديث جديد من API وحفظه فوراً
  Future<NewDailyHadithModel?> fetchHadith(String id) async {


    
    try {
      final response =
          await _dio.get("hadeeths/one/", queryParameters: {
        "language": "ar",
        "id": id,
      });

      final hadithModel = NewDailyHadithModel.fromJson(response.data);

      await saveHadith(hadithModel);
      debugPrint('✅ New hadith fetched and saved');

      return hadithModel;
    } catch (e) {
      debugPrint("❌ Error fetching hadith: $e");
      return null;
    }
  }
}
