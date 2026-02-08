import 'package:hive/hive.dart';
import 'package:mishkat_almasabih/core/services/hive_service.dart';
import '../models/ramadan_task_model.dart';

/// Local datasource using Hive for persistence.
class RamadanTasksLocalDataSource {
  Box<RamadanTaskModel>? _box;

  Future<void> init() async {
    if (!Hive.isAdapterRegistered(33)) {
      Hive.registerAdapter(RamadanTaskModelAdapter());
    }
    _box ??= await Hive.openBox<RamadanTaskModel>(HiveService.ramadanTasksBox);
  }

  Future<List<RamadanTaskModel>> getAll() async {
    await init();
    return _box!.values.toList(growable: false);
  }

  Future<void> put(RamadanTaskModel model) async {
    await init();
    await _box!.put(model.id, model);
  }

  Future<void> delete(String id) async {
    await init();
    await _box!.delete(id);
  }
}
