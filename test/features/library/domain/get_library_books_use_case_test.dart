import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/features/library/domain/entities/category_books.dart';
import 'package:mishkat_almasabih/features/library/domain/entities/library_book.dart';
import 'package:mishkat_almasabih/features/library/domain/entities/library_statistics.dart';
import 'package:mishkat_almasabih/features/library/domain/repos/library_repo.dart';
import 'package:mishkat_almasabih/features/library/domain/usecases/get_library_books_use_case.dart';

const _bukhari = LibraryBook(bookName: 'Sahih Bukhari', bookSlug: 'bukhari');
const _muslim = LibraryBook(bookName: 'Sahih Muslim', bookSlug: 'muslim');
const _nawawi = LibraryBook(bookName: 'الأربعون النووية', bookSlug: 'nawawi');

class _FakeLibraryRepo implements LibraryRepo {
  final Map<String, ApiResult<CategoryBooks>> remote = {};
  final Map<String, CategoryBooks> cache = {};

  @override
  Future<CategoryBooks?> getCachedCategoryBooks(String categoryId) async =>
      cache[categoryId];

  @override
  Future<ApiResult<CategoryBooks>> getCategoryBooks(String categoryId) async =>
      remote[categoryId] ?? const ApiResult.failure(ServerFailure());

  @override
  Future<LibraryStatistics?> getCachedStatistics() =>
      throw UnimplementedError();

  @override
  Future<ApiResult<LibraryStatistics>> getStatistics() =>
      throw UnimplementedError();
}

List<String?> _slugs(ApiResult<List<LibraryBook>> result) => switch (result) {
  ApiSuccess(:final data) => data.map((book) => book.bookSlug).toList(),
  ApiFailure() => fail('expected success, got $result'),
};

void main() {
  late _FakeLibraryRepo repo;
  late GetLibraryBooksUseCase useCase;

  setUp(() {
    repo = _FakeLibraryRepo();
    useCase = GetLibraryBooksUseCase(repo);
  });

  test('joins the books of every category in category order', () async {
    repo.remote['nine'] = const ApiResult.success(
      CategoryBooks(books: [_bukhari, _muslim]),
    );
    repo.remote['forty'] = const ApiResult.success(
      CategoryBooks(books: [_nawawi]),
    );

    final result = await useCase(['nine', 'forty']);

    expect(_slugs(result), ['bukhari', 'muslim', 'nawawi']);
  });

  test('lists a book found in two categories once', () async {
    repo.remote['nine'] = const ApiResult.success(
      CategoryBooks(books: [_bukhari]),
    );
    repo.remote['adab'] = const ApiResult.success(
      CategoryBooks(books: [_bukhari, _nawawi]),
    );

    final result = await useCase(['nine', 'adab']);

    expect(_slugs(result), ['bukhari', 'nawawi']);
  });

  test('skips a category that fails when another succeeds', () async {
    repo.remote['nine'] = const ApiResult.success(
      CategoryBooks(books: [_bukhari]),
    );

    final result = await useCase(['nine', 'forty']);

    expect(_slugs(result), ['bukhari']);
  });

  test('fails with the first failure when every category fails', () async {
    repo.remote['nine'] = const ApiResult.failure(NetworkFailure());

    final result = await useCase(['nine', 'forty']);

    expect(result, isA<ApiFailure<List<LibraryBook>>>());
    expect((result as ApiFailure).failure, isA<NetworkFailure>());
  });

  test('returns an empty shelf for no categories', () async {
    expect(_slugs(await useCase([])), isEmpty);
  });

  test('returns the cached shelf once every category is cached', () async {
    repo.cache['nine'] = const CategoryBooks(books: [_bukhari]);
    repo.cache['forty'] = const CategoryBooks(books: [_nawawi]);

    final cached = await useCase.cached(['nine', 'forty']);

    expect(cached?.map((book) => book.bookSlug), ['bukhari', 'nawawi']);
  });

  test('returns no cached shelf while any category is uncached', () async {
    repo.cache['nine'] = const CategoryBooks(books: [_bukhari]);

    expect(await useCase.cached(['nine', 'forty']), isNull);
  });
}
