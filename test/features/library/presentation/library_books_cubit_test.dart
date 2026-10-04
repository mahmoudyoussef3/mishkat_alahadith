import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/features/library/domain/entities/category_books.dart';
import 'package:mishkat_almasabih/features/library/domain/entities/library_book.dart';
import 'package:mishkat_almasabih/features/library/domain/entities/library_statistics.dart';
import 'package:mishkat_almasabih/features/library/domain/repos/library_repo.dart';
import 'package:mishkat_almasabih/features/library/domain/usecases/get_library_books_use_case.dart';
import 'package:mishkat_almasabih/features/library/presentation/logic/library_books/library_books_cubit.dart';

const _bukhari = LibraryBook(bookName: 'Sahih Bukhari', bookSlug: 'bukhari');
const _nawawi = LibraryBook(bookName: 'الأربعون النووية', bookSlug: 'nawawi');

class _FakeLibraryRepo implements LibraryRepo {
  final Map<String, CategoryBooks> cache = {};

  /// Completers let a test decide when, and in which order, the server
  /// answers.
  final Map<String, Completer<ApiResult<CategoryBooks>>> pending = {};

  void answer(String categoryId, ApiResult<CategoryBooks> result) =>
      pending[categoryId]!.complete(result);

  @override
  Future<CategoryBooks?> getCachedCategoryBooks(String categoryId) async =>
      cache[categoryId];

  @override
  Future<ApiResult<CategoryBooks>> getCategoryBooks(String categoryId) =>
      (pending[categoryId] = Completer()).future;

  @override
  Future<LibraryStatistics?> getCachedStatistics() =>
      throw UnimplementedError();

  @override
  Future<ApiResult<LibraryStatistics>> getStatistics() =>
      throw UnimplementedError();
}

List<String?> _slugs(LibraryBooksState state) =>
    (state as LibraryBooksLoaded).books.map((book) => book.bookSlug).toList();

void main() {
  late _FakeLibraryRepo repo;
  late LibraryBooksCubit cubit;
  late List<LibraryBooksState> emitted;
  late StreamSubscription<LibraryBooksState> subscription;

  setUp(() {
    repo = _FakeLibraryRepo();
    cubit = LibraryBooksCubit(GetLibraryBooksUseCase(repo));
    emitted = [];
    subscription = cubit.stream.listen(emitted.add);
  });

  tearDown(() async {
    await subscription.cancel();
    await cubit.close();
  });

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  test(
    'shows loading, then the server shelf, when nothing is cached',
    () async {
      final load = cubit.load(['nine']);
      await settle();
      repo.answer(
        'nine',
        const ApiResult.success(CategoryBooks(books: [_bukhari])),
      );
      await load;
      await settle();

      expect(emitted.first, isA<LibraryBooksLoading>());
      expect(_slugs(emitted.last), ['bukhari']);
    },
  );

  test('shows the cached shelf while refreshing it from the server', () async {
    repo.cache['nine'] = const CategoryBooks(books: [_bukhari]);

    final load = cubit.load(['nine']);
    await settle();
    expect(emitted.single, isA<LibraryBooksLoaded>());
    expect((emitted.single as LibraryBooksLoaded).isRefreshing, isTrue);

    repo.answer(
      'nine',
      const ApiResult.success(CategoryBooks(books: [_bukhari, _nawawi])),
    );
    await load;
    await settle();

    expect(_slugs(emitted.last), ['bukhari', 'nawawi']);
    expect((emitted.last as LibraryBooksLoaded).isRefreshing, isFalse);
  });

  test(
    'reports the failure when the server fails and nothing is cached',
    () async {
      final load = cubit.load(['nine']);
      await settle();
      repo.answer('nine', const ApiResult.failure(NetworkFailure('offline')));
      await load;
      await settle();

      expect(emitted.last, isA<LibraryBooksError>());
      expect((emitted.last as LibraryBooksError).message, 'offline');
    },
  );

  test('keeps the cached shelf when the server fails', () async {
    repo.cache['nine'] = const CategoryBooks(books: [_bukhari]);

    final load = cubit.load(['nine']);
    await settle();
    repo.answer('nine', const ApiResult.failure(NetworkFailure()));
    await load;
    await settle();

    expect(_slugs(emitted.last), ['bukhari']);
    expect((emitted.last as LibraryBooksLoaded).isRefreshing, isFalse);
  });

  test('ignores a slow answer for a filter the user already left', () async {
    final first = cubit.load(['nine']);
    await settle();
    final second = cubit.load(['forty']);
    await settle();

    repo.answer(
      'forty',
      const ApiResult.success(CategoryBooks(books: [_nawawi])),
    );
    await second;
    repo.answer(
      'nine',
      const ApiResult.success(CategoryBooks(books: [_bukhari])),
    );
    await first;
    await settle();

    expect(_slugs(cubit.state), ['nawawi']);
  });
}
