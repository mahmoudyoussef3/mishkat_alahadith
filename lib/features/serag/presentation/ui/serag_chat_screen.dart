import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/arabic_digits.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/core/widgets/app_icon_button.dart';
import 'package:mishkat_almasabih/core/widgets/detail_header.dart';
import 'package:mishkat_almasabih/core/widgets/snackbars.dart';
import 'package:mishkat_almasabih/features/remaining_questions/presentation/logic/cubit/remaining_questions_cubit.dart';
import 'package:mishkat_almasabih/features/serag/domain/entities/chat_message.dart';
import 'package:mishkat_almasabih/features/serag/presentation/logic/chat_history/chat_history_cubit.dart';
import 'package:mishkat_almasabih/features/serag/presentation/logic/chat_history/chat_history_state.dart';
import 'package:mishkat_almasabih/features/serag/presentation/logic/serag/serag_cubit.dart';
import 'package:mishkat_almasabih/features/serag/presentation/logic/serag/serag_state.dart';
import 'package:mishkat_almasabih/features/serag/presentation/ui/open_siraj.dart';
import 'package:mishkat_almasabih/features/serag/presentation/ui/widgets/chat_message_bubble.dart';
import 'package:mishkat_almasabih/features/serag/presentation/ui/widgets/siraj_composer.dart';
import 'package:mishkat_almasabih/features/serag/presentation/ui/widgets/siraj_welcome.dart';

/// Conversation with Siraj about one hadith. Opens on a greeting with
/// starter questions, or straight into [SeragChatArgs.question].
class SeragChatScreen extends StatefulWidget {
  const SeragChatScreen({super.key, required this.args});

  final SeragChatArgs args;

  @override
  State<SeragChatScreen> createState() => _SeragChatScreenState();
}

class _SeragChatScreenState extends State<SeragChatScreen> {
  final _scrollController = ScrollController();

  static const _followUps = [
    'وضّح أكثر بمثال',
    'لخّص الفوائد في نقاط',
    'اذكر أحاديث مشابهة',
  ];

