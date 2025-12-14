import 'package:flutter/material.dart';

class HadithRefreshNotifier extends ChangeNotifier {
  static final HadithRefreshNotifier _instance = HadithRefreshNotifier._internal();
  
  factory HadithRefreshNotifier() => _instance;
  
  HadithRefreshNotifier._internal();

  void notifyRefresh() {
    debugPrint('🔔 Notifying all listeners to refresh hadith');
    notifyListeners();
  }
}