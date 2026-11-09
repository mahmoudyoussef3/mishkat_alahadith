part of 'quran_hizb_index_cubit.dart';

@immutable
sealed class QuranHizbIndexState {
  const QuranHizbIndexState();
}

/// Not asked for yet.
final class QuranHizbIndexIdle extends QuranHizbIndexState {
  const QuranHizbIndexIdle();
}

final class QuranHizbIndexLoading extends QuranHizbIndexState {
  const QuranHizbIndexLoading();
}

final class QuranHizbIndexLoaded extends QuranHizbIndexState {
  /// All 240, in mushaf order.
  final List<QuranHizbQuarter> quarters;

  const QuranHizbIndexLoaded(this.quarters);
}

final class QuranHizbIndexFailure extends QuranHizbIndexState {
  final String message;

  const QuranHizbIndexFailure(this.message);
}
