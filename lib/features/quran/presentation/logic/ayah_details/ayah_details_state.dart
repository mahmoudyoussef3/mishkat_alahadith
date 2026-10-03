part of 'ayah_details_cubit.dart';

@immutable
sealed class AyahDetailsState {
  const AyahDetailsState();
}

final class AyahDetailsLoading extends AyahDetailsState {
  const AyahDetailsLoading();
}

final class AyahDetailsLoaded extends AyahDetailsState {
  final AyahDetails details;

  const AyahDetailsLoaded(this.details);
}

final class AyahDetailsFailure extends AyahDetailsState {
  final String message;

  const AyahDetailsFailure(this.message);
}
