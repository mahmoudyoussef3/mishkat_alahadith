import 'package:hive/hive.dart';
import '../../domain/entities/ramadan_task_entity.dart';

class RamadanTaskModel {
  String id;
  String title;
  int typeIndex; // 0=daily, 1=monthly
  List<int> completedDays; // store as list for Hive

  RamadanTaskModel({
    required this.id,
    required this.title,
    required this.typeIndex,
    required this.completedDays,
  });

  factory RamadanTaskModel.fromEntity(RamadanTaskEntity e) => RamadanTaskModel(
    id: e.id,
    title: e.title,
    typeIndex: e.type.index,
    completedDays: e.completedDays.toList()..sort(),
  );

  RamadanTaskEntity toEntity() => RamadanTaskEntity(
    id: id,
    title: title,
    type: TaskType.values[typeIndex],
    completedDays: completedDays.toSet(),
  );
}

/// Manual adapter to avoid code generation
class RamadanTaskModelAdapter extends TypeAdapter<RamadanTaskModel> {
  @override
  final int typeId = 33;

  @override
  RamadanTaskModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return RamadanTaskModel(
      id: fields[0] as String,
      title: fields[1] as String,
      typeIndex: fields[2] as int,
      completedDays: (fields[3] as List).cast<int>(),
    );
  }

  @override
  void write(BinaryWriter writer, RamadanTaskModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.typeIndex)
      ..writeByte(3)
      ..write(obj.completedDays);
  }
}
