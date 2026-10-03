import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:mishkat_almasabih/features/bookmark/domain/entities/bookmark_collection.dart';
import 'package:mishkat_almasabih/features/bookmark/domain/usecases/get_bookmark_collections_use_case.dart';
import 'package:mishkat_almasabih/features/bookmark/domain/usecases/get_cached_bookmark_collections_use_case.dart';

part 'get_collections_bookmark_state.dart';

class GetCollectionsBookmarkCubit extends Cubit<GetCollectionsBookmarkState> {
  final GetCachedBookmarkCollectionsUseCase _getCachedCollections;
  final GetBookmarkCollectionsUseCase _getCollections;
  GetCollectionsBookmarkCubit(this._getCachedCollections, this._getCollections)
    : super(GetCollectionsBookmarkInitial());

  Future<void> getBookMarkCollections() async {
    final cached = await _getCachedCollections();

    if (cached != null) {
      emit(
        GetCollectionsBookmarkSuccess(
          cached,
          isFromCache: true,
          isRefreshing: true,
        ),
      );

      _backgroundRefresh();
    } else {
      emit(GetCollectionsBookmarkLoading());
      final result = await _getCollections();
      result.when(
        success:
            (collections) => emit(GetCollectionsBookmarkSuccess(collections)),
        failure:
            (failure) => emit(GetCollectionsBookmarkError(failure.message)),
      );
    }
  }

  Future<void> _backgroundRefresh() async {
    final result = await _getCollections();
    result.when(
      success: (collections) {
        emit(
          GetCollectionsBookmarkSuccess(
            collections,
            isFromCache: false,
            isRefreshing: false,
          ),
        );
      },
      failure: (_) {
        if (state is GetCollectionsBookmarkSuccess) {
          emit(
            (state as GetCollectionsBookmarkSuccess).copyWith(
              isRefreshing: false,
            ),
          );
        }
      },
    );
  }
}
