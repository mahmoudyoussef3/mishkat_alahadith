import '../entities/chat_message.dart';
import '../repos/chat_history_repo.dart';

class LoadChatHistoryUseCase {
  final ChatHistoryRepo _repo;

  LoadChatHistoryUseCase(this._repo);

  Future<List<ChatMessage>> call() => _repo.loadMessages();
}
