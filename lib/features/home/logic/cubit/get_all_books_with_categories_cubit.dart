
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:mishkat_almasabih/core/networking/api_error_model.dart';
import 'package:mishkat_almasabih/features/home/data/repos/get_all_books_with_categories_repo.dart';

part 'get_all_books_with_categories_state.dart';

class GetAllBooksWithCategoriesCubit
    extends Cubit<GetAllBooksWithCategoriesState> {
  final GetAllBooksWithCategoriesRepo _allBooksWithCategoriesRepo;
  GetAllBooksWithCategoriesCubit(this._allBooksWithCategoriesRepo)
    : super(GetAllBooksWithCategoriesInitial());


  Future<void> emitGetAllBooksWithCategories() async {
    emit(GetAllBooksWithCategoriesLoading());
    final response =
        await _allBooksWithCategoriesRepo.getAllBooksWithCategoriesRepo();

    response.fold(
      (error) => emit(
        GetAllBooksWithCategoriesError(error.getAllErrorMessages()),
      ),
      (data) {


        emit(GetAllBooksWithCategoriesSuccess()
        );
      },
    );
  }
}
