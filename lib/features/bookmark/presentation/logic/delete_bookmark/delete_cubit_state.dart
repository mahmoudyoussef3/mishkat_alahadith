part of 'delete_cubit_cubit.dart';

@immutable
sealed class DeleteCubitState {}

final class DeleteCubitInitial extends DeleteCubitState {}

final class DeleteLoading extends DeleteCubitState {}

final class DeleteSuccess extends DeleteCubitState {
  final AddBookmarkResponse addBookmarkResponse;
  DeleteSuccess(this.addBookmarkResponse);
}

final class DeleteFaliure extends DeleteCubitState {
  final String errorMessage;
  DeleteFaliure(this.errorMessage);
}
