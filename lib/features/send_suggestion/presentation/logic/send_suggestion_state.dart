part of 'send_suggestion_cubit.dart';

sealed class SendSuggestionState {
  const SendSuggestionState();
}

final class SendSuggestionInitial extends SendSuggestionState {
  const SendSuggestionInitial();
}

final class SendSuggestionSending extends SendSuggestionState {
  const SendSuggestionSending();
}

final class SendSuggestionSent extends SendSuggestionState {
  const SendSuggestionSent();
}

final class SendSuggestionFailed extends SendSuggestionState {
  final String message;
  const SendSuggestionFailed(this.message);
}
