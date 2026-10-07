import 'package:mishkat_almasabih/core/domain/entities/explained_hadith.dart';

/// A hadith page to read aloud.
sealed class HadithSpeechRequest {
  /// Shown in the player while it is read.
  final String title;

  const HadithSpeechRequest({required this.title});

  /// Identifies the reading: the same key resumes rather than restarts.
  String get key;
}

/// A hadith from a book: its full text, read after its number.
final class BookHadithSpeech extends HadithSpeechRequest {
  final String text;
  final String bookName;
  final String bookSlug;
  final String number;

  const BookHadithSpeech({
    required super.title,
    required this.text,
    required this.bookName,
    required this.bookSlug,
    required this.number,
  });

  @override
  String get key =>
      number.trim().isEmpty
          ? 'book:$bookSlug:${text.hashCode}'
          : 'book:$bookSlug:$number';
}

/// An explained hadith: its text and source, then its explanation, lessons
/// and word meanings.
final class ExplainedHadithSpeech extends HadithSpeechRequest {
  final ExplainedHadith hadith;

  const ExplainedHadithSpeech({required super.title, required this.hadith});

  @override
  String get key {
    final id = hadith.id?.trim();
    return id == null || id.isEmpty
        ? 'explained:${hadith.hadeeth.hashCode}'
        : 'explained:$id';
  }
}
