part of 'ayah_commentary_cubit.dart';

@immutable
sealed class AyahCommentaryState {
  /// The tafsir and translation asked for.
  final CommentarySettings settings;

  const AyahCommentaryState(this.settings);
}

final class AyahCommentaryLoading extends AyahCommentaryState {
  const AyahCommentaryLoading(super.settings);
}

final class AyahCommentaryLoaded extends AyahCommentaryState {
  final AyahCommentary commentary;

  const AyahCommentaryLoaded(super.settings, this.commentary);
}

final class AyahCommentaryFailure extends AyahCommentaryState {
  final String message;

  const AyahCommentaryFailure(super.settings, this.message);
}
