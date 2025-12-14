part of 'ahadiths_cubit.dart';

@immutable
sealed class AhadithsState {}

final class AhadithsInitial extends AhadithsState {}

final class AhadithsLoading extends AhadithsState {}

final class AhadithsSuccess extends AhadithsState {
  final List<Hadith> allAhadith;
  final List<Hadith> filteredAhadith;

  AhadithsSuccess({
    required this.allAhadith,
    required this.filteredAhadith,
  });

  AhadithsSuccess copyWith({
    List<Hadith>? allAhadith,
    List<Hadith>? filteredAhadith,
  }) {
    return AhadithsSuccess(
      allAhadith: allAhadith ?? this.allAhadith,
      filteredAhadith: filteredAhadith ?? this.filteredAhadith,
    );
  }
}

final class LocalAhadithsSuccess extends AhadithsState {
  final List<LocalHadith> hadiths;

  LocalAhadithsSuccess({required this.hadiths});

}

final class AhadithsFailure extends AhadithsState {
  final String error;
  AhadithsFailure(this.error);
}
