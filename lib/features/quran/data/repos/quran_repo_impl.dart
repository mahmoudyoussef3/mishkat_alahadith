import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../../domain/entities/quran_ayah.dart';
import '../../domain/entities/quran_surah.dart';
import '../../domain/entities/tajweed_info.dart';
import '../../domain/repos/quran_repo.dart';
import '../datasources/quran_text_local_datasource.dart';
import '../mappers/quran_mappers.dart';

class QuranRepoImpl implements QuranRepo {
  static const String _loadFailedMessage = 'تعذر تحميل نص المصحف';

  final QuranTextLocalDataSource _local;

  List<QuranSurah>? _surahs;
  List<QuranAyah>? _ayahs;

  QuranRepoImpl(this._local);

  @override
  Future<ApiResult<List<QuranSurah>>> getSurahs() async {
    try {
      return ApiResult.success(
        _surahs ??= List.unmodifiable(
          _local.getSurahs().map((s) => s.toEntity()),
        ),
      );
    } catch (_) {
      return const ApiResult.failure(CacheFailure(_loadFailedMessage));
    }
  }

  @override
  Future<ApiResult<List<QuranAyah>>> getAllAyahs() async {
    try {
      final cached = _ayahs;
      if (cached != null) return ApiResult.success(cached);
      final ayahs = List<QuranAyah>.unmodifiable(
        (await _local.getAllAyahs()).map((a) => a.toEntity()),
      );
      _ayahs = ayahs;
      return ApiResult.success(ayahs);
    } catch (_) {
      return const ApiResult.failure(CacheFailure(_loadFailedMessage));
    }
  }

  @override
  Future<ApiResult<List<QuranAyah>>> getPageAyahs(int page) async {
    try {
      final ayahs = await _local.getPageAyahs(page);
      return ApiResult.success([for (final a in ayahs) a.toEntity()]);
    } catch (_) {
      return const ApiResult.failure(CacheFailure(_loadFailedMessage));
    }
  }

  @override
  Future<ApiResult<QuranAyah>> getAyah(int ayahId) async {
    try {
      final ayah = await _local.getAyah(ayahId);
      if (ayah == null) return const ApiResult.failure(UnexpectedFailure());
      return ApiResult.success(ayah.toEntity());
    } catch (_) {
      return const ApiResult.failure(CacheFailure(_loadFailedMessage));
    }
  }

  @override
  Future<ApiResult<List<TajweedSegment>>> getAyahTajweed(
    int ayahId, {
    required bool includeNaturalMadd,
  }) async {
    try {
      final ayah = await _local.getAyah(ayahId);
      if (ayah == null) return const ApiResult.failure(UnexpectedFailure());
      final spans = _local.annotate(
        ayah.text,
        includeNaturalMadd: includeNaturalMadd,
      );
      return ApiResult.success([for (final s in spans) s.toEntity()]);
    } catch (_) {
      return const ApiResult.failure(CacheFailure(_loadFailedMessage));
    }
  }

  @override
  Future<ApiResult<List<TajweedRuleCount>>> getPageTajweedCounts(
    int page, {
    required bool includeNaturalMadd,
  }) async {
    try {
      final counts = await _local.getPageTajweedCounts(
        page,
        includeNaturalMadd: includeNaturalMadd,
      );
      return ApiResult.success([for (final c in counts) c.toEntity()]);
    } catch (_) {
      return const ApiResult.failure(CacheFailure(_loadFailedMessage));
    }
  }
}
