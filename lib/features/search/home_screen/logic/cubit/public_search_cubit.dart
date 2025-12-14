import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:mishkat_almasabih/core/networking/api_error_model.dart';
import 'package:mishkat_almasabih/features/search/home_screen/data/models/public_search_model.dart';
import 'package:mishkat_almasabih/features/search/home_screen/data/repos/public_search_repo.dart';

part 'public_search_state.dart';

class PublicSearchCubit extends Cubit<PublicSearchState> {
  final PublicSearchRepo _publicSearchRepo;
  PublicSearchCubit(this._publicSearchRepo) : super(PublicSearchInitial());

  Future<void> emitPublicSearch(String query) async {
    emit(PublicSearchLoading());
    final result = await _publicSearchRepo.getPublicSearchRepo(query);
    result.fold(
      (error) =>
          emit(PublicSearchFailure(error.getAllErrorMessages() )),
      (searchResult) => emit(PublicSearchSuccess(searchResult)),
    );
  }
}
