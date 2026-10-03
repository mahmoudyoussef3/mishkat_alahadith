part of 'ahadiths_cubit.dart';

@immutable
sealed class AhadithsState {}

final class AhadithsInitial extends AhadithsState {}

final class AhadithsLoading extends AhadithsState {}

final class AhadithsSuccess extends AhadithsState {
  final List<Hadith> allAhadith;
  final List<Hadith> filteredAhadith;
  final bool isLoadingMore;
  final bool isRefreshing;
  final bool hasMoreData;
  final bool isFromCache;

  AhadithsSuccess({
    required this.allAhadith,
    required this.filteredAhadith,
    this.isLoadingMore = false,
    this.isRefreshing = false,
    this.hasMoreData = true,
    this.isFromCache = false,
  });

  AhadithsSuccess copyWith({
    List<Hadith>? allAhadith,
    List<Hadith>? filteredAhadith,
    bool? isLoadingMore,
    bool? isRefreshing,
    bool? hasMoreData,
    bool? isFromCache,
  }) {
    return AhadithsSuccess(
      allAhadith: allAhadith ?? this.allAhadith,
      filteredAhadith: filteredAhadith ?? this.filteredAhadith,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }
}

final class LocalAhadithsSuccess extends AhadithsState {
  final List<LocalHadith> hadiths;
  final List<LocalHadith> filteredHadiths;

  LocalAhadithsSuccess({
    required this.hadiths,
    List<LocalHadith>? filteredHadiths,
  }) : filteredHadiths = filteredHadiths ?? hadiths;

  LocalAhadithsSuccess copyWith({
    List<LocalHadith>? hadiths,
    List<LocalHadith>? filteredHadiths,
  }) {
    return LocalAhadithsSuccess(
      hadiths: hadiths ?? this.hadiths,
      filteredHadiths: filteredHadiths ?? this.filteredHadiths,
    );
  }
}

final class AhadithsFailure extends AhadithsState {
  final String error;
  AhadithsFailure(this.error);
}
