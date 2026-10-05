import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/domain/entities/explained_hadith.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/core/widgets/answer_view.dart';
import 'package:mishkat_almasabih/core/widgets/segmented_tabs.dart';

enum _Section { explanation, lessons, words }

/// The explanation, lessons and word meanings of a hadith, one at a time.
/// Sections the hadith has no content for are left out.
class ExplanationTabs extends StatefulWidget {
  const ExplanationTabs({super.key, required this.hadith});

  final ExplainedHadith hadith;

  @override
  State<ExplanationTabs> createState() => _ExplanationTabsState();
}

class _ExplanationTabsState extends State<ExplanationTabs> {
  int _index = 0;

  List<_Section> get _sections {
    final hadith = widget.hadith;
    return [
      if ((hadith.explanation ?? '').trim().isNotEmpty) _Section.explanation,
      if ((hadith.hints ?? const []).any((h) => h.trim().isNotEmpty))
        _Section.lessons,
      if ((hadith.wordsMeanings ?? const []).any(
        (m) => (m.word ?? '').trim().isNotEmpty,
      ))
        _Section.words,
    ];
  }

  static String _label(_Section section) => switch (section) {
    _Section.explanation => 'الشرح',
    _Section.lessons => 'الفوائد',
    _Section.words => 'معاني الكلمات',
  };

  @override
  Widget build(BuildContext context) {
    final sections = _sections;
    if (sections.isEmpty) return const SizedBox.shrink();
    final index = _index.clamp(0, sections.length - 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (sections.length > 1) ...[
          SegmentedTabs(
            labels: [for (final section in sections) _label(section)],
            selectedIndex: index,
            onChanged: (value) => setState(() => _index = value),
          ),
          SizedBox(height: 14.h),
        ] else
          Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Text(
              _label(sections.first),
              style: TextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: KeyedSubtree(
            key: ValueKey(sections[index]),
            child: _content(sections[index]),
          ),
        ),
      ],
    );
  }

  Widget _content(_Section section) {
    final hadith = widget.hadith;
    return switch (section) {
      _Section.explanation => SelectableText(
        hadith.explanation!.trim(),
        style: TextStyles.explanationBody.copyWith(
          fontWeight: FontWeight.w500,
          height: 2,
        ),
      ),
      _Section.lessons => NumberedListCard(
        items: [
          for (final hint in hadith.hints!)
            if (hint.trim().isNotEmpty) hint.trim(),
        ],
        ordered: true,
      ),
      _Section.words => Wrap(
        spacing: 8.w,
        runSpacing: 8.h,
        children: [
          for (final meaning in hadith.wordsMeanings!)
            if ((meaning.word ?? '').trim().isNotEmpty)
              _WordMeaning(meaning: meaning),
        ],
      ),
    };
  }
}

class _WordMeaning extends StatelessWidget {
  const _WordMeaning({required this.meaning});

  final HadithWordMeaning meaning;

  @override
  Widget build(BuildContext context) {
    final explanation = meaning.meaning?.trim();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: ColorsManager.cardBackground,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: ColorsManager.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            meaning.word!.trim(),
            style: TextStyles.readingMedium.copyWith(
              fontSize: 16.sp,
              height: 1.6,
              fontWeight: FontWeight.w700,
              color: ColorsManager.purpleText,
            ),
          ),
          if (explanation != null && explanation.isNotEmpty)
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 280.w),
              child: Text(explanation, style: TextStyles.caption.copyWith(height: 1.6)),
            ),
        ],
      ),
    );
  }
}
