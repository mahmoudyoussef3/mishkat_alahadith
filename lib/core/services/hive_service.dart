import 'package:hive_flutter/hive_flutter.dart';


class HiveService {
  static const String ramadanTasksBox = 'ramadan_tasks';

  static Future<void> init() async {
    await Hive.initFlutter();

  }
}
