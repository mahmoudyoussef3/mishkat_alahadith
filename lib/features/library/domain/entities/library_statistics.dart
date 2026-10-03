class LibraryStatistics {
  final int totalBooks;
  final int totalHadiths;
  final int totalChapters;
  final Map<String, CategoryStatistics> booksByCategory;
  final List<TopBookStatistics> topBooks;
  final String lastUpdated;

  const LibraryStatistics({
    required this.totalBooks,
    required this.totalHadiths,
    required this.totalChapters,
    required this.booksByCategory,
    required this.topBooks,
    required this.lastUpdated,
  });
}

class CategoryStatistics {
  final String name;
  final String nameEn;
  final String nameUr;
  final int count;
  final int hadiths;

  const CategoryStatistics({
    required this.name,
    required this.nameEn,
    required this.nameUr,
    required this.count,
    required this.hadiths,
  });
}

class TopBookStatistics {
  final String name;
  final int hadiths;
  final int chapters;

  const TopBookStatistics({
    required this.name,
    required this.hadiths,
    required this.chapters,
  });
}
