import 'package:mishkat_almasabih/features/daily_zekr/data/models/personal_task.dart';

abstract class PersonalTasksRepository {
  Future<List<PersonalTask>> loadAll();

  Future<void> saveAll(List<PersonalTask> tasks);
}
