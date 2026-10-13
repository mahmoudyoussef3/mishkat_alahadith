import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/domain/entities/explained_hadith.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/core/widgets/answer_view.dart';
import 'package:mishkat_almasabih/core/widgets/segmented_tabs.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/entities/speech_track.dart';
import 'package:mishkat_almasabih/features/read_aloud/presentation/logic/read_aloud_cubit.dart';
import 'package:mishkat_almasabih/features/read_aloud/presentation/ui/read_aloud_host.dart';
import 'package:mishkat_almasabih/features/read_aloud/presentation/ui/read_aloud_text.dart';

enum _Section { explanation, lessons, words }

/// The explanation, lessons and word meanings of a hadith, one at a time.
/// Sections the hadith has no content for are left out. While the page is
/// read aloud, the tab follows the section being read.
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

  static _Section? _sectionOf(SpeechPart? part) => switch (part) {
    SpeechPart.explanation => _Section.explanation,
    SpeechPart.lesson => _Section.lessons,
    SpeechPart.wordMeaning => _Section.words,
    _ => null,
  };

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
    final owner = ReadAloudHost.maybeOwnerOf(context);

    return BlocListener<ReadAloudCubit, ReadAloudState>(
      listenWhen:
          (previous, current) =>
              current.ownedBy(owner) &&
              _sectionOf(current.segment?.part) !=
                  _sectionOf(previous.segment?.part),
      listener: (context, state) {
        final section = _sectionOf(state.segment?.part);
        final target = section == null ? -1 : sections.indexOf(section);
        if (target >= 0 && target != index) setState(() => _index = target);
      },
      child: Column(
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
                style: TextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w800,
                ),
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
      ),
    );
  }

  Widget _content(_Section section) {
    final hadith = widget.hadith;
    return switch (section) {
      _Section.explanation => SelectionArea(
        child: ReadAloudText(
          hadith.explanation!.trim(),
          part: SpeechPart.explanation,
          scaled: false,
          style: TextStyles.explanationBody.copyWith(
            fontWeight: FontWeight.w500,
            height: 2,
          ),
        ),
      ),
      _Section.lessons => _Lessons(
        items: [
          for (final hint in hadith.hints!)
            if (hint.trim().isNotEmpty) hint.trim(),
        ],
      ),
      _Section.words => _WordMeanings(
        meanings: [
          for (final meaning in hadith.wordsMeanings!)
            if ((meaning.word ?? '').trim().isNotEmpty) meaning,
        ],
      ),
    };
  }
}

/// The lessons, the one being read aloud marked.
class _Lessons extends StatelessWidget {
  const _Lessons({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return NumberedListCard(
      items: items,
      ordered: true,
      highlightedIndex: watchReadAloudItem(context, SpeechPart.lesson),
    );
  }
}

/// The word meanings, the one being read aloud marked.
class _WordMeanings extends StatelessWidget {
  const _WordMeanings({required this.meanings});

  final List<HadithWordMeaning> meanings;

  @override
  Widget build(BuildContext context) {
    final reading = watchReadAloudItem(context, SpeechPart.wordMeaning);
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: [
        for (var i = 0; i < meanings.length; i++)
          _WordMeaning(meaning: meanings[i], active: i == reading),
      ],
    );
  }
}

class _WordMeaning extends StatelessWidget {
  const _WordMeaning({required this.meaning, this.active = false});

  final HadithWordMeaning meaning;

  /// Being read aloud.
  final bool active;

  @override
  Widget build(BuildContext context) {
    final explanation = meaning.meaning?.trim();
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: active ? ColorsManager.goldSoft : ColorsManager.cardBackground,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: active ? ColorsManager.goldBright : ColorsManager.border,
        ),
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
              child: Text(
                explanation,
                style: TextStyles.caption.copyWith(height: 1.6),
              ),
            ),
        ],
      ),
    );
  }
}
