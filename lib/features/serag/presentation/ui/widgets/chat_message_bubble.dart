import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/core/widgets/answer_view.dart';
import 'package:mishkat_almasabih/features/serag/presentation/ui/widgets/siraj_mark.dart';
import 'package:mishkat_almasabih/features/serag/domain/entities/chat_message.dart';
import 'package:share_plus/share_plus.dart';

/// One turn of the conversation: the user's question as a brand bubble,
/// or Siraj's typeset answer beside its mark, with copy and share.
class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({super.key, required this.message});

  final ChatMessage message;

  bool get _fromUser => message.role == 'user';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: _fromUser ? _Question(text: message.content) : _Answer(text: message.content),
    );
  }
}

class _Question extends StatelessWidget {
  const _Question({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final radius = Radius.circular(18.r);
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.8,
        ),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: ColorsManager.primaryPurple,
            borderRadius: BorderRadiusDirectional.only(
              topStart: radius,
              topEnd: radius,
              bottomEnd: radius,
              bottomStart: Radius.circular(6.r),
            ),
          ),
          child: SelectableText(
            text,
            style: TextStyles.bodyMedium.copyWith(
              fontSize: 15.sp,
              height: 1.7,
              fontWeight: FontWeight.w500,
              color: ColorsManager.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _Answer extends StatelessWidget {
  const _Answer({required this.text});

  final String text;

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('تم نسخ الإجابة')));
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SirajMark(size: 32.r, onLight: true),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectionArea(child: AnswerView(text: text)),
              SizedBox(height: 4.h),
              Row(
                children: [
                  _AnswerAction(
                    tooltip: 'نسخ',
                    icon: Icons.content_copy_rounded,
                    onTap: () => _copy(context),
                  ),
                  _AnswerAction(
                    tooltip: 'مشاركة',
                    icon: Icons.share_rounded,
                    onTap:
                        () => SharePlus.instance.share(
                          ShareParams(text: '$text\n\n— سراج · مشكاة الأحاديث'),
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AnswerAction extends StatelessWidget {
  const _AnswerAction({
    required this.tooltip,
    required this.icon,
    required this.onTap,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onTap,
      visualDensity: VisualDensity.compact,
      icon: Icon(icon, size: 19.r, color: ColorsManager.secondaryText),
    );
  }
}

/// Shown while Siraj prepares an answer.
class SirajTypingIndicator extends StatefulWidget {
  const SirajTypingIndicator({super.key});

  @override
  State<SirajTypingIndicator> createState() => _SirajTypingIndicatorState();
}

class _SirajTypingIndicatorState extends State<SirajTypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Semantics(
        liveRegion: true,
        label: 'سراج يكتب الإجابة',
        excludeSemantics: true,
        child: Row(
          children: [
            SirajMark(size: 32.r, onLight: true),
            SizedBox(width: 10.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: ColorsManager.cardBackground,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: ColorsManager.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < 3; i++) ...[
                    FadeTransition(
                      opacity: TweenSequence<double>([
                        TweenSequenceItem(tween: Tween(begin: 0.25, end: 1), weight: 1),
                        TweenSequenceItem(tween: Tween(begin: 1, end: 0.25), weight: 1),
                      ]).animate(
                        CurvedAnimation(
                          parent: _controller,
                          curve: Interval(i * 0.2, 0.6 + i * 0.2),
                        ),
                      ),
                      child: Container(
                        width: 6.r,
                        height: 6.r,
                        decoration: BoxDecoration(
                          color: ColorsManager.primaryPurple,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    SizedBox(width: i < 2 ? 4.w : 8.w),
                  ],
                  Text('يبحث في المصادر…', style: TextStyles.caption),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
