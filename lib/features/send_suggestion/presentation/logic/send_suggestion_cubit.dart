import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/features/send_suggestion/domain/usecases/send_suggestion_use_case.dart';

part 'send_suggestion_state.dart';

class SendSuggestionCubit extends Cubit<SendSuggestionState> {
  final SendSuggestionUseCase _sendSuggestion;

  SendSuggestionCubit(this._sendSuggestion)
    : super(const SendSuggestionInitial());

  Future<void> send(String suggestion) async {
    emit(const SendSuggestionSending());
    final result = await _sendSuggestion(suggestion);
    result.when(
      success: (_) => emit(const SendSuggestionSent()),
      failure: (failure) => emit(SendSuggestionFailed(failure.message)),
    );
  }
}
