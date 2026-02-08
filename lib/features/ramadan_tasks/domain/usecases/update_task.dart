import '../repositories/ramadan_tasks_repository.dart';
import '../entities/ramadan_task_entity.dart';

class UpdateTask {
  final RamadanTasksRepository repo;
  UpdateTask(this.repo);
  Future<void> call(RamadanTaskEntity task) => repo.updateTask(task);
}
