import 'package:json_annotation/json_annotation.dart';

part 'hadith_by_category_model.g.dart';

@JsonSerializable()
class HadithByCategoryResponseModel {
  final List<HadithByCategoryModel>? data;
  final MetaModel? meta;

  HadithByCategoryResponseModel({this.data, this.meta});

  factory HadithByCategoryResponseModel.fromJson(Map<String, dynamic> json) =>
      _$HadithByCategoryResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$HadithByCategoryResponseModelToJson(this);
}

@JsonSerializable()
class HadithByCategoryModel {
  final String? id;
  final String? title;
  final List<String>? translations;

  HadithByCategoryModel({this.id, this.title, this.translations});

  factory HadithByCategoryModel.fromJson(Map<String, dynamic> json) =>
      _$HadithByCategoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$HadithByCategoryModelToJson(this);
}

@JsonSerializable()
class MetaModel {
  @JsonKey(name: 'current_page')
  final int? currentPage;

  @JsonKey(name: 'last_page')
  final int? lastPage;

  @JsonKey(name: 'total_items')
  final int? totalItems;

  @JsonKey(name: 'per_page')
  final int? perPage;

  MetaModel({this.currentPage, this.lastPage, this.totalItems, this.perPage});

  factory MetaModel.fromJson(Map<String, dynamic> json) => MetaModel(
    currentPage: _parseInt(json['current_page']),
    lastPage: _parseInt(json['last_page']),
    totalItems: _parseInt(json['total_items']),
    perPage: _parseInt(json['per_page']),
  );

  Map<String, dynamic> toJson() => _$MetaModelToJson(this);
}

int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}
