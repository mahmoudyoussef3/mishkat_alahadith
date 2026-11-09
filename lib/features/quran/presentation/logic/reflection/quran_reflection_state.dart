part of 'quran_reflection_cubit.dart';

@immutable
sealed class QuranReflectionState {
  const QuranReflectionState();
}

final class QuranReflectionLoading extends QuranReflectionState {
  /// The ayah shown before, kept on screen while another loads.
  final CommentedAyah? previous;

  const QuranReflectionLoading({this.previous});
}

final class QuranReflectionLoaded extends QuranReflectionState {
  final CommentedAyah ayah;

  const QuranReflectionLoaded(this.ayah);
}

final class QuranReflectionFailure extends QuranReflectionState {
  final String message;

  const QuranReflectionFailure(this.message);
}
