import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/features/serag/domain/entities/chat_message.dart';
import 'package:mishkat_almasabih/features/serag/domain/entities/serag_hadith_context.dart';
import 'package:mishkat_almasabih/features/serag/domain/usecases/ask_serag_use_case.dart';
import 'package:mishkat_almasabih/features/serag/presentation/logic/serag/serag_state.dart';

class SeragCubit extends Cubit<SeragState> {
  final AskSeragUseCase _askSerag;

  SeragCubit(this._askSerag) : super(SeragInitial());

  /// Asks about the last message of [conversation], sending the earlier
  /// turns too so follow-up questions keep their context.
  Future<void> sendMessage({
    required SeragHadithContext hadith,
    required List<ChatMessage> conversation,
  }) async {
    emit(SeragLoading());

    final result = await _askSerag(hadith: hadith, conversation: conversation);

    result.when(
      success: (response) => emit(SeragSuccess(response)),
      failure: (failure) => emit(SeragFailure(failure.message)),
    );
  }
}
