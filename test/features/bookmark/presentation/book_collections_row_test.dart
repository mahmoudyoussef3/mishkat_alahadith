import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/features/bookmark/domain/entities/bookmark_collection.dart';
import 'package:mishkat_almasabih/features/bookmark/domain/repos/bookmark_repo.dart';
import 'package:mishkat_almasabih/features/bookmark/domain/usecases/get_bookmark_collections_use_case.dart';
import 'package:mishkat_almasabih/features/bookmark/domain/usecases/get_cached_bookmark_collections_use_case.dart';
import 'package:mishkat_almasabih/features/bookmark/presentation/logic/collections/get_collections_bookmark_cubit.dart';
import 'package:mishkat_almasabih/features/bookmark/presentation/ui/widgets/book_collections_row.dart';

class _FakeBookmarkRepo extends Fake implements BookmarkRepo {
  _FakeBookmarkRepo(this.collections);

  final List<BookmarkCollection> collections;

  @override
  Future<List<BookmarkCollection>?> getCachedCollections() async => null;

  @override
  Future<ApiResult<List<BookmarkCollection>>> getCollections() async =>
      ApiResult.success(collections);
}

Future<GetCollectionsBookmarkCubit> _loadedCubit(
  List<BookmarkCollection> collections,
) async {
  final repo = _FakeBookmarkRepo(collections);
  final cubit = GetCollectionsBookmarkCubit(
    GetCachedBookmarkCollectionsUseCase(repo),
    GetBookmarkCollectionsUseCase(repo),
  );
  await cubit.getBookMarkCollections();
  return cubit;
}

Widget _row(GetCollectionsBookmarkCubit cubit, {double textScale = 1}) =>
    ScreenUtilInit(
      designSize: const Size(375, 812),
      builder:
          (_, __) => MaterialApp(
            home: MediaQuery.withClampedTextScaling(
              minScaleFactor: textScale,
              maxScaleFactor: textScale,
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Scaffold(
                  body: BlocProvider.value(
                    value: cubit,
                    child: BookmarkCollectionsRow(
                      selectedCollection: null,
                      onCollectionSelected: (_) {},
                    ),
                  ),
                ),
              ),
            ),
          ),
    );

void main() {
  testWidgets('hides itself when there are no named collections', (
    tester,
  ) async {
    final cubit = await _loadedCubit(const [BookmarkCollection(count: 3)]);
    await tester.pumpWidget(_row(cubit));

    expect(find.text('الكل'), findsNothing);
    await cubit.close();
  });

  for (final scale in [1.0, 1.3]) {
    testWidgets('fits a tile with a count at text scale $scale', (
      tester,
    ) async {
      final cubit = await _loadedCubit(const [
        BookmarkCollection(collection: 'أذكار اليوم', count: 9),
      ]);
      await tester.pumpWidget(_row(cubit, textScale: scale));

      expect(find.text('أذكار اليوم'), findsOneWidget);
      expect(find.text('٩ أحاديث'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await cubit.close();
    });
  }
}
