import 'dart:convert';

import 'package:mishkat_almasabih/features/daily_zekr/data/models/personal_task.dart';
import 'package:mishkat_almasabih/features/daily_zekr/data/repo/personal_tasks_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsPersonalTasksRepository implements PersonalTasksRepository {
  static const String _prefsKey = 'daily_zekr_personal_tasks';

  const SharedPrefsPersonalTasksRepository();

  @override
  Future<List<PersonalTask>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) return const [];

    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];

    return decoded
        .whereType<Map>()
        .map(
          (m) => PersonalTask.fromJson(
            m.map((key, value) => MapEntry(key.toString(), value))
                as Map<String, Object?>,
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<void> saveAll(List<PersonalTask> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = jsonEncode(tasks.map((t) => t.toJson()).toList());
    await prefs.setString(_prefsKey, payload);
  }
}
