part of 'azkar_home_cubit.dart';

@immutable
sealed class AzkarHomeState {
  const AzkarHomeState();
}

final class AzkarHomeLoading extends AzkarHomeState {
  const AzkarHomeLoading();
}

final class AzkarHomeLoaded extends AzkarHomeState {
  final List<AzkarCategory> categories;

  /// The translation search looks in, besides the Arabic.
  final AzkarTranslation translation;
  final AzkarSuggestion suggestion;

  /// Null when today's counts could not be read.
  final AzkarDayProgress? progress;

  /// Null when the saved favourites could not be read.
  final List<int>? favoriteIds;

  /// Null shows every chapter.
  final AzkarCollection? collection;
  final String query;

  /// Null while there is no query long enough to search on.
  final AzkarSearchResults? searchResults;

  AzkarHomeLoaded({
    required this.categories,
    required this.translation,
    required this.suggestion,
    required this.progress,
    required this.favoriteIds,
    required this.collection,
    required this.query,
    required this.searchResults,
  });

  late final Map<int, AzkarCategory> _byId = {
    for (final category in categories) category.id: category,
  };

  /// Each chapter's place in the book, from 1.
  late final Map<int, int> _numbers = {
    for (var i = 0; i < categories.length; i++) categories[i].id: i + 1,
  };

  bool get isSearching => searchResults != null;

  AzkarCategory? categoryById(int id) => _byId[id];

  int numberOf(AzkarCategory category) => _numbers[category.id] ?? 0;

  List<AzkarCategory> get visibleCategories {
    final collection = this.collection;
    if (collection == null) return categories;
    return [
      for (final category in categories)
        if (collection.contains(category.id)) category,
    ];
  }

  List<AzkarCategory> get favorites => [
    for (final id in favoriteIds ?? const <int>[])
      if (categoryById(id) case final category?) category,
  ];

  bool isFavorite(int categoryId) => favoriteIds?.contains(categoryId) ?? false;

  AzkarCategoryProgress progressOf(AzkarCategory category) =>
      progress?.of(category) ?? AzkarCategoryProgress.of(category, const {});

  AzkarHomeLoaded copyWith({
    List<AzkarCategory>? categories,
    AzkarTranslation? translation,
    AzkarSuggestion? suggestion,
    AzkarDayProgress? Function()? progress,
    List<int>? Function()? favoriteIds,
    AzkarCollection? Function()? collection,
    String? query,
    AzkarSearchResults? Function()? searchResults,
  }) {
    return AzkarHomeLoaded(
      categories: categories ?? this.categories,
      translation: translation ?? this.translation,
      suggestion: suggestion ?? this.suggestion,
      progress: progress != null ? progress() : this.progress,
      favoriteIds: favoriteIds != null ? favoriteIds() : this.favoriteIds,
      collection: collection != null ? collection() : this.collection,
      query: query ?? this.query,
      searchResults:
          searchResults != null ? searchResults() : this.searchResults,
    );
  }
}

final class AzkarHomeFailure extends AzkarHomeState {
  final String message;

  const AzkarHomeFailure(this.message);
}
