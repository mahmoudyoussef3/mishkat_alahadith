class CategoryEntity {
  final String id;
  final String title;
  final int hadeethsCount;
  final String? parentId;

  CategoryEntity({
    required this.id,
    required this.title,
    required this.hadeethsCount,
    this.parentId,
  });
}