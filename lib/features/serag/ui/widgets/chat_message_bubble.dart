import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/serag_decorations.dart';
import 'package:mishkat_almasabih/core/theming/serag_styles.dart';
import 'package:mishkat_almasabih/features/serag/data/models/serag_request_model.dart';

class ChatMessageBubble extends StatelessWidget {
  final Message message;

  const ChatMessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == "user";

    return Padding(
      padding: SeragDecorations.messageBubblePadding,
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isUser) ...[
            SizedBox(width: 8.w),
            CircleAvatar(
              radius: SeragDecorations.userAvatarRadius,
              backgroundColor: SeragDecorations.userAvatarBackground,
              child: Icon(
                Icons.person,
                color: SeragDecorations.userAvatarIconColor,
                size: SeragDecorations.userAvatarIconSize,
              ),
            ),
          ],
          SizedBox(width: 8.w),
          Flexible(
            child: GestureDetector(
              onLongPress: () {
                HapticFeedback.mediumImpact();
                Clipboard.setData(ClipboardData(text: message.content));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text("تم نسخ الرسالة"),
                    backgroundColor: SeragDecorations.snackbarCopyBackground,
                    behavior: SeragDecorations.snackbarBehavior,
                    shape: SeragDecorations.snackbarShape,
                    margin: SeragDecorations.snackbarMargin,
                  ),
                );
              },
              child: Container(
                padding: SeragDecorations.messageBubbleInternalPadding,
                decoration:
                    isUser
                        ? SeragDecorations.userMessageBubble()
                        : SeragDecorations.assistantMessageBubble(),
                child: Text(
                  message.content,
                  style:
                      isUser
                          ? SeragTextStyles.userMessage
                          : SeragTextStyles.assistantMessage,
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          if (!isUser) ...[
            CircleAvatar(
              radius: SeragDecorations.assistantAvatarRadius,
              backgroundImage: AssetImage(SeragDecorations.assistantAvatarPath),
            ),
          ],
        ],
      ),
    );
  }
}
