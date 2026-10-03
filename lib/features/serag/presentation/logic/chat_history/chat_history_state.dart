import 'package:flutter/material.dart';
import 'package:mishkat_almasabih/features/serag/domain/entities/chat_message.dart';

@immutable
sealed class ChatHistoryState {}

final class ChatHistoryInitial extends ChatHistoryState {}

final class ChatHistoryLoading extends ChatHistoryState {}

final class ChatHistorySuccess extends ChatHistoryState {
  final List<ChatMessage> messages;
  ChatHistorySuccess(this.messages);
}

final class ChatHistoryFailure extends ChatHistoryState {
  final String errMessage;
  ChatHistoryFailure(this.errMessage);
}
