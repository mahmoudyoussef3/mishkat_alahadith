import 'package:flutter/material.dart';
import 'package:mishkat_almasabih/features/serag/data/models/serag_request_model.dart';
import 'package:mishkat_almasabih/features/serag/data/models/serag_response_model.dart';

@immutable
sealed class ChatHistoryState {}

final class ChatHistoryInitial extends ChatHistoryState {}

final class ChatHistoryLoading extends ChatHistoryState {}

final class ChatHistorySuccess extends ChatHistoryState {
  final List<Message> messages;
  ChatHistorySuccess(this.messages);
}

final class ChatHistoryFailure extends ChatHistoryState {
  final String errMessage;
  ChatHistoryFailure(this.errMessage);
}
