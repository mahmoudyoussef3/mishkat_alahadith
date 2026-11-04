import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

/// The recitations of Hisn Al-Muslim, by Hamad Al-Durayhim, from the
/// Islamic-Pro-azkar-API repository: downloaded on first play and kept on the
/// device, so each plays offline from then on.
class AzkarAudioCacheDataSource {
  /// Pinned to the commit the bundled text was taken from, so the CDN keeps
  /// serving the same files whatever changes upstream.
  static const String baseUrl =
      'https://cdn.jsdelivr.net/gh/YousefAsalya/Islamic-Pro-azkar-API'
      '@d793023e3b69c91674023f692425950c8ebbb64d/audio';

  /// A plain file name, so a damaged entry can never reach outside the
  /// cache folder or the audio folder upstream.
  static final RegExp _fileName = RegExp(r'^[A-Za-z0-9_-]+\.mp3$');

  final Dio _dio;
  final Future<Directory> Function() _cacheRoot;
  final Map<String, ({Future<String> path, CancelToken cancel})> _downloads =
      {};

  /// [_dio] must carry no app headers: the files come from a public CDN,
  /// which has no business seeing the user's session token.
  AzkarAudioCacheDataSource(
    this._dio, {
    Future<Directory> Function()? cacheRoot,
  }) : _cacheRoot = cacheRoot ?? getApplicationCacheDirectory;

  /// The path of [fileName] on the device, downloading it first when it is
  /// not there yet. Requests for a file already downloading share it.
  ///
  /// Throws [ArgumentError] for anything but a plain `.mp3` file name, and
  /// [DioException] when the download fails.
  Future<String> resolve(String fileName) async {
    if (!_fileName.hasMatch(fileName)) {
      throw ArgumentError.value(fileName, 'fileName', 'Not an audio file');
    }
    final pending = _downloads[fileName];
    if (pending != null) return pending.path;

    final cancel = CancelToken();
    // A block body: an arrow would hand whenComplete the removed entry's
    // future — this very download — and it would wait on itself forever.
    final path = _fetch(fileName, cancel).whenComplete(() {
      _downloads.remove(fileName);
    });
    _downloads[fileName] = (path: path, cancel: cancel);
    return path;
  }

  /// Abandons the downloads under way, all but [except]'s, so recitations
  /// the reader has moved on from stop using their data.
  void cancelDownloads({String? except}) {
    for (final MapEntry(key: fileName, value: download) in _downloads.entries) {
      if (fileName != except) download.cancel.cancel();
    }
  }

  Future<String> _fetch(String fileName, CancelToken cancel) async {
    final directory = Directory('${(await _cacheRoot()).path}/azkar_audio');
    final file = File('${directory.path}/$fileName');
    if (await file.exists() && await file.length() > 0) return file.path;

    await directory.create(recursive: true);
    // Written beside the final name and moved into place only once whole,
    // so a dropped connection never leaves half a file to be played later.
    final partial = File('${file.path}.part');
    try {
      await _dio.download(
        '$baseUrl/$fileName',
        partial.path,
        cancelToken: cancel,
      );
      await partial.rename(file.path);
    } catch (_) {
      if (await partial.exists()) await partial.delete();
      rethrow;
    }
    return file.path;
  }
}
