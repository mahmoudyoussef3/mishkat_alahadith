import '../repositories/ramadan_tasks_repository.dart';
import '../entities/ramadan_task_entity.dart';

class AddTask {
  final RamadanTasksRepository repo;
  AddTask(this.repo);
  Future<void> call(RamadanTaskEntity task) => repo.addTask(task);
}
