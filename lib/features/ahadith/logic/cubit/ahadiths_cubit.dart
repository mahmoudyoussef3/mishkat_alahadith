import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:mishkat_almasabih/core/helpers/functions.dart';
import 'package:mishkat_almasabih/core/networking/api_error_model.dart';
import 'package:mishkat_almasabih/features/ahadith/data/models/ahadiths_model.dart';
import 'package:mishkat_almasabih/features/ahadith/data/models/local_books_model.dart';
import 'package:mishkat_almasabih/features/ahadith/data/repos/ahadiths_repo.dart';
part 'ahadiths_state.dart';

class AhadithsCubit extends Cubit<AhadithsState> {
  final AhadithsRepo _chapterAhadithsRepo;
  AhadithsCubit(this._chapterAhadithsRepo) : super(AhadithsInitial());

  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _lastSourceKey;

  Future<void> emitAhadiths({
    required String bookSlug,
    required int chapterId,
    required bool hadithLocal,
    required bool isArbainBooks,
    required int page,
    int paginate = 10,
  }) async {
    // نحدد نوع المصدر الحالي
    final currentSourceKey = '$bookSlug-$chapterId-$hadithLocal-$isArbainBooks';

    // لو غيرنا المصدر، نعمل reset للصفحات
    if (_lastSourceKey != currentSourceKey) {
      _hasMore = true;
      _isLoadingMore = false;
      emit(AhadithsInitial());
      _lastSourceKey = currentSourceKey;
    }

    // أول صفحة => تحميل عادي
    if (page == 1) emit(AhadithsLoading());

    // لو بالفعل بيحمل بيانات إضافية، متحملش تاني
    if (_isLoadingMore || !_hasMore) return;
    _isLoadingMore = true;

    if (isArbainBooks) {
      final result = await _chapterAhadithsRepo.getThreeAhadith(
        bookSlug: bookSlug,
        chapterId: chapterId,
      );

      result.fold(
        (l) {
          _isLoadingMore = false;
          emit(AhadithsFailure(l.getAllErrorMessages()));
        },
        (r) {
          _isLoadingMore = false;
          emit(LocalAhadithsSuccess(hadiths: r.hadiths?.data ?? []));
        },
      );
    } else if (hadithLocal) {
      final result = await _chapterAhadithsRepo.getLocalAhadith(
        bookSlug: bookSlug,
        chapterId: chapterId,
      );

      result.fold(
        (l) {
          emit(AhadithsFailure(l.getAllErrorMessages()));
        },
        (r) {
          emit(LocalAhadithsSuccess(hadiths: r.hadiths?.data ?? []));
        },
      );
    } else {
      final result = await _chapterAhadithsRepo.getAhadith(
        bookSlug: bookSlug,
        chapterId: chapterId,
        page: page,
        paginate: paginate,
      );

      result.fold(
        (l) {
          _isLoadingMore = false;
          emit(AhadithsFailure(l.getAllErrorMessages()));
        },
        (r) {
          final newHadiths = r.hadiths?.data ?? [];

          if (newHadiths.isEmpty) _hasMore = false;

          if (state is AhadithsSuccess && page > 1) {
            final current = state as AhadithsSuccess;
            final combined = List.of(current.allAhadith)..addAll(newHadiths);

            emit(
              current.copyWith(filteredAhadith: combined, allAhadith: combined),
            );
          } else {
            emit(
              AhadithsSuccess(
                filteredAhadith: newHadiths,
                allAhadith: newHadiths,
              ),
            );
          }

          _isLoadingMore = false;
        },
      );
    }
  }

  bool get hasMore => _hasMore;

  void filterAhadith(String query) {
    final currentState = state;
    final normalizedQuery = normalizeArabic(query);

    if (currentState is AhadithsSuccess) {
      if (normalizedQuery.isEmpty) {
        emit(currentState.copyWith(filteredAhadith: currentState.allAhadith));
      } else {
        final filtered =
            currentState.allAhadith
                .where(
                  (h) =>
                      h.hadithArabic != null &&
                      normalizeArabic(
                        h.hadithArabic!,
                      ).contains(normalizedQuery),
                )
                .toList();
        emit(currentState.copyWith(filteredAhadith: filtered));
      }
    }
  }
}
