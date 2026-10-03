import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/domain/usecases/get_categories_use_case.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/presentation/logic/categories/categories_state.dart';

class CategoriesCubit extends Cubit<CategoriesState> {
  final GetCategoriesUseCase _getCategoriesUseCase;

  CategoriesCubit(this._getCategoriesUseCase)
    : super(const CategoriesInitial());

  Future<void> getCategories() async {
    emit(const CategoriesLoading());
    final result = await _getCategoriesUseCase();

    result.when(
      success: (categories) => emit(CategoriesLoaded(categories)),
      failure: (failure) => emit(CategoriesError(failure.message)),
    );
  }


}
