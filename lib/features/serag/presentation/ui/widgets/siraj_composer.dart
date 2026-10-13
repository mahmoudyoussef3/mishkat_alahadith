import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';

/// Bottom bar for asking Siraj: tappable suggested questions, a growing
/// text field and a send button that shows progress while Siraj answers.
class SirajComposer extends StatefulWidget {
  const SirajComposer({
    super.key,
    required this.onSend,
    this.suggestions = const [],
    this.hint = 'اكتب سؤالك…',
    this.busy = false,
    this.footnote,
  });

  final ValueChanged<String> onSend;
  final List<String> suggestions;
  final String hint;

  /// True while an answer is on its way; sending is paused.
  final bool busy;

  /// Small print under the field, such as a reliability note.
  final String? footnote;

  @override
  State<SirajComposer> createState() => _SirajComposerState();
}

class _SirajComposerState extends State<SirajComposer> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send([String? text]) {
    final question = (text ?? _controller.text).trim();
    if (question.isEmpty || widget.busy) return;
    HapticFeedback.lightImpact();
    widget.onSend(question);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final footnote = widget.footnote;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: ColorsManager.cardBackground,
        border: Border(top: BorderSide(color: ColorsManager.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 10.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.suggestions.isNotEmpty) ...[
                SizedBox(
                  height: 32.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.suggestions.length,
                    separatorBuilder: (_, _) => SizedBox(width: 6.w),
                    itemBuilder: (context, index) {
                      final suggestion = widget.suggestions[index];
                      return ActionChip(
                        label: Text(suggestion),
                        onPressed: widget.busy ? null : () => _send(suggestion),
                        backgroundColor: ColorsManager.primarySoft,
                        labelStyle: TextStyles.chipLabel.copyWith(
                          fontWeight: FontWeight.w600,
                          color: ColorsManager.purpleText,
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      );
                    },
                  ),
                ),
                SizedBox(height: 10.h),
              ],
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      style: TextStyles.bodyMedium.copyWith(fontSize: 15.sp),
                      decoration: InputDecoration(
                        hintText: widget.hint,
                        filled: true,
                        fillColor: ColorsManager.secondaryBackground,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 14.h,
                        ),
                        border: _border(ColorsManager.border),
                        enabledBorder: _border(ColorsManager.border),
                        focusedBorder: _border(ColorsManager.primaryPurple),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _controller,
                    builder: (context, value, _) {
                      final canSend =
                          value.text.trim().isNotEmpty && !widget.busy;
                      return SizedBox.square(
                        dimension: 50.r,
                        child: FilledButton(
                          onPressed: canSend ? _send : null,
                          style: FilledButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.square(50.r),
                            disabledBackgroundColor: ColorsManager.mediumGray,
                            disabledForegroundColor: ColorsManager.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.r),
                            ),
                          ),
                          child:
                              widget.busy
                                  ? SizedBox.square(
                                    dimension: 20.r,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: ColorsManager.purpleText,
                                    ),
                                  )
                                  : Tooltip(
                                    message: 'إرسال',
                                    child: Icon(Icons.send_rounded, size: 21.r),
                                  ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              if (footnote != null) ...[
                SizedBox(height: 8.h),
                Text(
                  footnote,
                  textAlign: TextAlign.center,
                  style: TextStyles.labelSmall.copyWith(color: ColorsManager.gray),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(18.r),
    borderSide: BorderSide(color: color),
  );
}
