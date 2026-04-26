import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/domain/usecases/get_categories_usecase.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/presentation/cubit/categories_cubit/categories_state.dart';

class CategoriesCubit extends Cubit<CategoriesState> {
  final GetCategoriesUseCase _getCategoriesUseCase;

  CategoriesCubit(this._getCategoriesUseCase)
    : super(const CategoriesInitial());

  Future<void> getCategories() async {
    emit(const CategoriesLoading());
    final result = await _getCategoriesUseCase();

    result.fold(
      (error) => emit(CategoriesError(error.message ?? 'حدث خطأ ما')),
      (categories) => emit(CategoriesLoaded(categories)),
    );
  }


}
