import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:mishkat_almasabih/core/networking/api_error_model.dart';
import 'package:mishkat_almasabih/features/chapters/data/models/chapters_model.dart';
import 'package:mishkat_almasabih/features/chapters/data/repos/chapters_repo.dart';

part 'chapters_state.dart';

class ChaptersCubit extends Cubit<ChaptersState> {
  final BookChaptersRepo _bookChaptersRepo;
  ChaptersCubit(this._bookChaptersRepo) : super(ChaptersInitial());

  Future<void> emitGetBookChapters({
    required String bookSlug,

  }) async {
    emit(ChaptersLoading());
    final result = await _bookChaptersRepo.getBookChapters(bookSlug);
    result.fold(
      (l) => emit(ChaptersFailure(l.getAllErrorMessages())),
      (r) => emit(
        ChaptersSuccess(
          allChapters: r.chapters ?? [],
          filteredChapters: r.chapters ?? [],
        ),
      ),
    );
  }

  void filterChapters(String query) {
    if (state is ChaptersSuccess) {
      final currentState = state as ChaptersSuccess;
      final normalizedQuery = normalizeArabic(query);

      if (normalizedQuery.isEmpty) {
        emit(currentState.copyWith(filteredChapters: currentState.allChapters));
      } else {
        final filtered =
            currentState.allChapters.where((chapter) {
              final normalizedChapter = normalizeArabic(
                chapter.chapterArabic ?? '',
              );
              return normalizedChapter.contains(normalizedQuery.trim());
            }).toList();

        emit(currentState.copyWith(filteredChapters: filtered));
      }
    }
  }

  String normalizeArabic(String text) {
    // 1. شيل التشكيل (كل الحركات + التنوين + السكون + الشدة)
    final diacritics = RegExp(r'[\u0617-\u061A\u064B-\u0652]');
    String result = text.replaceAll(diacritics, '');

    // 2. توحيد الهمزات: أ إ آ -> ا
    result = result.replaceAll(RegExp('[إأآ]'), 'ا');

    // 3. شيل المدّة "ـ"
    result = result.replaceAll('ـ', '');

    // 4. lowercase (لو فيه انجليزي)
    result = result.toLowerCase();

    return result;
  }
}
