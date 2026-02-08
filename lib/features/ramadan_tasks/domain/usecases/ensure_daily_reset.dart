import '../repositories/ramadan_tasks_repository.dart';

class EnsureDailyReset {
  final RamadanTasksRepository repo;
  EnsureDailyReset(this.repo);
  Future<void> call(int day) => repo.ensureDailyReset(day);
}
