import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/features/serag/domain/entities/chat_message.dart';
import 'package:mishkat_almasabih/features/serag/domain/usecases/clear_chat_history_use_case.dart';
import 'package:mishkat_almasabih/features/serag/domain/usecases/load_chat_history_use_case.dart';
import 'package:mishkat_almasabih/features/serag/domain/usecases/save_chat_history_use_case.dart';
import 'package:mishkat_almasabih/features/serag/presentation/logic/chat_history/chat_history_state.dart';

class ChatHistoryCubit extends Cubit<ChatHistoryState> {
  final LoadChatHistoryUseCase _loadHistory;
  final SaveChatHistoryUseCase _saveHistory;
  final ClearChatHistoryUseCase _clearHistory;
  final List<ChatMessage> _messages = [];

  ChatHistoryCubit(this._loadHistory, this._saveHistory, this._clearHistory)
    : super(ChatHistoryInitial());

  List<ChatMessage> get messages => List.unmodifiable(_messages);

  Future<void> addMessage(ChatMessage message) async {
    _messages.add(message);
    await _saveHistory(_messages);
    emit(ChatHistorySuccess(List.unmodifiable(_messages)));
  }

  Future<void> clearMessages() async {
    _messages.clear();
    await _clearHistory();
    emit(ChatHistorySuccess([]));
  }

  Future<void> loadMessages() async {
    emit(ChatHistoryLoading());
    final saved = await _loadHistory();
    _messages
      ..clear()
      ..addAll(saved);

    emit(ChatHistorySuccess(List.unmodifiable(_messages)));
  }
}
