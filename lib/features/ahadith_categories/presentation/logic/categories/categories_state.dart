import 'package:mishkat_almasabih/features/ahadith_categories/domain/entities/category_entity.dart';

sealed class CategoriesState {
  const CategoriesState();
}

class CategoriesInitial extends CategoriesState {
  const CategoriesInitial();
}

class CategoriesLoading extends CategoriesState {
  const CategoriesLoading();
}

class CategoriesLoaded extends CategoriesState {
  final List<CategoryEntity> categories;

  const CategoriesLoaded(this.categories);

  static bool _isRoot(CategoryEntity category) {
    final parent = category.parentId;
    return parent == null || parent.isEmpty || parent == '0';
  }

  static int _largestFirst(CategoryEntity a, CategoryEntity b) =>
      b.hadeethsCount.compareTo(a.hadeethsCount);

  /// Top-level topics, largest first.
  List<CategoryEntity> get roots =>
      categories.where(_isRoot).toList()..sort(_largestFirst);

  /// Sub-topics of the topic [id], largest first.
  List<CategoryEntity> childrenOf(String id) =>
      categories.where((c) => c.parentId == id).toList()..sort(_largestFirst);

  /// Hadiths across the top-level topics.
  int get totalHadiths => roots.fold(0, (sum, c) => sum + c.hadeethsCount);
}

class CategoriesError extends CategoriesState {
  final String message;

  const CategoriesError(this.message);
}
