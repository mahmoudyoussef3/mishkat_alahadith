class UserStats {
  final int? bookmarksCount;
  final int? collectionsCount;
  final int? cardsCount;
  final int? searchesCount;
  final String? lastActivityAt;
  final List<TopCollectionStat> topCollections;

  const UserStats({
    this.bookmarksCount,
    this.collectionsCount,
    this.cardsCount,
    this.searchesCount,
    this.lastActivityAt,
    this.topCollections = const [],
  });
}

class TopCollectionStat {
  final String? name;
  final int? count;

  const TopCollectionStat({this.name, this.count});
}
