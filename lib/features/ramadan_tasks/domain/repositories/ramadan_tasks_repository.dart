import '../entities/ramadan_task_entity.dart';

/// Repository interface for Ramadan tasks persistence and business rules.
abstract class RamadanTasksRepository {
  Future<List<RamadanTaskEntity>> getTasks();
  Future<void> addTask(RamadanTaskEntity task);
  Future<void> updateTask(RamadanTaskEntity task);
  Future<void> deleteTask(String id);

  /// Toggle today's completion for a daily task.
  Future<void> toggleDailyCompletion({required String id, required int day});

  /// Set monthly task completion. If true, records the provided day number;
  /// if false, clears completion.
  Future<void> setMonthlyCompleted({
    required String id,
    required bool completed,
    required int day,
  });

  /// Ensures daily tasks only have completion for the provided day (resets old days).
  Future<void> ensureDailyReset(int day);
}
