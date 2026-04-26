import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/domain/entities/hadith_entity.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/domain/usecases/get_ahadith_by_category_usecase.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/presentation/cubit/hadith_by_category_cubit/ahadith_by_category_state.dart';

class HadithByCategoryCubit extends Cubit<HadithByCategoryState> {
  final GetAhadithByCategoryUseCase _getAhadithByCategoryUseCase;
  static const int _perPage = 20;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  int _lastPage = 1;
  String? _categoryId;
  int _requestVersion = 0;

  HadithByCategoryCubit(this._getAhadithByCategoryUseCase)
    : super(const HadithByCategoryInitial());

  Future<void> getAhadithByCategory(
    String categoryId, {
    bool refresh = false,
  }) async {
    final isNewCategory = _categoryId != categoryId;
    if (isNewCategory || refresh) {
      _categoryId = categoryId;
      _currentPage = 1;
      _lastPage = 1;
      _isLoadingMore = false;
      _requestVersion++;
      emit(const HadithByCategoryLoading());
    }

    final requestVersion = _requestVersion;
    final result = await _getAhadithByCategoryUseCase(
      categoryId,
      page: 1,
      perPage: _perPage,
    );

    result.fold(
      (error) {
        if (requestVersion != _requestVersion || _categoryId != categoryId) {
          return;
        }
        emit(HadithByCategoryError(error.message ?? 'حدث خطأ ما'));
      },
      (response) {
        if (requestVersion != _requestVersion || _categoryId != categoryId) {
          return;
        }
        _isLoadingMore = false;
        _currentPage = response.meta.currentPage;
        _lastPage = response.meta.lastPage;
        emit(
          HadithByCategoryLoaded(
            ahadith: response.data,
            meta: response.meta,
          ),
        );
      },
    );
  }

  Future<void> loadMore() async {
    if (_categoryId == null ||
        _isLoadingMore ||
        _currentPage >= _lastPage) {
      return;
    }

    _isLoadingMore = true;
    final requestVersion = _requestVersion;
    final requestCategoryId = _categoryId;
    final nextPage = _currentPage + 1;
    final currentState = state;
    if (currentState is HadithByCategoryLoaded) {
      emit(currentState.copyWith(isLoadingMore: true, clearPaginationError: true));
    }

    final result = await _getAhadithByCategoryUseCase(
      requestCategoryId!,
      page: nextPage,
      perPage: _perPage,
    );

    result.fold(
      (error) {
        if (requestVersion != _requestVersion ||
            requestCategoryId != _categoryId) {
          _isLoadingMore = false;
          return;
        }
        _isLoadingMore = false;
        final latestState = state;
        if (latestState is HadithByCategoryLoaded) {
          emit(
            latestState.copyWith(
              isLoadingMore: false,
              paginationError: error.message ?? 'حدث خطأ ما',
            ),
          );
        } else {
          emit(HadithByCategoryError(error.message ?? 'حدث خطأ ما'));
        }
      },
      (response) {
        if (requestVersion != _requestVersion ||
            requestCategoryId != _categoryId) {
          _isLoadingMore = false;
          return;
        }
        _isLoadingMore = false;
        _currentPage = response.meta.currentPage;
        _lastPage = response.meta.lastPage;
        final latestState = state;
        final existing =
            latestState is HadithByCategoryLoaded
                ? latestState.ahadith
                : <HadithEntity>[];
        emit(
          HadithByCategoryLoaded(
            ahadith: [...existing, ...response.data],
            meta: response.meta,
          ),
        );
      },
    );
  }
}
