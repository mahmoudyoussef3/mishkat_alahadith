class HadithEntity {
  final String id;
  final String title;
  final List<String> translations;

  HadithEntity({
    required this.id,
    required this.title,
    required this.translations,
  });
}

class MetaEntity {
  final int currentPage;
  final int lastPage;
  final int totalItems;
  final int perPage;

  MetaEntity({
    required this.currentPage,
    required this.lastPage,
    required this.totalItems,
    required this.perPage,
  });
}

class HadithResponseEntity {
  final List<HadithEntity> data;
  final MetaEntity meta;

  HadithResponseEntity({required this.data, required this.meta});
}
