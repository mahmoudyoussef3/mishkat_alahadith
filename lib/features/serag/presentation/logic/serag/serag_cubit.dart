import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:mishkat_almasabih/core/networking/api_error_model.dart';
import 'package:mishkat_almasabih/features/serag/data/models/serag_request_model.dart';
import 'package:mishkat_almasabih/features/serag/data/repos/serag_repo.dart';
import 'package:mishkat_almasabih/features/serag/logic/cubit/serag_state.dart';

class SeragCubit extends Cubit<SeragState> {
  final SeragRepo _seragRepo;

  SeragCubit(this._seragRepo) : super(SeragInitial());

  Future<void> sendMessage({
    required String hadeeth,
    required String grade_ar,
    required String source,
    required String takhrij_ar,
    required String content,
  }) async {
    emit(SeragLoading());

    final result = await _seragRepo.serag(
      SeragRequestModel(
        hadith: Hadith(
          hadeeth: hadeeth,
          grade_ar: grade_ar,
          source: source,
          takhrij_ar: takhrij_ar,
        ),
        messages: [Message(role: 'user', content: content)],
      ),
    );

    result.fold(
      (failure) => emit(
        SeragFailure(failure.getAllErrorMessages() ),
      ),
      (response) {
        emit(SeragSuccess(response));
      },
    );
  }
}
