import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../../domain/entities/mushaf_reader_settings.dart';
import '../../domain/entities/quran_bookmark.dart';
import '../../domain/entities/quran_last_read.dart';
import '../../domain/entities/quran_metrics.dart';
import '../../domain/entities/recitation_settings.dart';
import '../../domain/repos/quran_reading_repo.dart';
import '../datasources/quran_reading_local_datasource.dart';
import '../mappers/quran_mappers.dart';

class QuranReadingRepoImpl implements QuranReadingRepo {
  final QuranReadingLocalDataSource _local;

  /// The tail of the bookmark write queue; see [updateBookmarks].
  Future<void> _bookmarkWrites = Future.value();

  QuranReadingRepoImpl(this._local);

  @override
  Future<ApiResult<QuranLastRead?>> getLastRead() async {
    try {
      final stored = await _local.getLastRead();
      if (stored == null || !QuranMetrics.isValidPage(stored.page)) {
        return const ApiResult.success(null);
      }
      return ApiResult.success(
        QuranLastRead(
          page: stored.page,
          savedAt: DateTime.fromMillisecondsSinceEpoch(stored.savedAtMillis),
        ),
      );
    } catch (_) {
      return const ApiResult.failure(CacheFailure());
    }
  }

  @override
  Future<ApiResult<void>> saveLastRead(QuranLastRead lastRead) async {
    try {
      await _local.saveLastRead(
        page: lastRead.page,
        savedAtMillis: lastRead.savedAt.millisecondsSinceEpoch,
      );
      return const ApiResult.success(null);
    } catch (_) {
      return const ApiResult.failure(CacheFailure());
    }
  }

  @override
  Future<ApiResult<List<QuranBookmark>>> getBookmarks() async {
    try {
      final models = await _local.getBookmarks();
      return ApiResult.success([for (final m in models) m.toEntity()]);
    } catch (_) {
      return const ApiResult.failure(CacheFailure());
    }
  }

  @override
  Future<ApiResult<List<QuranBookmark>>> updateBookmarks(
    List<QuranBookmark> Function(List<QuranBookmark> current) change,
  ) {
    final result = _bookmarkWrites.then((_) => _applyBookmarkChange(change));
    _bookmarkWrites = result;
    return result;
  }

  Future<ApiResult<List<QuranBookmark>>> _applyBookmarkChange(
    List<QuranBookmark> Function(List<QuranBookmark> current) change,
  ) async {
    try {
      final current = [
        for (final m in await _local.getBookmarks()) m.toEntity(),
      ];
      final updated = change(current);
      await _local.saveBookmarks([for (final b in updated) b.toModel()]);
      return ApiResult.success(updated);
    } catch (_) {
      return const ApiResult.failure(CacheFailure());
    }
  }

  @override
  Future<ApiResult<MushafReaderSettings>> getSettings() async {
    try {
      final stored = await _local.getSettings();
      const defaults = MushafReaderSettings.defaults;
      return ApiResult.success(
        MushafReaderSettings(
          tajweedEnabled: stored.tajweed ?? defaults.tajweedEnabled,
          naturalMaddEnabled: stored.naturalMadd ?? defaults.naturalMaddEnabled,
          themeMode:
              MushafThemeMode.values.asNameMap()[stored.themeMode] ??
              defaults.themeMode,
          layoutMode:
              MushafLayoutMode.values.asNameMap()[stored.layoutMode] ??
              defaults.layoutMode,
          fontScale:
              QuranFontScale.values.asNameMap()[stored.fontScale] ??
              defaults.fontScale,
        ),
      );
    } catch (_) {
      return const ApiResult.failure(CacheFailure());
    }
  }

  @override
  Future<ApiResult<RecitationSettings>> getRecitationSettings() async {
    try {
      final stored = await _local.getRecitationSettings();
      const defaults = RecitationSettings.defaults;
      final reciter = stored.reciter;
      final reciterName = stored.reciterName;
      final validReciter =
          reciter != null && RecitationSettings.isValidEditionId(reciter);
      return ApiResult.success(
        RecitationSettings(
          reciterId: validReciter ? reciter : defaults.reciterId,
          // A name only ever goes with the reciter it was saved with.
          reciterName:
              validReciter && reciterName != null && reciterName.isNotEmpty
                  ? reciterName
                  : validReciter
                  ? reciter
                  : defaults.reciterName,
          repeat:
              AyahRepeat.values.asNameMap()[stored.repeat] ?? defaults.repeat,
          speed:
              RecitationSpeed.values.asNameMap()[stored.speed] ??
              defaults.speed,
          quality:
              RecitationQuality.values.asNameMap()[stored.quality] ??
              defaults.quality,
          continuous: stored.continuous ?? defaults.continuous,
        ),
      );
    } catch (_) {
      return const ApiResult.failure(CacheFailure());
    }
  }

  @override
  Future<ApiResult<void>> saveRecitationSettings(
    RecitationSettings settings,
  ) async {
    try {
      await _local.saveRecitationSettings(
        reciter: settings.reciterId,
        reciterName: settings.reciterName,
        repeat: settings.repeat.name,
        speed: settings.speed.name,
        quality: settings.quality.name,
        continuous: settings.continuous,
      );
      return const ApiResult.success(null);
    } catch (_) {
      return const ApiResult.failure(CacheFailure());
    }
  }

  @override
  Future<ApiResult<CommentarySettings>> getCommentarySettings() async {
    try {
      final stored = await _local.getCommentarySettings();
      final tafsir = stored.tafsir;
      final translation = stored.translation;
      return ApiResult.success(
        CommentarySettings(
          tafsirId:
              tafsir != null && RecitationSettings.isValidEditionId(tafsir)
                  ? tafsir
                  : CommentarySettings.defaults.tafsirId,
          translationId:
              translation != null &&
                      RecitationSettings.isValidEditionId(translation)
                  ? translation
                  : null,
        ),
      );
    } catch (_) {
      return const ApiResult.failure(CacheFailure());
    }
  }

  @override
  Future<ApiResult<void>> saveCommentarySettings(
    CommentarySettings settings,
  ) async {
    try {
      await _local.saveCommentarySettings(
        tafsir: settings.tafsirId,
        translation: settings.translationId,
      );
      return const ApiResult.success(null);
    } catch (_) {
      return const ApiResult.failure(CacheFailure());
    }
  }

  @override
  Future<ApiResult<void>> saveSettings(MushafReaderSettings settings) async {
    try {
      await _local.saveSettings(
        tajweed: settings.tajweedEnabled,
        naturalMadd: settings.naturalMaddEnabled,
        themeMode: settings.themeMode.name,
        layoutMode: settings.layoutMode.name,
        fontScale: settings.fontScale.name,
      );
      return const ApiResult.success(null);
    } catch (_) {
      return const ApiResult.failure(CacheFailure());
    }
  }
}
