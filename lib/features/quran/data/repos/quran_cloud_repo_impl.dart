import 'dart:collection';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_error_handler.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../../domain/entities/quran_commentary.dart';
import '../../domain/entities/quran_edition.dart';
import '../../domain/entities/quran_edition_search.dart';
import '../../domain/entities/quran_hizb_quarter.dart';
import '../../domain/entities/quran_metrics.dart';
import '../../domain/entities/recitation.dart';
import '../../domain/repos/quran_cloud_repo.dart';
import '../datasources/quran_cloud_cache_local_datasource.dart';
import '../datasources/quran_cloud_remote_datasource.dart';
import '../mappers/quran_cloud_mappers.dart';
import '../models/quran_cloud_models.dart';

class QuranCloudRepoImpl implements QuranCloudRepo {
  /// Edition lists change rarely; a week-old copy is used without asking,
  /// and an older one still beats nothing when the service cannot be
  /// reached.
  static const Duration editionsMaxAge = Duration(days: 7);

  final QuranCloudRemoteDataSource _remote;
  final QuranCloudCacheLocalDataSource _cache;
  final DateTime Function() _now;

  final Map<QuranEditionType, List<QuranEdition>> _editions = {};
  final Map<QuranEditionType, Future<ApiResult<List<QuranEdition>>>>
  _editionLoads = {};
  List<QuranAyahRef>? _hizbStarts;
  Future<ApiResult<List<QuranAyahRef>>>? _hizbLoad;

  /// A surah or juz played again, or carried on into, starts at once.
  final _LruCache<String, List<RecitationAudio>> _recitations = _LruCache(8);

  /// An ayah sheet opened again shows its tafsir at once.
  final _LruCache<String, List<EditionText>> _ayahTexts = _LruCache(200);

