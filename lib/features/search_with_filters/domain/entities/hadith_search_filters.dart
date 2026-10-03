class HadithSearchFilters {
  final String query;
  final String bookSlug;
  final String narrator;
  final String grade;
  final String chapter;
  final String category;

  const HadithSearchFilters({
    required this.query,
    required this.bookSlug,
    required this.narrator,
    required this.grade,
    required this.chapter,
    required this.category,
  });
}
