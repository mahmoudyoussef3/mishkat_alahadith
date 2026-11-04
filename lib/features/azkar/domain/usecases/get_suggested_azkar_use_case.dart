import '../entities/azkar_category.dart';
import '../entities/azkar_suggestion.dart';

/// The chapter that suits the hour: the morning remembrances until noon,
/// those after the prayer around midday, the evening ones from the
/// afternoon, and the remembrances before sleep at night.
class GetSuggestedAzkarUseCase {
  final DateTime Function() _now;

  GetSuggestedAzkarUseCase({DateTime Function()? now})
    : _now = now ?? DateTime.now;

  AzkarSuggestion call() => switch (_now().hour) {
    >= 4 && < 12 => const AzkarSuggestion(
      timeOfDay: AzkarTimeOfDay.morning,
      categoryId: AzkarCategoryIds.morningEvening,
    ),
    >= 12 && < 15 => const AzkarSuggestion(
      timeOfDay: AzkarTimeOfDay.midday,
      categoryId: AzkarCategoryIds.afterPrayer,
    ),
    >= 15 && < 21 => const AzkarSuggestion(
      timeOfDay: AzkarTimeOfDay.evening,
      categoryId: AzkarCategoryIds.morningEvening,
    ),
    _ => const AzkarSuggestion(
      timeOfDay: AzkarTimeOfDay.night,
      categoryId: AzkarCategoryIds.sleep,
    ),
  };
}
