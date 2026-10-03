import 'dart:convert';
import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/chat_message.dart';
import '../../domain/repos/chat_history_repo.dart';
import '../mappers/serag_mapper.dart';
import '../models/serag_request_model.dart';

class ChatHistoryRepoImpl implements ChatHistoryRepo {
  static const String _key = "serag_messages";

  @override
  Future<List<ChatMessage>> loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data == null) return [];

    try {
      final decoded = jsonDecode(data) as List<dynamic>;
      return decoded
          .map((e) => Message.fromJson(e as Map<String, dynamic>).toEntity())
          .toList();
    } catch (error) {
      log('Unreadable Serag chat history: $error');
      return [];
    }
  }

  @override
  Future<void> saveMessages(List<ChatMessage> messages) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = messages.map((m) => m.toModel().toJson()).toList();
      await prefs.setString(_key, jsonEncode(jsonList));
    } catch (error) {
      log('Unable to save Serag chat history: $error');
    }
  }

  @override
  Future<void> clearMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } catch (error) {
      log('Unable to clear Serag chat history: $error');
    }
  }
}
