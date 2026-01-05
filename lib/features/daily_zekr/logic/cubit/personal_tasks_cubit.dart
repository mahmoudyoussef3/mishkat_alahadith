import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/features/daily_zekr/data/models/personal_task.dart';
import 'package:mishkat_almasabih/features/daily_zekr/data/repo/personal_tasks_repository.dart';

part 'personal_tasks_state.dart';

class PersonalTasksCubit extends Cubit<PersonalTasksState> {
  final PersonalTasksRepository _repo;

  PersonalTasksCubit(this._repo) : super(PersonalTasksInitial());

  Future<void> init() async {
    emit(PersonalTasksLoading());
    try {
      final tasks = await _repo.loadAll();
      emit(PersonalTasksLoaded(tasks));
    } catch (_) {
      emit(PersonalTasksError('حدث خطأ أثناء تحميل مهامك'));
    }
  }

  Future<void> addTask(String title) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return;

    final current = state;
    final existing =
        current is PersonalTasksLoaded ? current.tasks : const <PersonalTask>[];

    final now = DateTime.now();
    final task = PersonalTask(
      id: now.microsecondsSinceEpoch.toString(),
      title: trimmed,
      isDone: false,
      createdAt: now,
    );

    final updated = [task, ...existing];
    await _repo.saveAll(updated);
    emit(PersonalTasksLoaded(updated));
  }

  Future<void> toggleDone(String id) async {
    final current = state;
    if (current is! PersonalTasksLoaded) return;

    final updated = current.tasks
        .map((t) => t.id == id ? t.copyWith(isDone: !t.isDone) : t)
        .toList(growable: false);

    await _repo.saveAll(updated);
    emit(PersonalTasksLoaded(updated));
  }
}
