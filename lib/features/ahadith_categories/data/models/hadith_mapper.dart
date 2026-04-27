import 'package:mishkat_almasabih/features/ahadith_categories/data/models/hadith_by_category_model.dart';

import 'package:mishkat_almasabih/features/ahadith_categories/domain/entities_temp/hadith_entity.dart';

extension HadithResponseMapper on HadithByCategoryResponseModel {
  HadithResponseEntity toEntity() {
    return HadithResponseEntity(
      data: data?.map((e) => e.toEntity()).toList() ?? [],
      meta:
          meta?.toEntity() ??
          MetaEntity(currentPage: 1, lastPage: 1, totalItems: 0, perPage: 0),
    );
  }
}

extension HadithMapper on HadithByCategoryModel {
  HadithEntity toEntity() {
    return HadithEntity(
      id: id ?? '',
      title: title ?? '',
      translations: translations ?? [],
    );
  }
}

extension MetaMapper on MetaModel {
  MetaEntity toEntity() {
    return MetaEntity(
      currentPage: currentPage ?? 1,
      lastPage: lastPage ?? 1,
      totalItems: totalItems ?? 0,
      perPage: perPage ?? 0,
    );
  }
}
