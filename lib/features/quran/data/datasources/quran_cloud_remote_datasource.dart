import 'package:dio/dio.dart';

import '../../domain/entities/recitation_settings.dart';
import '../models/quran_cloud_models.dart';

/// A response that is not what the service promises.
class QuranCloudFormatException implements Exception {
  final String message;

  const QuranCloudFormatException(this.message);

  @override
  String toString() => 'QuranCloudFormatException: $message';
}

/// AlQuran Cloud (https://alquran.cloud/api).
///
/// Every answer comes as `{code, status, data}`. Two quirks shape this
/// class: an unknown edition is quietly swapped for the default Arabic text
/// rather than refused, so callers check the edition that came back; and a
/// search that finds nothing answers 404, which is read here as no matches.
///
/// Throws [DioException] when the request fails, [ArgumentError] for an
/// identifier that could reshape the request, and
/// [QuranCloudFormatException] for an answer it cannot read.
class QuranCloudRemoteDataSource {
  static const String baseUrl = 'https://api.alquran.cloud/v1/';

  final Dio _dio;

  /// [_dio] must carry no app headers: the service is a third party, with
  /// no business seeing the user's session token.
  QuranCloudRemoteDataSource(this._dio);

  /// Editions in [format] (`text`, `audio`) of [type] (`tafsir`,
  /// `translation`, `versebyverse`).
  Future<List<QuranEditionModel>> getEditions({
    required String format,
    required String type,
  }) async {
    final data = await _get('edition', query: {'format': format, 'type': type});
    if (data is! List) throw const QuranCloudFormatException('editions');
    return [
      for (final entry in data)
        if (QuranEditionModel.tryFromJson(entry) case final edition?) edition,
    ];
  }

  /// The ayahs of one surah, page, juz or hizb quarter in [edition].
  /// [division] is the service's name for it: `surah`, `page`, `juz` or
  /// `hizbQuarter`.
  Future<CloudAyahGroupModel> getDivision(
    String division,
    int number,
    String edition,
  ) async {
    _checkEdition(edition);
    final data = await _get('$division/$number/$edition');
    return CloudAyahGroupModel.tryFromJson(data) ??
        (throw const QuranCloudFormatException('division'));
  }

  /// One ayah in each of [editions], each naming its edition.
  Future<List<CloudAyahModel>> getAyahEditions(
    int ayah,
    List<String> editions,
  ) async {
    editions.forEach(_checkEdition);
    final data = await _get('ayah/$ayah/editions/${editions.join(',')}');
    return switch (data) {
      final List<dynamic> list => CloudAyahModel.listFromJson(list),
      final Map<String, dynamic> single => CloudAyahModel.listFromJson([
        single,
      ]),
      _ => throw const QuranCloudFormatException('ayah editions'),
    };
  }

  /// [limit] ayahs of a surah from [offset] (from 0), once per edition.
  Future<List<CloudAyahGroupModel>> getSurahEditions(
    int surah,
    List<String> editions, {
    required int offset,
    required int limit,
  }) async {
    editions.forEach(_checkEdition);
    final data = await _get(
      'surah/$surah/editions/${editions.join(',')}',
      query: {'offset': offset, 'limit': limit},
    );
    final groups = switch (data) {
      final List<dynamic> list => list,
      final Map<String, dynamic> single => [single],
      _ => throw const QuranCloudFormatException('surah editions'),
    };
    return [
      for (final group in groups)
        if (CloudAyahGroupModel.tryFromJson(group) case final model?) model,
    ];
  }

  /// The passages of [edition] containing [query], [limit] from [offset].
  Future<CloudSearchModel> search(
    String query,
    String edition, {
    required int offset,
    required int limit,
  }) async {
    _checkEdition(edition);
    try {
      final data = await _get(
        'search/${Uri.encodeComponent(query)}/all/$edition',
        query: {'offset': offset, 'limit': limit},
      );
      return CloudSearchModel.tryFromJson(data) ??
          (throw const QuranCloudFormatException('search'));
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) return CloudSearchModel.empty;
      rethrow;
    }
  }

  Future<CloudAyahModel> getRandomAyah(String edition) async {
    _checkEdition(edition);
    final data = await _get('ayah/random/$edition');
    return CloudAyahModel.tryFromJson(data) ??
        (throw const QuranCloudFormatException('random ayah'));
  }

  /// Where each hizb quarter begins, from the service's metadata.
  Future<List<({int surah, int ayah})>> getHizbQuarterStarts() async {
    final data = await _get('meta');
    final references = switch (data) {
      {'hizbQuarters': {'references': final List<dynamic> refs}} => refs,
      _ => throw const QuranCloudFormatException('meta'),
    };
    return [
      for (final ref in references)
        switch (ref) {
          {'surah': final int surah, 'ayah': final int ayah} => (
            surah: surah,
            ayah: ayah,
          ),
          _ => throw const QuranCloudFormatException('hizb reference'),
        },
    ];
  }

  /// The `data` of a successful answer.
  Future<Object?> _get(String path, {Map<String, Object>? query}) async {
    final response = await _dio.get<Object?>(
      '$baseUrl$path',
      queryParameters: query,
    );
    return switch (response.data) {
      {'code': 200, 'data': final Object? data} => data,
      _ => throw QuranCloudFormatException('envelope of $path'),
    };
  }

  static void _checkEdition(String edition) {
    if (!RecitationSettings.isValidEditionId(edition)) {
      throw ArgumentError.value(edition, 'edition', 'Not an edition id');
    }
  }
}
