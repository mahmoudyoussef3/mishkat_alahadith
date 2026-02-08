import '../../domain/entities/ramadan_task_entity.dart';
import '../../domain/repositories/ramadan_tasks_repository.dart';
import '../datasources/ramadan_tasks_local_datasource.dart';
import '../models/ramadan_task_model.dart';

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
    // Ensure ID
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
      // daily tasks should only hold current day completion; clear any other day entries
      completed
        ..clear()
        ..add(day);
    }
    await updateTask(t.copyWith(completedDays: completed));
  }

  @override
  Future<void> setMonthlyCompleted({
    required String id,
    required bool completed,
    required int day,
  }) async {
    final tasks = await getTasks();
    final t = tasks.firstWhere(
      (e) => e.id == id,
      orElse: () => throw ArgumentError('Task not found'),
    );
    if (t.type != TaskType.monthly) {
      throw StateError('setMonthlyCompleted only valid for monthly tasks');
    }
    final days = Set<int>.from(t.completedDays);
    if (completed) {
      // record completion on provided day if not already
      if (!days.contains(day)) days.add(day);
    } else {
      days.clear();
    }
    await updateTask(t.copyWith(completedDays: days));
  }

  @override
  Future<void> ensureDailyReset(int day) async {
    final tasks = await getTasks();
    for (final t in tasks.where((e) => e.type == TaskType.daily)) {
      final newDays = <int>{};
      if (t.completedDays.contains(day)) newDays.add(day);
      await updateTask(t.copyWith(completedDays: newDays));
    }
  }
}
