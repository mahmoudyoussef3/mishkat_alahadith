import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/di/dependency_injection.dart';
import 'package:mishkat_almasabih/core/theming/quran_styles.dart';
import 'package:mishkat_almasabih/core/widgets/state_message.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/mushaf_reader_settings.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_flowing_page.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_surah.dart';
import 'package:mishkat_almasabih/features/quran/presentation/logic/flowing_page/flowing_page_cubit.dart';
import 'package:mishkat_almasabih/features/quran/presentation/logic/mushaf_reader/mushaf_reader_cubit.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/helpers/flowing_text.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/helpers/quran_ui_helpers.dart';
import 'package:mushaf_text/mushaf_text.dart';

typedef _FlowView =
    ({
      bool tajweed,
      QuranFontScale fontScale,
      String? focusRuleKey,
      int focusIndex,
      int? selectedAyahId,
    });

/// One mushaf page as running text at the reader's chosen size.
///
/// It carries the same ayahs as the printed page and answers taps the same
/// way, so the bars, sheets and bookmarks around it work in either layout.
class FlowingPageItem extends StatelessWidget {
  final int page;
  final MushafColors colors;
  final ValueChanged<int> onAyahTap;
  final ValueChanged<TajweedHit> onTajweedTap;

  const FlowingPageItem({
    super.key,
    required this.page,
    required this.colors,
    required this.onAyahTap,
    required this.onTajweedTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              getIt<FlowingPageCubit>()..load(
                page,
                includeNaturalMadd: _naturalMadd(
                  context.read<MushafReaderCubit>().state,
                ),
              ),
      // The natural madd changes which rules the text carries, so the page
      // is loaded again — in place, keeping where the reader had scrolled to.
      child: BlocListener<MushafReaderCubit, MushafReaderState>(
        listenWhen:
            (previous, current) =>
                _naturalMadd(previous) != _naturalMadd(current),
        listener:
            (context, state) => context.read<FlowingPageCubit>().load(
              page,
              includeNaturalMadd: _naturalMadd(state),
            ),
        child: _FlowingPageBody(
          page: page,
          colors: colors,
          onAyahTap: onAyahTap,
          onTajweedTap: onTajweedTap,
        ),
      ),
    );
  }
}

bool _naturalMadd(MushafReaderState state) =>
    state is MushafReaderReady && state.settings.naturalMaddEnabled;

class _FlowingPageBody extends StatelessWidget {
  final int page;
  final MushafColors colors;
  final ValueChanged<int> onAyahTap;
  final ValueChanged<TajweedHit> onTajweedTap;

  const _FlowingPageBody({
    required this.page,
    required this.colors,
    required this.onAyahTap,
    required this.onTajweedTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FlowingPageCubit, FlowingPageState>(
      builder:
          (context, state) => switch (state) {
            // The text is bundled and loads in tens of milliseconds, so the
            // bare paper reads better than a spinner that flashes and goes.
            FlowingPageLoading() => const SizedBox.expand(),
            FlowingPageFailure(:final message) => Center(
              child: SingleChildScrollView(
                child: StateMessage.error(
                  message: message,
                  onRetry:
                      () => context.read<FlowingPageCubit>().load(
                        page,
                        includeNaturalMadd: _naturalMadd(
                          context.read<MushafReaderCubit>().state,
                        ),
                      ),
                ),
              ),
            ),
            FlowingPageReady(page: final flowing) => _FlowingPageText(
              page: flowing,
              colors: colors,
              onAyahTap: onAyahTap,
              onTajweedTap: onTajweedTap,
            ),
          },
    );
  }
}

class _FlowingPageText extends StatelessWidget {
  final QuranFlowingPage page;
  final MushafColors colors;
  final ValueChanged<int> onAyahTap;
  final ValueChanged<TajweedHit> onTajweedTap;

