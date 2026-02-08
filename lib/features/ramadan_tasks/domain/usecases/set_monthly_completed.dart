import '../repositories/ramadan_tasks_repository.dart';

class ToggleTodayOnlyCompletion {
  final RamadanTasksRepository repo;
  ToggleTodayOnlyCompletion(this.repo);
  Future<void> call({required String id, required int day}) =>
      repo.toggleTodayOnlyCompletion(id: id, day: day);
}
