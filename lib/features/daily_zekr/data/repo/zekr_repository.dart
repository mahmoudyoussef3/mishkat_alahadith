import 'package:mishkat_almasabih/features/daily_zekr/data/models/zekr_item.dart';

/// Abstraction over local persistence for Daily Zekr states.
abstract class ZekrRepository {
  /// Load all sections with their persisted checked state.
  Future<List<ZekrItem>> loadAll();

  /// Persist the checked state for a specific section.
  Future<void> setChecked(ZekrSection section, bool checked);
}
