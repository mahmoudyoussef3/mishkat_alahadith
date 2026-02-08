import '../repositories/ramadan_tasks_repository.dart';
import '../entities/ramadan_task_entity.dart';

class GetTasks {
  final RamadanTasksRepository repo;
  GetTasks(this.repo);
  Future<List<RamadanTaskEntity>> call() => repo.getTasks();
}
