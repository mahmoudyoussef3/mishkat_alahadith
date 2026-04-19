import 'package:json_annotation/json_annotation.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/domain/entities/category_entity.dart';
part 'category_model.g.dart';
@JsonSerializable()
class CategoryModel {
  final String? id;
  final String? title;

  @JsonKey(name: 'hadeeths_count')
  final String? hadeethsCount;

  CategoryModel({
    this.id,
    this.title,
    this.hadeethsCount,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryModelToJson(this);

  CategoryEntity toEntity() => CategoryEntity(
        id: id ?? '',
        title: title ?? '',
        hadeethsCount: int.tryParse(hadeethsCount ?? '0') ?? 0,
      );
}
