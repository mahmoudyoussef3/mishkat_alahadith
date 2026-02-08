import 'package:hive/hive.dart';
import '../../domain/entities/ramadan_task_entity.dart';

class RamadanTaskModel {
  String id;
  String title;
  String description;
  int typeIndex; // 0=daily, 1=todayOnly
  List<int> completedDays; // store as list for Hive
  int createdForDay; // which Ramadan day this todayOnly task belongs to

  RamadanTaskModel({
    required this.id,
    required this.title,
    this.description = '',
    required this.typeIndex,
    required this.completedDays,
    this.createdForDay = 0,
  });

  factory RamadanTaskModel.fromEntity(RamadanTaskEntity e) => RamadanTaskModel(
    id: e.id,
    title: e.title,
    description: e.description,
    typeIndex: e.type.index,
    completedDays: e.completedDays.toList()..sort(),
    createdForDay: e.createdForDay,
  );

  RamadanTaskEntity toEntity() => RamadanTaskEntity(
    id: id,
    title: title,
    description: description,
    type: TaskType.values[typeIndex],
    completedDays: completedDays.toSet(),
    createdForDay: createdForDay,
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
      description: (fields[4] as String?) ?? '',
      typeIndex: fields[2] as int,
      completedDays: (fields[3] as List).cast<int>(),
      createdForDay: (fields[5] as int?) ?? 0,
    );
  }

  @override
  void write(BinaryWriter writer, RamadanTaskModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.typeIndex)
      ..writeByte(3)
      ..write(obj.completedDays)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.createdForDay);
  }
}
