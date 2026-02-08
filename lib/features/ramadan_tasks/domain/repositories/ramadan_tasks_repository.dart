import '../entities/ramadan_task_entity.dart';

abstract class RamadanTasksRepository {
  Future<List<RamadanTaskEntity>> getTasks();
  Future<void> addTask(RamadanTaskEntity task);
  Future<void> updateTask(RamadanTaskEntity task);
  Future<void> deleteTask(String id);

  Future<void> toggleDailyCompletion({required String id, required int day});

  Future<void> setMonthlyCompleted({
    required String id,
    required bool completed,
    required int day,
  });

  Future<void> ensureDailyReset(int day);
}
