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

  /// An entry for [query] searched at [at], with the API's "yyyy-MM-dd"
  /// date and "HH:mm:ss" time.
  factory NewSearchHistoryEntry.forQuery(String query, DateTime at) {
    String two(int value) => value.toString().padLeft(2, '0');
    return NewSearchHistoryEntry(
      title: query.trim(),
      date: '${at.year}-${two(at.month)}-${two(at.day)}',
      time: '${two(at.hour)}:${two(at.minute)}:${two(at.second)}',
    );
  }
}
