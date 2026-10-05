/// A piece of an AI answer, recognised from its plain-text or light
/// Markdown layout so it can be typeset instead of shown as one block.
sealed class AnswerBlock {
  const AnswerBlock();
}

/// A section title ("المعنى الإجمالي").
final class AnswerHeading extends AnswerBlock {
  const AnswerHeading(this.text);
  final String text;
}

final class AnswerParagraph extends AnswerBlock {
  const AnswerParagraph(this.text);
  final String text;
}

/// Consecutive bullet or numbered lines.
final class AnswerList extends AnswerBlock {
  const AnswerList(this.items, {required this.ordered});
  final List<String> items;
  final bool ordered;
}

/// Quoted words of a hadith, set apart from the explanation.
final class AnswerQuote extends AnswerBlock {
  const AnswerQuote(this.text);
  final String text;
}

final _markdownHeading = RegExp(r'^#{1,6}\s*(.+)$');
final _boldLine = RegExp(r'^\*\*(.+?)\*\*\s*[:：]?$');
final _bullet = RegExp(r'^[-*•▪◦]\s+(.+)$');
final _numbered = RegExp(r'^(?:\d+|[٠-٩]+)\s*[.)\-–]\s*(.+)$');
final _blockQuote = RegExp(r'^>\s*(.+)$');
final _hadithQuote = RegExp(r'^«[^»]+»[.،؛]?$');

/// Splits [text] into blocks. Lines are read one at a time: Markdown or
/// bold-only lines and short lines ending in a colon become headings,
/// bullets and numbers become lists, lines that are wholly «…» or start
/// with ">" become quotes, and anything else is a paragraph.
List<AnswerBlock> parseAnswer(String text) {
  final blocks = <AnswerBlock>[];
  List<String>? listItems;
  var listOrdered = false;

  void closeList() {
    final items = listItems;
    if (items != null && items.isNotEmpty) {
      blocks.add(AnswerList(List.unmodifiable(items), ordered: listOrdered));
    }
    listItems = null;
  }

  for (final raw in text.split('\n')) {
    final line = raw.trim();
    if (line.isEmpty) {
      closeList();
      continue;
    }

    final numbered = _numbered.firstMatch(line);
    final bullet = numbered == null ? _bullet.firstMatch(line) : null;
    if (numbered != null || bullet != null) {
      final ordered = numbered != null;
      if (listItems != null && listOrdered != ordered) closeList();
      listOrdered = ordered;
      (listItems ??= []).add((numbered ?? bullet)!.group(1)!.trim());
      continue;
    }
    closeList();

    if (_markdownHeading.firstMatch(line) case final match?) {
      blocks.add(AnswerHeading(_stripColon(_stripBold(match.group(1)!))));
    } else if (_boldLine.firstMatch(line) case final match?) {
      blocks.add(AnswerHeading(_stripColon(match.group(1)!)));
    } else if (_blockQuote.firstMatch(line) case final match?) {
      blocks.add(AnswerQuote(match.group(1)!.trim()));
    } else if (_hadithQuote.hasMatch(line)) {
      blocks.add(AnswerQuote(line));
    } else if (_looksLikeHeading(line)) {
      blocks.add(AnswerHeading(_stripColon(line)));
    } else {
      blocks.add(AnswerParagraph(line));
    }
  }
  closeList();
  return blocks;
}

bool _looksLikeHeading(String line) =>
    (line.endsWith(':') || line.endsWith('：')) &&
    line.length <= 40 &&
    !line.contains('«') &&
    !line.contains('.');

String _stripColon(String text) =>
    text.replaceFirst(RegExp(r'\s*[:：]\s*$'), '').trim();

String _stripBold(String text) => text.replaceAll('**', '').trim();
