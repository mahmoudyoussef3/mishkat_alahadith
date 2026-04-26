// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hadith_by_category_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HadithByCategoryResponseModel _$HadithByCategoryResponseModelFromJson(
  Map<String, dynamic> json,
) => HadithByCategoryResponseModel(
  data:
      (json['data'] as List<dynamic>?)
          ?.map(
            (e) => HadithByCategoryModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
  meta:
      json['meta'] == null
          ? null
          : MetaModel.fromJson(json['meta'] as Map<String, dynamic>),
);

Map<String, dynamic> _$HadithByCategoryResponseModelToJson(
  HadithByCategoryResponseModel instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

HadithByCategoryModel _$HadithByCategoryModelFromJson(
  Map<String, dynamic> json,
) => HadithByCategoryModel(
  id: json['id'] as String?,
  title: json['title'] as String?,
  translations:
      (json['translations'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
);

Map<String, dynamic> _$HadithByCategoryModelToJson(
  HadithByCategoryModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'translations': instance.translations,
};

MetaModel _$MetaModelFromJson(Map<String, dynamic> json) => MetaModel(
  currentPage: (json['current_page'] as num?)?.toInt(),
  lastPage: (json['last_page'] as num?)?.toInt(),
  totalItems: (json['total_items'] as num?)?.toInt(),
  perPage: (json['per_page'] as num?)?.toInt(),
);

Map<String, dynamic> _$MetaModelToJson(MetaModel instance) => <String, dynamic>{
  'current_page': instance.currentPage,
  'last_page': instance.lastPage,
  'total_items': instance.totalItems,
  'per_page': instance.perPage,
};
