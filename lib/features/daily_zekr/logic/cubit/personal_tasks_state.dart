part of 'personal_tasks_cubit.dart';

@immutable
sealed class PersonalTasksState {}

final class PersonalTasksInitial extends PersonalTasksState {}

final class PersonalTasksLoading extends PersonalTasksState {}

final class PersonalTasksLoaded extends PersonalTasksState {
  final List<PersonalTask> tasks;
  PersonalTasksLoaded(this.tasks);
}

final class PersonalTasksError extends PersonalTasksState {
  final String message;
  PersonalTasksError(this.message);
}