  @override
  void initState() {
    super.initState();
    final question = widget.args.question;
    if (question != null && question.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _send(question));
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool get _outOfQuestions {
    final remaining = context.read<RemainingQuestionsCubit>();
    return remaining.state is RemainingQuestionsSuccess &&
        remaining.remaining <= 0;
  }

  Future<void> _send(String question) async {
    if (!mounted) return;
    if (_outOfQuestions) {
      showErrorSnackbar(context, 'استنفدت أسئلة اليوم، تتجدد غداً');
      return;
    }
    final history = context.read<ChatHistoryCubit>();
    final serag = context.read<SeragCubit>();
    await history.addMessage(ChatMessage(role: 'user', content: question));
    _scrollToEnd();
    await serag.sendMessage(
      hadith: widget.args.hadith,
      conversation: history.messages,
    );
  }

  /// Asks again about the last question after a failed answer.
  void _retry() => context.read<SeragCubit>().sendMessage(
    hadith: widget.args.hadith,
    conversation: context.read<ChatHistoryCubit>().messages,
  );

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocListener<SeragCubit, SeragState>(
        listener: (context, state) async {
          if (state is SeragSuccess) {
            await context.read<ChatHistoryCubit>().addMessage(
              ChatMessage(role: 'assistant', content: state.response),
            );
            if (!context.mounted) return;
            context.read<RemainingQuestionsCubit>().emitRemainingQuestions();
            _scrollToEnd();
          } else if (state is SeragLoading) {
            _scrollToEnd();
          }
        },
        child: Scaffold(
          backgroundColor: ColorsManager.secondaryBackground,
          body: SafeArea(
            bottom: false,
            child: BlocBuilder<ChatHistoryCubit, ChatHistoryState>(
              builder: (context, history) {
                final messages =
                    history is ChatHistorySuccess
                        ? history.messages
                        : const <ChatMessage>[];
                return Column(
                  children: [
                    DetailHeader(
                      title: 'سراج',
                      subtitle: widget.args.title ?? 'مساعد الحديث',
                      actions: [
                        const _RemainingBadge(),
                        AppIconButton(
                          tooltip: 'محادثة جديدة',
                          icon: Icons.edit_square,
                          onPressed:
                              messages.isEmpty
                                  ? null
                                  : context.read<ChatHistoryCubit>().clearMessages,
                        ),
                      ],
                    ),
                    Expanded(
                      child:
                          messages.isEmpty
                              ? SirajWelcome(
                                hadithText: widget.args.hadith.hadeeth,
                                onAsk: _send,
                              )
                              : _Conversation(
                                messages: messages,
                                controller: _scrollController,
                                onRetry: _retry,
                              ),
                    ),
                    BlocBuilder<RemainingQuestionsCubit, RemainingQuestionsState>(
                      builder: (context, remaining) {
                        if (remaining is RemainingQuestionsSuccess &&
                            remaining.remainingQuestions.remaining <= 0) {
                          return const _OutOfQuestions();
                        }
                        return BlocBuilder<SeragCubit, SeragState>(
                          builder:
                              (context, serag) => SirajComposer(
                                busy: serag is SeragLoading,
                                suggestions:
                                    messages.isEmpty ? const [] : _followUps,
                                footnote:
                                    'قد يخطئ سراج؛ تحقّق دائماً من المصادر الأصلية.',
                                onSend: _send,
                              ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _Conversation extends StatelessWidget {
  const _Conversation({
    required this.messages,
    required this.controller,
    required this.onRetry,
  });

  final List<ChatMessage> messages;
  final ScrollController controller;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SeragCubit, SeragState>(
      builder: (context, serag) {
        final awaitingAnswer = messages.last.role == 'user';
        final tail = switch (serag) {
          SeragLoading() when awaitingAnswer => const SirajTypingIndicator(),
          SeragFailure(:final errMessage) when awaitingAnswer => _AnswerFailed(
            message: errMessage,
            onRetry: onRetry,
          ),
          _ => null,
        };

        return ListView.builder(
          controller: controller,
          padding: EdgeInsets.symmetric(vertical: 12.h),
          itemCount: messages.length + (tail == null ? 0 : 1),
          itemBuilder:
              (context, index) =>
                  index < messages.length
                      ? ChatMessageBubble(message: messages[index])
                      : tail!,
        );
      },
    );
  }
}

class _AnswerFailed extends StatelessWidget {
  const _AnswerFailed({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Container(
        padding: EdgeInsets.fromLTRB(14.w, 10.h, 6.w, 10.h),
        decoration: BoxDecoration(
          color: ColorsManager.errorSoft,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline_rounded, size: 20.r, color: ColorsManager.error),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                message,
                style: TextStyles.caption.copyWith(color: ColorsManager.error),
              ),
            ),
            TextButton(onPressed: onRetry, child: const Text('إعادة المحاولة')),
          ],
        ),
      ),
    );
  }
}

/// Today's remaining questions, e.g. "٩ / ١٠".
class _RemainingBadge extends StatelessWidget {
  const _RemainingBadge();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RemainingQuestionsCubit, RemainingQuestionsState>(
      builder: (context, state) {
        if (state is! RemainingQuestionsSuccess) return const SizedBox.shrink();
        final remaining = state.remainingQuestions.remaining;
        final max = state.remainingQuestions.max;
        final label = max == null ? '$remaining' : '$remaining / $max';
        return Semantics(
          label: 'الأسئلة المتبقية اليوم: $remaining',
          excludeSemantics: true,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            decoration: ShapeDecoration(
              color: ColorsManager.goldSoft,
              shape: const StadiumBorder(),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bolt_rounded, size: 15.r, color: ColorsManager.hadithGood),
                SizedBox(width: 2.w),
                Text(
                  toArabicDigits(label),
                  style: TextStyles.chipLabel.copyWith(color: ColorsManager.hadithGood),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _OutOfQuestions extends StatelessWidget {
  const _OutOfQuestions();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ColorsManager.cardBackground,
        border: Border(top: BorderSide(color: ColorsManager.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Row(
            children: [
              Icon(Icons.hourglass_bottom_rounded, color: ColorsManager.primaryGold),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  'استنفدت أسئلة اليوم، وتتجدد غداً بإذن الله.',
                  style: TextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
