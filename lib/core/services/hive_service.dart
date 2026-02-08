import 'package:hive_flutter/hive_flutter.dart';

/// HiveService centralizes Hive initialization and box management.
///
/// Initializes Hive for Flutter, registers adapters, and provides
/// box names used across the app.
class HiveService {
  static const String ramadanTasksBox = 'ramadan_tasks';

  /// Call once during app startup before accessing any Hive boxes.
  static Future<void> init() async {
    await Hive.initFlutter();
    // Adapters for models will be registered close to their definitions
    // to avoid tight coupling. The RamadanTaskModel adapter is registered
    // in the feature's datasource init method.
  }
}
