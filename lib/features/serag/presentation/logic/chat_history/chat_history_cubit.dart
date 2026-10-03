import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mishkat_almasabih/features/serag/data/models/serag_request_model.dart';
import 'package:mishkat_almasabih/features/serag/logic/chat_history/chat_history_state.dart';

class ChatHistoryCubit extends Cubit<ChatHistoryState> {
  final List<Message> _messages = [];

  ChatHistoryCubit() : super(ChatHistoryInitial()) {
    loadMessages();
  }

  List<Message> get messages => List.unmodifiable(_messages);

  Future<void> addMessage(Message message) async {
    _messages.add(message);
    await _saveMessages();
    emit(ChatHistorySuccess(List.unmodifiable(_messages)));
  }

  Future<void> clearMessages() async {
    _messages.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("serag_messages");
    emit(ChatHistorySuccess([]));
  }

  Future<void> loadMessages() async {
    emit(ChatHistoryLoading());
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString("serag_messages");

    if (data != null) {
      final decoded = jsonDecode(data) as List<dynamic>;
      _messages
        ..clear()
        ..addAll(decoded.map((e) => Message.fromJson(e)));
    }

    emit(ChatHistorySuccess(List.unmodifiable(_messages)));
  }

  Future<void> _saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _messages.map((m) => m.toJson()).toList();
    await prefs.setString("serag_messages", jsonEncode(jsonList));
  }
}
