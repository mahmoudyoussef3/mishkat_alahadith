import 'package:mishkat_almasabih/features/ahadith_categories/domain/entities/hadith_entity.dart';

sealed class HadithByCategoryState {
  const HadithByCategoryState();
}

class HadithByCategoryInitial extends HadithByCategoryState {
  const HadithByCategoryInitial();
}

class HadithByCategoryLoading extends HadithByCategoryState {
  const HadithByCategoryLoading();
}

class HadithByCategoryLoaded extends HadithByCategoryState {
  final List<HadithEntity> ahadith;
  final MetaEntity meta;
  final bool isLoadingMore;
  final String? paginationError;

  const HadithByCategoryLoaded({
    required this.ahadith,
    required this.meta,
    this.isLoadingMore = false,
    this.paginationError,
  });

  bool get hasMore => meta.currentPage < meta.lastPage;

  HadithByCategoryLoaded copyWith({
    List<HadithEntity>? ahadith,
    MetaEntity? meta,
    bool? isLoadingMore,
    String? paginationError,
    bool clearPaginationError = false,
  }) {
    return HadithByCategoryLoaded(
      ahadith: ahadith ?? this.ahadith,
      meta: meta ?? this.meta,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      paginationError:
          clearPaginationError ? null : (paginationError ?? this.paginationError),
    );
  }
}

class HadithByCategoryError extends HadithByCategoryState {
  final String message;

  const HadithByCategoryError(this.message);
}
