class SearchHistoryEntry {
  final int id;
  final String title;
  final String time;
  final String date;
  final String createdAt;

  const SearchHistoryEntry({
    required this.id,
    required this.title,
    required this.time,
    required this.date,
    required this.createdAt,
  });
}

class NewSearchHistoryEntry {
  final String title;
  final String time;
  final String date;
  final String? searchType;
  final int? resultsCount;

  const NewSearchHistoryEntry({
    required this.title,
    required this.time,
    required this.date,
    this.searchType,
    this.resultsCount,
  });
}
