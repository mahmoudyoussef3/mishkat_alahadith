import '../repos/chat_history_repo.dart';

class ClearChatHistoryUseCase {
  final ChatHistoryRepo _repo;

  ClearChatHistoryUseCase(this._repo);

  Future<void> call() => _repo.clearMessages();
}