  QuranCloudRepoImpl(this._remote, this._cache, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  // ── editions ────────────────────────────────────────────────────────────

  @override
  Future<ApiResult<List<QuranEdition>>> getEditions(QuranEditionType type) {
    final cached = _editions[type];
    if (cached != null) return Future.value(ApiResult.success(cached));
    // Pickers opened while the list is loading share the one request; a
    // failed load is forgotten so the next can try again.
    // A block body: an arrow would hand whenComplete the removed entry —
    // this very load — and it would wait on itself forever.
    return _editionLoads[type] ??= _loadEditions(type).whenComplete(() {
      _editionLoads.remove(type);
    });
  }

  Future<ApiResult<List<QuranEdition>>> _loadEditions(
    QuranEditionType type,
  ) async {
    final key = type.name;
    final stored = await _guardCache(() => _cache.getEditions(key));
    final storedEditions =
        stored == null
            ? const <QuranEdition>[]
            : _editionsOf(stored.editions, type);
    if (stored != null &&
        storedEditions.isNotEmpty &&
        _now().difference(stored.savedAt) < editionsMaxAge) {
      return ApiResult.success(_editions[type] = storedEditions);
    }

    try {
      final (format, apiType) = switch (type) {
        QuranEditionType.recitation => ('audio', 'versebyverse'),
        QuranEditionType.tafsir => ('text', 'tafsir'),
        QuranEditionType.translation => ('text', 'translation'),
      };
      final models = await _remote.getEditions(format: format, type: apiType);
      final editions = _editionsOf(models, type);
      if (editions.isEmpty) {
        throw const QuranCloudFormatException('no usable editions');
      }
      await _guardCache(
        () => _cache.saveEditions(key, models, savedAt: _now()),
      );
      return ApiResult.success(_editions[type] = editions);
    } catch (error, stackTrace) {
      log('Quran editions failed', error: error, stackTrace: stackTrace);
      if (storedEditions.isNotEmpty) {
        return ApiResult.success(_editions[type] = storedEditions);
      }
      return ApiResult.failure(_failureOf(error));
    }
  }

  static List<QuranEdition> _editionsOf(
    Iterable<QuranEditionModel> models,
    QuranEditionType type,
  ) => List.unmodifiable([
    for (final model in models)
      if (model.toEntity() case final edition? when edition.type == type)
        edition,
  ]);

  // ── recitation ──────────────────────────────────────────────────────────

  @override
  Future<ApiResult<List<RecitationAudio>>> getRecitation(
    String reciterId,
    RecitationScope scope,
  ) async {
    if (!scope.isValid) return const ApiResult.failure(UnexpectedFailure());
    final key = '$reciterId|${scope.kind.name}|${scope.number}';
    final cached = _recitations[key];
    if (cached != null) return ApiResult.success(cached);

    try {
      final group = await _remote.getDivision(
        _divisionOf(scope.kind),
        scope.number,
        reciterId,
      );
      // An unknown reciter comes back as the default text: another
      // edition, and no audio.
      final edition = group.edition;
      if (edition != null && edition.identifier != reciterId) {
        return const ApiResult.failure(
          ServerFailure(FailureMessages.audioUnavailable),
        );
      }
      final audio = List<RecitationAudio>.unmodifiable([
        for (final ayah in group.ayahs)
          if (ayah.toRecitationAudio() case final entry?) entry,
      ]);
      if (audio.isEmpty) {
        return const ApiResult.failure(
          ServerFailure(FailureMessages.audioUnavailable),
        );
      }
      _recitations[key] = audio;
      return ApiResult.success(audio);
    } catch (error, stackTrace) {
      log('Quran recitation failed', error: error, stackTrace: stackTrace);
      return ApiResult.failure(_failureOf(error, audio: true));
    }
  }

  static String _divisionOf(RecitationScopeKind kind) => switch (kind) {
    RecitationScopeKind.surah => 'surah',
    RecitationScopeKind.page => 'page',
    RecitationScopeKind.juz => 'juz',
    RecitationScopeKind.hizbQuarter => 'hizbQuarter',
  };

  // ── tafsir and translations ─────────────────────────────────────────────

  @override
  Future<ApiResult<List<EditionText>>> getAyahTexts(
    int ayahId,
    List<String> editionIds,
  ) async {
    if (!QuranMetrics.isValidAyahId(ayahId) || editionIds.isEmpty) {
      return const ApiResult.failure(UnexpectedFailure());
    }
    final key = '$ayahId|${editionIds.join(',')}';
    final cached = _ayahTexts[key];
    if (cached != null) return ApiResult.success(cached);

    try {
      final models = await _remote.getAyahEditions(ayahId, editionIds);
      final byEdition = <String, EditionText>{};
      for (final model in models) {
        final entry = model.toEditionText();
        // An unknown edition comes back as the default text instead.
        if (entry == null || entry.ayahId != ayahId) continue;
        final id = entry.text.edition.identifier;
        if (editionIds.contains(id)) {
          byEdition.putIfAbsent(id, () => entry.text);
        }
      }
      final texts = List<EditionText>.unmodifiable([
        for (final id in editionIds)
          if (byEdition[id] case final text?) text,
      ]);
      _ayahTexts[key] = texts;
      return ApiResult.success(texts);
    } catch (error, stackTrace) {
      log('Quran ayah texts failed', error: error, stackTrace: stackTrace);
      return ApiResult.failure(_failureOf(error));
    }
  }

  @override
  Future<ApiResult<List<AyahEditionText>>> getSurahTexts(
    int surahNumber,
    List<String> editionIds, {
    required int offset,
    required int limit,
  }) async {
    if (surahNumber < 1 ||
        surahNumber > QuranMetrics.surahCount ||
        editionIds.isEmpty ||
        offset < 0 ||
        limit < 1) {
      return const ApiResult.failure(UnexpectedFailure());
    }
    try {
      final groups = await _remote.getSurahEditions(
        surahNumber,
        editionIds,
        offset: offset,
        limit: limit,
      );
      return ApiResult.success([
        for (final group in groups)
          if (group.edition case final edition?
              when editionIds.contains(edition.identifier))
            for (final ayah in group.ayahs)
              if (ayah.toEditionText(parent: edition) case final text?) text,
      ]);
    } catch (error, stackTrace) {
      log('Quran surah texts failed', error: error, stackTrace: stackTrace);
      return ApiResult.failure(_failureOf(error));
    }
  }

  @override
  Future<ApiResult<EditionSearchMatches>> searchEdition(
    String query,
    String editionId, {
    required int offset,
    required int limit,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty || offset < 0 || limit < 1) {
      return const ApiResult.failure(UnexpectedFailure());
    }
    try {
      final result = await _remote.search(
        trimmed,
        editionId,
        offset: offset,
        limit: limit,
      );
      final matches = [
        for (final match in result.matches)
          if (QuranMetrics.isValidAyahId(match.number) &&
              match.text.trim().isNotEmpty &&
              (match.edition == null || match.edition!.identifier == editionId))
            AyahEditionMatch(
              ayahId: match.number,
              text: match.text,
              edition: match.edition?.toEntity(),
            ),
      ];
      return ApiResult.success(
        EditionSearchMatches(
          matches: List.unmodifiable(matches),
          total:
              result.total < offset + result.matches.length
                  ? offset + result.matches.length
                  : result.total,
        ),
      );
    } catch (error, stackTrace) {
      log('Quran edition search failed', error: error, stackTrace: stackTrace);
      return ApiResult.failure(_failureOf(error));
    }
  }

  @override
  Future<ApiResult<AyahEditionText>> getRandomAyahText(String editionId) async {
    try {
      final model = await _remote.getRandomAyah(editionId);
      final entry = model.toEditionText();
      if (entry == null || entry.text.edition.identifier != editionId) {
        return const ApiResult.failure(ServerFailure());
      }
      return ApiResult.success(entry);
    } catch (error, stackTrace) {
      log('Quran random ayah failed', error: error, stackTrace: stackTrace);
      return ApiResult.failure(_failureOf(error));
    }
  }

  // ── hizb index ──────────────────────────────────────────────────────────

  @override
  Future<ApiResult<List<QuranAyahRef>>> getHizbQuarterStarts() {
    final cached = _hizbStarts;
    if (cached != null) return Future.value(ApiResult.success(cached));
    return _hizbLoad ??= _loadHizbStarts().whenComplete(() => _hizbLoad = null);
  }

  Future<ApiResult<List<QuranAyahRef>>> _loadHizbStarts() async {
    final stored = await _guardCache(_cache.getHizbQuarterStarts);
    if (stored != null && stored.length == QuranMetrics.hizbQuarterCount) {
      return ApiResult.success(_hizbStarts = List.unmodifiable(stored));
    }
    try {
      final starts = await _remote.getHizbQuarterStarts();
      if (starts.length != QuranMetrics.hizbQuarterCount) {
        throw const QuranCloudFormatException('hizb quarter count');
      }
      await _guardCache(() => _cache.saveHizbQuarterStarts(starts));
      return ApiResult.success(_hizbStarts = List.unmodifiable(starts));
    } catch (error, stackTrace) {
      log('Quran hizb index failed', error: error, stackTrace: stackTrace);
      return ApiResult.failure(_failureOf(error));
    }
  }

  // ── failures ────────────────────────────────────────────────────────────

  /// A reply from the service means it refused or garbled the request; no
  /// reply means the connection.
  static Failure _failureOf(Object error, {bool audio = false}) {
    final message =
        audio ? FailureMessages.audioUnavailable : FailureMessages.server;
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      if (statusCode != null) return ServerFailure(message, statusCode);
      return ErrorHandler.toFailure(error);
    }
    if (error is QuranCloudFormatException || error is ArgumentError) {
      return ServerFailure(message);
    }
    return const UnexpectedFailure();
  }

  /// The device cache only ever speeds things up, so a failure to read or
  /// write it is logged and passed over.
  static Future<T?> _guardCache<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (error, stackTrace) {
      log('Quran cloud cache failed', error: error, stackTrace: stackTrace);
      return null;
    }
  }
}

/// A map that forgets the entry used longest ago once it holds [capacity].
class _LruCache<K, V> {
  final int capacity;
  final LinkedHashMap<K, V> _entries = LinkedHashMap();

  _LruCache(this.capacity);

  V? operator [](K key) {
    final value = _entries.remove(key);
    if (value != null) _entries[key] = value;
    return value;
  }

  void operator []=(K key, V value) {
    _entries.remove(key);
    _entries[key] = value;
    if (_entries.length > capacity) _entries.remove(_entries.keys.first);
  }
}
