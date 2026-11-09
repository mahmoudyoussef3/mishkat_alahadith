part of 'quran_editions_cubit.dart';

@immutable
sealed class QuranEditionsState {
  const QuranEditionsState();
}

final class QuranEditionsLoading extends QuranEditionsState {
  const QuranEditionsLoading();
}

final class QuranEditionsLoaded extends QuranEditionsState {
  final List<QuranEdition> editions;

  /// [editions] narrowed by [query].
  final List<QuranEdition> visible;
  final String query;

  const QuranEditionsLoaded({
    required this.editions,
    required this.visible,
    required this.query,
  });

  /// The edition named [identifier], if it is in the list.
  QuranEdition? find(String? identifier) =>
      editions.where((e) => e.identifier == identifier).firstOrNull;
}

final class QuranEditionsFailure extends QuranEditionsState {
  final String message;

  const QuranEditionsFailure(this.message);
}
