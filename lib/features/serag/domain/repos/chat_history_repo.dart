import '../entities/chat_message.dart';

abstract class ChatHistoryRepo {
  Future<List<ChatMessage>> loadMessages();

  Future<void> saveMessages(List<ChatMessage> messages);

  Future<void> clearMessages();
}
