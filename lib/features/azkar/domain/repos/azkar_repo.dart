import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/azkar_category.dart';
import '../entities/azkar_day_progress.dart';
import '../entities/azkar_settings.dart';

/// Hisn Al-Muslim, bundled with the app, and what the reader keeps on the
/// device: favourite chapters, today's counts and reading settings.
abstract class AzkarRepo {
  /// Every chapter in source order, with [translation] filled in under the
  /// Arabic.
  Future<ApiResult<List<AzkarCategory>>> getCategories(
    AzkarTranslation translation,
  );

  /// Favourite chapter ids, most recently added first.
  Future<ApiResult<List<int>>> getFavoriteIds();

  /// Replaces the favourites with `change(current)` as one step; concurrent
  /// updates run one after another, each seeing the one before.
  Future<ApiResult<List<int>>> updateFavoriteIds(
    List<int> Function(List<int> current) change,
  );

  /// The last day anything was counted, or null when nothing ever was.
  Future<ApiResult<AzkarDayProgress?>> getProgress();

  /// Replaces the stored progress with `change(stored)` as one step;
  /// concurrent updates run one after another, each seeing the one before.
  Future<ApiResult<AzkarDayProgress>> updateProgress(
    AzkarDayProgress Function(AzkarDayProgress? stored) change,
  );

  Future<ApiResult<AzkarSettings>> getSettings();

  Future<ApiResult<void>> saveSettings(AzkarSettings settings);
}
