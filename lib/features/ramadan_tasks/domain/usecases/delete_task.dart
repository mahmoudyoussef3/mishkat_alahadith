import '../repositories/ramadan_tasks_repository.dart';

class DeleteTask {
  final RamadanTasksRepository repo;
  DeleteTask(this.repo);
  Future<void> call(String id) => repo.deleteTask(id);
}
