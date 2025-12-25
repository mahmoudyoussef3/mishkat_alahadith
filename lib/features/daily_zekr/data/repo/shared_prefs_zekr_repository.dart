import 'package:shared_preferences/shared_preferences.dart';
import 'package:mishkat_almasabih/features/daily_zekr/data/models/zekr_item.dart';
import 'zekr_repository.dart';

/// SharedPreferences-backed implementation of ZekrRepository.
class SharedPrefsZekrRepository implements ZekrRepository {
  static const _prefsKeyPrefix = 'daily_zekr_checked_';

  const SharedPrefsZekrRepository();

  String _keyForSection(ZekrSection section) =>
      '$_prefsKeyPrefix${section.name}';

  @override
  Future<List<ZekrItem>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    return ZekrSection.values
        .map(
          (s) => ZekrItem(
            section: s,
            checked: prefs.getBool(_keyForSection(s)) ?? false,
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<void> setChecked(ZekrSection section, bool checked) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyForSection(section), checked);
  }
}
