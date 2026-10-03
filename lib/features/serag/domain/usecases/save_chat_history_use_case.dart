import '../entities/chat_message.dart';
import '../repos/chat_history_repo.dart';

class SaveChatHistoryUseCase {
  final ChatHistoryRepo _repo;

  SaveChatHistoryUseCase(this._repo);

  Future<void> call(List<ChatMessage> messages) => _repo.saveMessages(messages);
}
