part of 'add_cubit_cubit.dart';

@immutable
sealed class AddCubitState {}

final class AddCubitInitial extends AddCubitState {}



final class AddLoading extends AddCubitState {}

final class AddSuccess extends AddCubitState {
  final AddBookmarkResponse addBookmarkResponse;
  AddSuccess(this.addBookmarkResponse);
}

final class AddFailure extends AddCubitState {
  final String message;
  AddFailure(this.message);
}
