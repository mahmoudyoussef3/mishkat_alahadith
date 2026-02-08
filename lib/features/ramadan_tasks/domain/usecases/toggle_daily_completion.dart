import '../repositories/ramadan_tasks_repository.dart';

class ToggleDailyCompletion {
  final RamadanTasksRepository repo;
  ToggleDailyCompletion(this.repo);
  Future<void> call({required String id, required int day}) =>
      repo.toggleDailyCompletion(id: id, day: day);
}
