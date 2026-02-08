import '../repositories/ramadan_tasks_repository.dart';

class SetMonthlyCompleted {
  final RamadanTasksRepository repo;
  SetMonthlyCompleted(this.repo);
  Future<void> call({
    required String id,
    required bool completed,
    required int day,
  }) => repo.setMonthlyCompleted(id: id, completed: completed, day: day);
}
