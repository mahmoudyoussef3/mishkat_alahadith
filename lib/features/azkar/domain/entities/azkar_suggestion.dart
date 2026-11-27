/// The parts of the day that have remembrances of their own.
enum AzkarTimeOfDay { morning, midday, evening, night }

/// The chapter that suits the time of day.
class AzkarSuggestion {
  final AzkarTimeOfDay timeOfDay;
  final int categoryId;

  const AzkarSuggestion({required this.timeOfDay, required this.categoryId});

  @override
  bool operator ==(Object other) =>
      other is AzkarSuggestion &&
      other.timeOfDay == timeOfDay &&
      other.categoryId == categoryId;

  @override
  int get hashCode => Object.hash(timeOfDay, categoryId);
}
