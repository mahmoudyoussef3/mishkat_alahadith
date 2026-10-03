import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/features/serag/logic/chat_history/chat_history_cubit.dart';
import 'package:mishkat_almasabih/features/serag/logic/chat_history/chat_history_state.dart';
import 'chat_message_bubble.dart';
import 'empty_chat_state.dart';

class ChatMessagesList extends StatelessWidget {
  const ChatMessagesList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatHistoryCubit, ChatHistoryState>(
      builder: (context, historyState) {
        if (historyState is ChatHistoryLoading) {
          return const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (historyState is ChatHistorySuccess &&
            historyState.messages.isNotEmpty) {
          final messages = historyState.messages;

          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final msg = messages[index];
                return ChatMessageBubble(message: msg);
              },
              childCount: messages.length,
            ),
          );
        }

        return const EmptyChatState();
      },
    );
  }
}