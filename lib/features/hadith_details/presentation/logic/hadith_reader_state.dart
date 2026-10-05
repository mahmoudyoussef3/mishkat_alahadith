part of 'hadith_reader_cubit.dart';

class HadithReaderState {
  final String hadithId;
  final String text;
  final NavigationHadithRef? previous;
  final NavigationHadithRef? next;

  /// How many hadiths the chapter has, once known.
  final int? chapterTotal;

  /// True while the current hadith's neighbours are being found.
  final bool isLoading;

  /// True when the neighbours could not be loaded.
  final bool failed;

  const HadithReaderState({
    required this.hadithId,
    required this.text,
    this.previous,
    this.next,
    this.chapterTotal,
    this.isLoading = false,
    this.failed = false,
  });

  bool get hasPrevious => previous?.id?.isNotEmpty ?? false;

  bool get hasNext => next?.id?.isNotEmpty ?? false;

  HadithReaderState copyWith({
    NavigationHadithRef? previous,
    NavigationHadithRef? next,
    int? chapterTotal,
    bool? isLoading,
    bool? failed,
  }) {
    return HadithReaderState(
      hadithId: hadithId,
      text: text,
      previous: previous ?? this.previous,
      next: next ?? this.next,
      chapterTotal: chapterTotal ?? this.chapterTotal,
      isLoading: isLoading ?? this.isLoading,
      failed: failed ?? this.failed,
    );
  }
}
