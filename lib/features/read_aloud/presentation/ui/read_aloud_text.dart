import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/entities/speech_track.dart';
import 'package:mishkat_almasabih/features/read_aloud/presentation/logic/read_aloud_cubit.dart';
import 'package:mishkat_almasabih/features/read_aloud/presentation/logic/read_aloud_settings_cubit.dart';
import 'package:mishkat_almasabih/features/read_aloud/presentation/ui/read_aloud_host.dart';
import 'package:mishkat_almasabih/features/reading_preferences/presentation/ui/hadith_text.dart';

/// Text that a reading can follow: while this screen's reading is on
/// [part] of this very [text], the word being read is marked and kept on
/// screen. Outside a [ReadAloudHost] it is plain text.
///
/// [scaled] text follows the reader's hadith font size, like [HadithText].
class ReadAloudText extends StatefulWidget {
  const ReadAloudText(
    this.text, {
    super.key,
    required this.part,
    required this.style,
    this.scaled = true,
  });

  final String text;
  final SpeechPart part;
  final TextStyle style;
  final bool scaled;

  @override
  State<ReadAloudText> createState() => _ReadAloudTextState();
}

class _ReadAloudTextState extends State<ReadAloudText> {
  final GlobalKey _textKey = GlobalKey();
  ({int start, int end})? _revealed;

  ({int start, int end})? _watchWord(BuildContext context) {
    final owner = ReadAloudHost.maybeOwnerOf(context);
    final highlight = context.select<ReadAloudSettingsCubit?, bool>(
      (cubit) => cubit?.state.settings.highlightWords ?? true,
    );
    final word = context.select<ReadAloudCubit?, ({int start, int end})?>((
      cubit,
    ) {
      final state = cubit?.state;
      if (state == null || !state.ownedBy(owner)) return null;
      if (state.status != ReadAloudStatus.playing &&
          state.status != ReadAloudStatus.paused) {
        return null;
      }
      final segment = state.segment;
      if (segment == null || !segment.reads(widget.part, text: widget.text)) {
        return null;
      }
      return state.word;
    });
    if (!highlight || word == null) return null;
    if (word.start < 0 || word.end > widget.text.length) return null;
    return word.start < word.end ? word : null;
  }

  @override
  Widget build(BuildContext context) {
    final word = _watchWord(context);
    if (word != _revealed) {
      _revealed = word;
      if (word != null) _revealAfterLayout(word);
    }

    final text = widget.text;
    final span =
        word == null
            ? TextSpan(text: text)
            : TextSpan(
              children: [
                TextSpan(text: text.substring(0, word.start)),
                TextSpan(
                  text: text.substring(word.start, word.end),
                  style: TextStyle(
                    color: ColorsManager.goldInk,
                    backgroundColor: ColorsManager.goldSoft,
                  ),
                ),
                TextSpan(text: text.substring(word.end)),
              ],
            );

    return widget.scaled
        ? HadithText.rich(span, key: _textKey, style: widget.style)
        : Text.rich(span, key: _textKey, style: widget.style);
  }

  /// Scrolls just enough to bring the word into view, if it is not.
  void _revealAfterLayout(({int start, int end}) word) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _revealed != word) return;
      final paragraph = _paragraphIn(_textKey.currentContext?.findRenderObject());
      if (paragraph == null || !paragraph.attached || !paragraph.hasSize) return;
      final boxes = paragraph.getBoxesForSelection(
        TextSelection(baseOffset: word.start, extentOffset: word.end),
      );
      if (boxes.isEmpty) return;
      var rect = boxes.first.toRect();
      for (final box in boxes.skip(1)) {
        rect = rect.expandToInclude(box.toRect());
      }
      paragraph.showOnScreen(
        rect: rect.inflate(56),
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    });
  }

  /// The paragraph a [Text] renders, under the mouse region it gains
  /// inside a selection area.
  static RenderParagraph? _paragraphIn(RenderObject? object) {
    if (object == null || object is RenderParagraph) {
      return object as RenderParagraph?;
    }
    RenderParagraph? found;
    object.visitChildren((child) => found ??= _paragraphIn(child));
    return found;
  }
}

/// The item of [part] this screen's reading is on (a lesson, a word
/// meaning), or null when it is elsewhere.
int? watchReadAloudItem(BuildContext context, SpeechPart part) {
  final owner = ReadAloudHost.maybeOwnerOf(context);
  return context.select<ReadAloudCubit?, int?>((cubit) {
    final state = cubit?.state;
    if (state == null || !state.ownedBy(owner)) return null;
    if (state.status != ReadAloudStatus.playing &&
        state.status != ReadAloudStatus.paused) {
      return null;
    }
    final segment = state.segment;
    return segment != null && segment.part == part ? segment.item : null;
  });
}
