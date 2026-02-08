import '../../domain/entities/ramadan_task_entity.dart';
import '../../domain/repositories/ramadan_tasks_repository.dart';
import '../datasources/ramadan_tasks_local_datasource.dart';
import '../models/ramadan_task_model.dart';

/// Concrete implementation of [RamadanTasksRepository] backed by Hive.
///
/// Design decisions:
/// - Daily task completions are preserved across all 30 days for history.
/// - TodayOnly tasks belong to a specific day (createdForDay) and toggle
///   completion for that day.
class RamadanTasksRepositoryImpl implements RamadanTasksRepository {
  final RamadanTasksLocalDataSource _ds;
  RamadanTasksRepositoryImpl(this._ds);

  @override
  Future<List<RamadanTaskEntity>> getTasks() async {
    final models = await _ds.getAll();
    return models.map((m) => m.toEntity()).toList(growable: false);
  }

  @override
  Future<void> addTask(RamadanTaskEntity task) async {
    final id =
        task.id.isEmpty
            ? DateTime.now().microsecondsSinceEpoch.toString()
            : task.id;
    final model = RamadanTaskModel.fromEntity(task.copyWith(id: id));
    await _ds.put(model);
  }

  @override
  Future<void> updateTask(RamadanTaskEntity task) async {
    final model = RamadanTaskModel.fromEntity(task);
    await _ds.put(model);
  }

  @override
  Future<void> deleteTask(String id) => _ds.delete(id);

  @override
  Future<void> toggleDailyCompletion({
    required String id,
    required int day,
  }) async {
    final tasks = await getTasks();
    final t = tasks.firstWhere(
      (e) => e.id == id,
      orElse: () => throw ArgumentError('Task not found'),
    );
    if (t.type != TaskType.daily) {
      throw StateError('toggleDailyCompletion only valid for daily tasks');
    }
    final completed = Set<int>.from(t.completedDays);
    if (completed.contains(day)) {
      completed.remove(day);
    } else {
      completed.add(day);
    }
    await updateTask(t.copyWith(completedDays: completed));
  }

  @override
  Future<void> toggleTodayOnlyCompletion({
    required String id,
    required int day,
  }) async {
    final tasks = await getTasks();
    final t = tasks.firstWhere(
      (e) => e.id == id,
      orElse: () => throw ArgumentError('Task not found'),
    );
    if (t.type != TaskType.todayOnly) {
      throw StateError(
        'toggleTodayOnlyCompletion only valid for todayOnly tasks',
      );
    }
    final completed = Set<int>.from(t.completedDays);
    if (completed.contains(day)) {
      completed.remove(day);
    } else {
      completed.add(day);
    }
    await updateTask(t.copyWith(completedDays: completed));
  }

  @override
  Future<void> ensureDailyReset(int day) async {
    // No-op: daily completions are kept across all 30 days for history.
  }
}