  const _FlowingPageText({
    required this.page,
    required this.colors,
    required this.onAyahTap,
    required this.onTajweedTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocSelector<MushafReaderCubit, MushafReaderState, _FlowView>(
      selector: (state) {
        if (state is! MushafReaderReady) {
          return (
            tajweed: false,
            fontScale: QuranFontScale.medium,
            focusRuleKey: null,
            focusIndex: 0,
            selectedAyahId: null,
          );
        }
        final isCurrent = state.page == page.page;
        return (
          tajweed: state.settings.tajweedEnabled,
          fontScale: state.settings.fontScale,
          focusRuleKey:
              isCurrent && state.isFocusing ? state.focusRuleKey : null,
          focusIndex: isCurrent ? state.focusIndex : 0,
          selectedAyahId: isCurrent ? state.selectedAyahId : null,
        );
      },
      builder: (context, view) {
        final fontSize = MediaQuery.textScalerOf(
          context,
        ).scale(quranFontSize(view.fontScale));
        final style = QuranTextStyles.mushafText(
          color: colors.ink,
          size: fontSize,
        );
        final focus = _focus(view);

        return Semantics(
          container: true,
          label: 'صفحة ${toArabicNumerals(page.page)} من المصحف',
          child: SingleChildScrollView(
            // Room at the end for the focus bar that floats over the page.
            padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 96.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final section in page.sections) ...[
                  if (section.opensHere)
                    _SurahTitle(
                      surah: section.surah,
                      fontSize: fontSize,
                      colors: colors,
                    ),
                  if (section.showsBasmala)
                    Text(
                      flowingBasmala,
                      textAlign: TextAlign.center,
                      textScaler: TextScaler.noScaling,
                      style: style,
                    ),
                  _FlowingSectionText(
                    ayahs: section.ayahs,
                    style: style,
                    colors: colors,
                    tajweed: view.tajweed,
                    selectedAyahId: view.selectedAyahId,
                    focus: focus,
                    onAyahTap: onAyahTap,
                    onTajweedTap: onTajweedTap,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  ({FlowingWordRef word, Color color})? _focus(_FlowView view) {
    final key = view.focusRuleKey;
    final rule = key == null ? null : tajweedRuleOf(key);
    if (key == null || rule == null) return null;
    final word = page.focusStop(key, view.focusIndex);
    if (word == null) return null;
    return (
      word: word,
      color: colors.tajweedColor(rule).withValues(alpha: 0.22),
    );
  }
}

/// The ayahs of one surah, as one paragraph that answers taps on its words.
class _FlowingSectionText extends StatefulWidget {
  final List<QuranFlowingAyah> ayahs;
  final TextStyle style;
  final MushafColors colors;
  final bool tajweed;
  final int? selectedAyahId;
  final ({FlowingWordRef word, Color color})? focus;
  final ValueChanged<int> onAyahTap;
  final ValueChanged<TajweedHit> onTajweedTap;

  const _FlowingSectionText({
    required this.ayahs,
    required this.style,
    required this.colors,
    required this.tajweed,
    required this.selectedAyahId,
    required this.focus,
    required this.onAyahTap,
    required this.onTajweedTap,
  });

  @override
  State<_FlowingSectionText> createState() => _FlowingSectionTextState();
}

class _FlowingSectionTextState extends State<_FlowingSectionText> {
  final GlobalKey _textKey = GlobalKey();
  late FlowingRun _run;

  @override
  void initState() {
    super.initState();
    _run = _buildRun();
    if (widget.focus != null || widget.selectedAyahId != null) {
      _revealAfterLayout();
    }
  }

  @override
  void didUpdateWidget(_FlowingSectionText oldWidget) {
    super.didUpdateWidget(oldWidget);
    _run = _buildRun();
    // Only a move matters: the tint also changes with the paper.
    final focusMoved =
        widget.focus != null && widget.focus?.word != oldWidget.focus?.word;
    final selectionMoved =
        widget.selectedAyahId != null &&
        widget.selectedAyahId != oldWidget.selectedAyahId;
    if (focusMoved || selectionMoved) _revealAfterLayout();
  }

  FlowingRun _buildRun() => buildFlowingRun(
    ayahs: widget.ayahs,
    style: widget.style,
    colors: widget.colors,
    tajweed: widget.tajweed,
    selectedAyahId: widget.selectedAyahId,
    focus: widget.focus,
  );

  RenderParagraph? get _paragraph {
    final box = _textKey.currentContext?.findRenderObject();
    return box is RenderParagraph ? box : null;
  }

  /// Once laid out, scrolls the focused word into view, so stepping through
  /// a rule follows it down a page longer than the screen.
  ///
  /// Without a focus, scrolls to the first word of the selected ayah — one
  /// arrived at from search, a bookmark or the index — unless some of the
  /// ayah is already on screen, as it is when the reader tapped it.
  ///
  /// Does nothing when the word is in another section.
  void _revealAfterLayout() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final paragraph = _paragraph;
      if (!mounted || paragraph == null) return;
      final focus = widget.focus;
      final selected = widget.selectedAyahId;
      final FlowingWord? word;
      if (focus != null) {
        word = _run.find(focus.word);
      } else if (selected != null && !_isOnScreen(paragraph, selected)) {
        word = _run.firstWordOf(selected);
      } else {
        word = null;
      }
      if (word == null) return;
      final boxes = paragraph.getBoxesForSelection(
        TextSelection(baseOffset: word.start, extentOffset: word.end),
      );
      if (boxes.isEmpty) return;
      // Room above and below only: wider than the page, the rect would
      // scroll the page view sideways too.
      final rect = boxes.first.toRect();
      final margin = widget.style.fontSize ?? 0;
      paragraph.showOnScreen(
        rect: Rect.fromLTRB(
          rect.left,
          rect.top - margin,
          rect.right,
          rect.bottom + margin,
        ),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    });
  }

  /// Whether any line of [ayahId] shows inside the page's scroll view.
  bool _isOnScreen(RenderParagraph paragraph, int ayahId) {
    final words = _run.words.where((w) => w.ayahId == ayahId);
    final viewport = Scrollable.maybeOf(context)?.context.findRenderObject();
    if (words.isEmpty || viewport is! RenderBox) return false;
    final visible = viewport.localToGlobal(Offset.zero) & viewport.size;
    final origin = paragraph.localToGlobal(Offset.zero);
    final boxes = paragraph.getBoxesForSelection(
      TextSelection(
        baseOffset: words.first.start,
        extentOffset: words.last.end,
      ),
    );
    return boxes.any((box) => box.toRect().shift(origin).overlaps(visible));
  }

  void _onTapUp(TapUpDetails details) {
    final paragraph = _paragraph;
    if (paragraph == null) return;
    final position = paragraph.getPositionForOffset(details.localPosition);
    // An upstream position sits after the character that was tapped.
    final offset =
        position.affinity == TextAffinity.upstream
            ? position.offset - 1
            : position.offset;
    final word = _run.wordAt(offset);
    if (word == null) return;

    final segment = word.segmentAt(offset);
    final rule = segment == null ? null : tajweedRuleOf(segment.ruleKey);
    if (segment != null && rule != null) {
      widget.onTajweedTap(
        TajweedHit(
          rule: rule,
          word: word.text,
          start: segment.start,
          end: segment.end,
          ayahId: word.ayahId,
        ),
      );
      return;
    }
    widget.onAyahTap(word.ayahId);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: _onTapUp,
      child: RichText(
        key: _textKey,
        text: _run.span,
        textAlign: TextAlign.justify,
        textDirection: TextDirection.rtl,
        // The size already has the system text size in it.
        textScaler: TextScaler.noScaling,
      ),
    );
  }
}

/// The surah's title, framed like the printed banner.
class _SurahTitle extends StatelessWidget {
  final QuranSurah surah;
  final double fontSize;
  final MushafColors colors;

  const _SurahTitle({
    required this.surah,
    required this.fontSize,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      padding: EdgeInsets.symmetric(vertical: 4.h),
      decoration: BoxDecoration(
        color: colors.banner,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: colors.gold),
      ),
      child: Text(
        'سُورَةُ ${surah.nameArabic}',
        textAlign: TextAlign.center,
        textScaler: TextScaler.noScaling,
        style: QuranTextStyles.mushafText(
          color: colors.accent,
          size: fontSize * 0.82,
        ).copyWith(height: 1.6),
      ),
    );
  }
}
