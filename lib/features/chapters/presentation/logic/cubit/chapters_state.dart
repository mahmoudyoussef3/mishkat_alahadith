part of 'chapters_cubit.dart';

@immutable
sealed class ChaptersState {}

final class ChaptersInitial extends ChaptersState {}

final class ChaptersLoading extends ChaptersState {}

final class ChaptersSuccess extends ChaptersState {
  final List<Chapter> allChapters;
  final List<Chapter> filteredChapters;
  final bool isRefreshing;
  final bool isFromCache;

  ChaptersSuccess({
    required this.allChapters,
    required this.filteredChapters,
    this.isRefreshing = false,
    this.isFromCache = false,
  });

  ChaptersSuccess copyWith({
    List<Chapter>? allChapters,
    List<Chapter>? filteredChapters,
    bool? isRefreshing,
    bool? isFromCache,
  }) {
    return ChaptersSuccess(
      allChapters: allChapters ?? this.allChapters,
      filteredChapters: filteredChapters ?? this.filteredChapters,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }
}

final class ChaptersFailure extends ChaptersState {
  final String? errorMessage;
  ChaptersFailure(this.errorMessage);
}
