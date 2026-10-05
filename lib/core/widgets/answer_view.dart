import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/answer_blocks.dart';
import 'package:mishkat_almasabih/core/helpers/arabic_digits.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';

/// Typesets an AI answer: section titles, paragraphs, numbered points in a
/// card, and quoted hadiths in Amiri.
class AnswerView extends StatelessWidget {
  const AnswerView({
    super.key,
    required this.text,
    this.accentFirstHeading = false,
    this.fallbackHeading,
  });

  final String text;

  /// Title to lead with when the answer does not start with one.
  final String? fallbackHeading;

  /// Draws the first heading in gold with a sparkle, as the answer's lead.
  final bool accentFirstHeading;

  @override
  Widget build(BuildContext context) {
    final parsed = parseAnswer(text);
    final fallback = fallbackHeading;
    final blocks = [
      if (fallback != null && parsed.firstOrNull is! AnswerHeading)
        AnswerHeading(fallback),
      ...parsed,
    ];
    final firstHeading = blocks.indexWhere((block) => block is AnswerHeading);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < blocks.length; i++) ...[
          if (i > 0)
            SizedBox(height: blocks[i] is AnswerHeading ? 16.h : 10.h),
          switch (blocks[i]) {
            AnswerHeading(:final text) => _Heading(
              text: text,
              accent: accentFirstHeading && i == firstHeading,
            ),
            AnswerParagraph(:final text) => _RichLine(
              text,
              style: TextStyles.explanationBody.copyWith(fontWeight: FontWeight.w500),
            ),
            AnswerList(:final items, :final ordered) => NumberedListCard(
              items: items,
              ordered: ordered,
            ),
            AnswerQuote(:final text) => _Quote(text: text),
          },
        ],
      ],
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading({required this.text, required this.accent});

  final String text;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final style = TextStyles.titleMedium.copyWith(
      fontWeight: FontWeight.w800,
      color: accent ? ColorsManager.primaryGold : ColorsManager.primaryText,
    );
    return Semantics(
      header: true,
      child: Row(
        children: [
          if (accent) ...[
            Icon(Icons.auto_awesome_rounded, size: 19.r, color: style.color),
            SizedBox(width: 6.w),
          ],
          Expanded(child: Text(text, style: style)),
        ],
      ),
    );
  }
}

/// Points in a bordered card, numbered or bulleted.
class NumberedListCard extends StatelessWidget {
  const NumberedListCard({
    super.key,required this.items, required this.ordered});

  final List<String> items;
  final bool ordered;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: ColorsManager.cardBackground,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: ColorsManager.border),
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) Divider(height: 1, color: ColorsManager.lightGray),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24.r,
                    height: 24.r,
                    margin: EdgeInsets.only(top: 2.h),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: ColorsManager.primarySoft,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child:
                        ordered
                            ? Text(
                              toArabicDigits('${i + 1}'),
                              style: TextStyles.chipLabel.copyWith(
                                fontWeight: FontWeight.w800,
                                color: ColorsManager.purpleText,
                              ),
                            )
                            : Container(
                              width: 6.r,
                              height: 6.r,
                              decoration: BoxDecoration(
                                color: ColorsManager.purpleText,
                                shape: BoxShape.circle,
                              ),
                            ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: _RichLine(
                      items[i],
                      style: TextStyles.explanationBody.copyWith(
                        fontSize: 14.sp,
                        height: 1.8,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Quote extends StatelessWidget {
  const _Quote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: ColorsManager.cardBackground,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: ColorsManager.border),
      ),
      child: Text(
        text,
        style: TextStyles.readingMedium.copyWith(
          fontSize: 17.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// A line of text with **bold** runs rendered in bold.
class _RichLine extends StatelessWidget {
  const _RichLine(this.text, {required this.style});

  final String text;
  final TextStyle style;

  static final _bold = RegExp(r'\*\*(.+?)\*\*');

  @override
  Widget build(BuildContext context) {
    final spans = <TextSpan>[];
    var start = 0;
    for (final match in _bold.allMatches(text)) {
      if (match.start > start) {
        spans.add(TextSpan(text: text.substring(start, match.start)));
      }
      spans.add(
        TextSpan(
          text: match.group(1),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      );
      start = match.end;
    }
    if (start < text.length) spans.add(TextSpan(text: text.substring(start)));
    return Text.rich(TextSpan(style: style, children: spans));
  }
}
