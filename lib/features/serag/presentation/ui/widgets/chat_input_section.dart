import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/serag_decorations.dart';
import 'package:mishkat_almasabih/core/theming/serag_styles.dart';
import 'package:mishkat_almasabih/features/remaining_questions/presentation/logic/cubit/remaining_questions_cubit.dart';
import 'package:mishkat_almasabih/features/serag/presentation/logic/serag/serag_cubit.dart';
import 'package:mishkat_almasabih/features/serag/presentation/logic/serag/serag_state.dart';
import 'package:mishkat_almasabih/features/serag/presentation/logic/chat_history/chat_history_cubit.dart';
import 'package:mishkat_almasabih/features/serag/domain/entities/chat_message.dart';
import 'package:mishkat_almasabih/features/serag/domain/entities/serag_hadith_context.dart';

class ChatInputSection extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback scrollToBottom;
  final SeragHadithContext model;

  const ChatInputSection({
    super.key,
    required this.controller,
    required this.scrollToBottom,
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: SeragDecorations.inputSectionContainer(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BlocConsumer<SeragCubit, SeragState>(
            listener: (context, state) {
              if (state is SeragSuccess) {
                context.read<ChatHistoryCubit>().addMessage(
                  ChatMessage(role: "assistant", content: state.response),
                );
                scrollToBottom();
              }
              if (state is SeragFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errMessage),
                    backgroundColor: SeragDecorations.errorSnackbarBackground,
                    behavior: SeragDecorations.snackbarBehavior,
                    shape: SeragDecorations.snackbarShape,
                    margin: SeragDecorations.snackbarMargin,
                  ),
                );
              }
            },
            builder: (context, seragState) {
              return Container(
                padding: SeragDecorations.inputSectionPadding(context),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: SeragDecorations.textFieldContainer(),
                        child: TextField(
                          controller: controller,
                          minLines: 1,
                          maxLines: 4,
                          style: SeragTextStyles.inputFieldText,
                          decoration: InputDecoration(
                            hintText: "اكتب رسالتك هنا...",
                            hintStyle: SeragTextStyles.inputHintText,
                            border: SeragDecorations.textFieldBorder,
                            contentPadding: SeragDecorations.textFieldPadding,
                          ),
                          onTap: scrollToBottom,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Container(
                      decoration: SeragDecorations.sendButtonGradient(),
                      child: Material(
                        color: Colors.transparent,
                        child: GestureDetector(
                          onTap:
                              seragState is SeragLoading
                                  ? null
                                  : () {
                                    context
                                                .read<RemainingQuestionsCubit>()
                                                .remaining ==
                                            0
                                        ? ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            behavior:
                                                SeragDecorations
                                                    .snackbarBehavior,
                                            backgroundColor:
                                                SeragDecorations
                                                    .limitExceededSnackbarBackground,

                                            content: Text(
                                              "عذراً، لقد استنفذت الحد اليومي.\nيرجى المحاولة مرة أخرى غداً.",
                                              style:
                                                  SeragTextStyles
                                                      .limitExceededSnackbar,
                                            ),
                                          ),
                                        )
                                        : _handleSendMessage(context);
                                  },
                          child: SizedBox(
                            width: SeragDecorations.sendButtonSize,
                            height: SeragDecorations.sendButtonHeight,
                            child: Center(
                              child:
                                  seragState is SeragLoading
                                      ? SizedBox(
                                        width:
                                            SeragDecorations
                                                .loadingIndicatorSize,
                                        height:
                                            SeragDecorations
                                                .loadingIndicatorHeight,
                                        child: CircularProgressIndicator(
                                          color:
                                              SeragDecorations
                                                  .loadingIndicatorColor,
                                          strokeWidth:
                                              SeragDecorations
                                                  .loadingIndicatorStrokeWidth,
                                        ),
                                      )
                                      : Icon(
                                        Icons.send_rounded,
                                        color:
                                            SeragDecorations
                                                .sendButtonIconColor,
                                        size:
                                            SeragTextStyles.sendButtonIconSize,
                                      ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          Divider(
            endIndent: SeragDecorations.dividerEndIndent,
            indent: SeragDecorations.dividerIndent,
            color: SeragDecorations.dividerColor,
          ),

          Container(
            width: double.infinity,
            padding: SeragDecorations.warningDisclaimerPadding,
            child: Text(
              " سراج قد يقدم معلومات غير دقيقة، يُفضل الرجوع إلى المصادر الأصلية للتأكد.",
              textAlign: TextAlign.center,
              style: SeragTextStyles.warningDisclaimer,
            ),
          ),
        ],
      ),
    );
  }

  void _handleSendMessage(BuildContext context) {
    final text = controller.text.trim();
    if (text.isNotEmpty) {
      HapticFeedback.lightImpact();
      context.read<RemainingQuestionsCubit>().emitRemainingQuestions();
      context.read<ChatHistoryCubit>().addMessage(
        ChatMessage(role: "user", content: text),
      );
      context.read<SeragCubit>().sendMessage(hadith: model, content: text);
      controller.clear();
      scrollToBottom();
    }
  }
}
