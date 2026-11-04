part of 'azkar_reader_cubit.dart';

/// What one tap on a zikr's counter did, so the screen can answer with the
/// right feel.
enum ZikrCountOutcome {
  /// Counted, with more repetitions to go.
  counted,

  /// The zikr has now been said as many times as asked.
  zikrCompleted,

  /// The last zikr of the chapter is done.
  categoryCompleted,

  /// Nothing to count: the zikr was already done, or is not in the chapter.
  ignored,
}

/// The zikr to bring into view. [serial] changes with every request, so
/// asking for the same zikr twice still scrolls to it.
typedef ZikrFocus = ({int zikrId, int serial});

@immutable
sealed class AzkarReaderState {
  const AzkarReaderState();
}

final class AzkarReaderLoading extends AzkarReaderState {
  const AzkarReaderLoading();
}

final class AzkarReaderLoaded extends AzkarReaderState {
  final AzkarCategory category;

  /// Zikr id → times said today.
  final Map<int, int> counts;
  final bool isFavorite;
  final AzkarSettings settings;
  final ZikrFocus? focus;

  /// The day [counts] belong to; null when today's counts could not be read.
  final DateTime? day;

  /// How many changes could not be saved; each one is reported once.
  final int failedSaves;

  const AzkarReaderLoaded({
    required this.category,
    required this.counts,
    required this.isFavorite,
    required this.settings,
    this.focus,
    this.day,
    this.failedSaves = 0,
  });

  int countOf(int zikrId) => counts[zikrId] ?? 0;

  bool isDone(Zikr zikr) => countOf(zikr.id) >= zikr.count;

  AzkarCategoryProgress get progress =>
      AzkarCategoryProgress.of(category, counts);

  /// The first zikr still to say after [zikrId], wrapping round to the
  /// start; null when every zikr is done.
  int? nextPendingAfter(int? zikrId) {
    final azkar = category.azkar;
    final start =
        zikrId == null ? 0 : azkar.indexWhere((z) => z.id == zikrId) + 1;
    for (var step = 0; step < azkar.length; step++) {
      final zikr = azkar[(start + step) % azkar.length];
      if (!isDone(zikr)) return zikr.id;
    }
    return null;
  }

  AzkarReaderLoaded copyWith({
    AzkarCategory? category,
    Map<int, int>? counts,
    bool? isFavorite,
    AzkarSettings? settings,
    ZikrFocus? Function()? focus,
    DateTime? Function()? day,
    int? failedSaves,
  }) {
    return AzkarReaderLoaded(
      category: category ?? this.category,
      counts: counts ?? this.counts,
      isFavorite: isFavorite ?? this.isFavorite,
      settings: settings ?? this.settings,
      focus: focus != null ? focus() : this.focus,
      day: day != null ? day() : this.day,
      failedSaves: failedSaves ?? this.failedSaves,
    );
  }
}

final class AzkarReaderFailure extends AzkarReaderState {
  final String message;

  const AzkarReaderFailure(this.message);
}
