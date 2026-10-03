import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/features/serag/domain/entities/chat_message.dart';
import 'package:mishkat_almasabih/features/serag/domain/repos/chat_history_repo.dart';
import 'package:mishkat_almasabih/features/serag/domain/usecases/clear_chat_history_use_case.dart';
import 'package:mishkat_almasabih/features/serag/domain/usecases/load_chat_history_use_case.dart';
import 'package:mishkat_almasabih/features/serag/domain/usecases/save_chat_history_use_case.dart';
import 'package:mishkat_almasabih/features/serag/presentation/logic/chat_history/chat_history_cubit.dart';

/// Load completes only when [releaseLoad] is called, so the test controls the
/// interleaving of load and clear.
class _SlowChatHistoryRepo implements ChatHistoryRepo {
  final Completer<void> releaseLoad = Completer();
  List<ChatMessage> stored = const [
    ChatMessage(role: 'user', content: 'سؤال قديم'),
  ];

  @override
  Future<List<ChatMessage>> loadMessages() async {
    final snapshot = stored; // read first, like prefs.getString
    await releaseLoad.future;
    return snapshot;
  }

  @override
  Future<void> saveMessages(List<ChatMessage> messages) async =>
      stored = List.of(messages);

  @override
  Future<void> clearMessages() async => stored = const [];
}

void main() {
  test('a fresh conversation stays empty after clearing (no stale load wins)', () async {
    final repo = _SlowChatHistoryRepo();
    final cubit = ChatHistoryCubit(
      LoadChatHistoryUseCase(repo),
      SaveChatHistoryUseCase(repo),
      ClearChatHistoryUseCase(repo),
    );

    // The router opens Serag with ..clearMessages().
    await cubit.clearMessages();
    repo.releaseLoad.complete();
    await Future<void>.delayed(Duration.zero);

    await cubit.addMessage(const ChatMessage(role: 'user', content: 'سؤال جديد'));

    expect(cubit.messages.map((m) => m.content), ['سؤال جديد']);
    await cubit.close();
  });
}
