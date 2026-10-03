import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/features/serag/domain/entities/serag_hadith_context.dart';
import 'package:mishkat_almasabih/features/serag/domain/usecases/ask_serag_use_case.dart';
import 'package:mishkat_almasabih/features/serag/presentation/logic/serag/serag_state.dart';

class SeragCubit extends Cubit<SeragState> {
  final AskSeragUseCase _askSerag;

  SeragCubit(this._askSerag) : super(SeragInitial());

  Future<void> sendMessage({
    required SeragHadithContext hadith,
    required String content,
  }) async {
    emit(SeragLoading());

    final result = await _askSerag(hadith: hadith, question: content);

    result.when(
      success: (response) => emit(SeragSuccess(response)),
      failure: (failure) => emit(SeragFailure(failure.message)),
    );
  }
}
