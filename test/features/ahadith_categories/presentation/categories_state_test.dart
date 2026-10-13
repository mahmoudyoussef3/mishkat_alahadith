import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/domain/entities/category_entity.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/presentation/logic/categories/categories_state.dart';

CategoryEntity _category(String id, int count, {String? parent}) =>
    CategoryEntity(id: id, title: id, hadeethsCount: count, parentId: parent);

void main() {
  final state = CategoriesLoaded([
    _category('small', 10),
    _category('large', 100, parent: '0'),
    _category('middle', 50, parent: ''),
    _category('child-a', 5, parent: 'large'),
    _category('child-b', 30, parent: 'large'),
  ]);

  test('roots are the top-level topics, largest first', () {
    expect(state.roots.map((c) => c.id), ['large', 'middle', 'small']);
  });

  test('childrenOf lists a topic\'s sub-topics, largest first', () {
    expect(state.childrenOf('large').map((c) => c.id), ['child-b', 'child-a']);
    expect(state.childrenOf('small'), isEmpty);
  });

  test('totalHadiths counts only the top-level topics', () {
    expect(state.totalHadiths, 160);
  });
}
