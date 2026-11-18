import 'dart:math';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/features/quran/data/datasources/quran_recitation_lengths_datasource.dart';

/// An ID3v2 tag of [size] bytes after its header, as a file's head.
List<int> _id3(int size, {bool footer = false}) => [
  ...'ID3'.codeUnits,
  4,
  0,
  footer ? 0x10 : 0,
  (size >> 21) & 0x7f,
  (size >> 14) & 0x7f,
  (size >> 7) & 0x7f,
  size & 0x7f,
  ...List.filled(size, 0),
];

/// The first frame of MPEG-1 Layer III audio at 128 kbps and 44.1 kHz, in
/// joint stereo, carrying an Info tag that counts [frames] when given.
List<int> _mpeg1Frame({int? frames}) => [
  0xff, 0xfb, 0x90, 0x44, //
  ...List.filled(32, 0),
  if (frames != null) ...[
    ...'Info'.codeUnits,
    0, 0, 0, 0x0f, //
    ...[frames >> 24, frames >> 16, frames >> 8, frames].map((b) => b & 0xff),
  ],
  ...List.filled(400, 0),
];

/// The first frame of MPEG-2 Layer III audio at 64 kbps and 22.05 kHz, in
/// mono, carrying a Xing tag that counts [frames].
List<int> _mpeg2MonoFrame({required int frames}) => [
  0xff, 0xf3, 0x80, 0xc0, //
  ...List.filled(9, 0),
  ...'Xing'.codeUnits,
  0, 0, 0, 0x01, //
  0, 0, frames >> 8, frames & 0xff,
  ...List.filled(400, 0),
];

/// A file of [size] bytes starting with [head].
Uint8List _file(List<int> head, int size) =>
    Uint8List(size)..setRange(0, head.length, head);

/// Serves [files] by URL, a range of them at a time unless [wholeFiles] —
/// or, as the real service does, unless asked for them uncompressed.
class _FakeCdn implements HttpClientAdapter {
  final Map<String, Uint8List> files;
  final bool wholeFiles;
  final List<String> ranges = [];

  _FakeCdn(this.files, {this.wholeFiles = false});

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final range = options.headers['range'] as String;
    ranges.add('${options.uri} $range');
    final file = files['${options.uri}'];
    if (file == null) {
      throw DioException.connectionError(
        requestOptions: options,
        reason: 'offline',
      );
    }
    if (wholeFiles || options.headers['accept-encoding'] != 'identity') {
      return ResponseBody.fromBytes(file, 200);
    }
    final [from, to] = range.substring('bytes='.length).split('-');
    final start = int.parse(from);
    final end = min(int.parse(to) + 1, file.length);
    return ResponseBody.fromBytes(
      Uint8List.sublistView(file, start, end),
      206,
      headers: {
        'content-range': ['bytes $start-${end - 1}/${file.length}'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('Mp3Head.audioStart', () {
    test('is the head of a file without a tag', () {
      expect(Mp3Head.audioStart(Uint8List.fromList(_mpeg1Frame())), 0);
    });

    test('is after the tag at the head', () {
      expect(Mp3Head.audioStart(Uint8List.fromList(_id3(393))), 403);
    });

    test('is after the tag and its footer', () {
      expect(
        Mp3Head.audioStart(Uint8List.fromList(_id3(393, footer: true))),
        413,
      );
    });
  });

  group('Mp3Head.length', () {
    test('counts the frames the Info tag gives', () {
      final head = Uint8List.fromList(_mpeg1Frame(frames: 293));

      expect(
        Mp3Head.length(head, audioBytes: 123007),
        const Duration(microseconds: 293 * 1152 * 1000000 ~/ 44100),
      );
    });

    test('counts the frames of MPEG-2 audio in mono', () {
      final head = Uint8List.fromList(_mpeg2MonoFrame(frames: 100));

      expect(
        Mp3Head.length(head, audioBytes: 50000),
        const Duration(microseconds: 100 * 576 * 1000000 ~/ 22050),
      );
    });

    test('counts the frames the VBRI tag gives', () {
      final head = Uint8List.fromList([
        0xff, 0xfb, 0x90, 0x44, //
        ...List.filled(32, 0),
        ...'VBRI'.codeUnits,
        0, 1, 0, 0, 0, 75, 0, 1, 0xe0, 0x2f, //
        0, 0, 0x01, 0x25,
        ...List.filled(400, 0),
      ]);

      expect(
        Mp3Head.length(head, audioBytes: 123007),
        const Duration(microseconds: 293 * 1152 * 1000000 ~/ 44100),
      );
    });

    test('without a tag, reads it from the bitrate', () {
      final head = Uint8List.fromList(_mpeg1Frame());

      expect(
        Mp3Head.length(head, audioBytes: 160000),
        const Duration(seconds: 10),
      );
    });

    test('finds the first frame past padding', () {
      final head = Uint8List.fromList([0, 0, 0, ..._mpeg1Frame()]);

      expect(
        Mp3Head.length(head, audioBytes: 160003),
        const Duration(seconds: 10),
      );
    });

    test('is unknown for what is not MPEG audio', () {
      final head = Uint8List.fromList(List.filled(600, 0x20));

      expect(Mp3Head.length(head, audioBytes: 600), isNull);
    });
  });

  group('read', () {
    const url = 'https://cdn.example/1.mp3';

    QuranRecitationLengthsDataSource over(_FakeCdn cdn) =>
        QuranRecitationLengthsDataSource(Dio()..httpClientAdapter = cdn);

    test('reads a length from the head of the file alone', () async {
      final cdn = _FakeCdn({url: _file(_mpeg1Frame(), 160000)});
      final lengths = over(cdn);

      await lengths.read([url], cancel: CancelToken());

      expect(lengths.lengthOf(url), const Duration(seconds: 10));
      expect(cdn.ranges, ['$url bytes=0-4095']);
    });

    test('reads past a tag longer than the head', () async {
      final cdn = _FakeCdn({
        url: _file([..._id3(5000), ..._mpeg1Frame()], 5010 + 160000),
      });
      final lengths = over(cdn);

      await lengths.read([url], cancel: CancelToken());

      expect(lengths.lengthOf(url), const Duration(seconds: 10));
      expect(cdn.ranges.last, '$url bytes=5010-7057');
    });

    test('leaves a file sent whole unread, rather than download it', () async {
      final cdn = _FakeCdn({
        url: _file(_mpeg1Frame(), 16000),
      }, wholeFiles: true);
      final lengths = over(cdn);

      await lengths.read([url], cancel: CancelToken());

      expect(lengths.lengthOf(url), isNull);
    });

    test('reads a file once, however often asked', () async {
      final cdn = _FakeCdn({url: _file(_mpeg1Frame(), 160000)});
      final lengths = over(cdn);

      await lengths.read([url, url], cancel: CancelToken());
      await lengths.read([url], cancel: CancelToken());

      expect(cdn.ranges, hasLength(1));
    });

    test('reads nothing once called off', () async {
      final cdn = _FakeCdn({url: _file(_mpeg1Frame(), 160000)});
      final lengths = over(cdn);

      await lengths.read([url], cancel: CancelToken()..cancel());

      expect(cdn.ranges, isEmpty);
      expect(lengths.lengthOf(url), isNull);
    });

    test('stops at the first file it cannot read, without throwing', () async {
      final cdn = _FakeCdn({});
      final lengths = over(cdn);
      final urls = [for (var i = 0; i < 20; i++) 'https://cdn.example/$i.mp3'];

      await expectLater(lengths.read(urls, cancel: CancelToken()), completes);

      expect(cdn.ranges.length, lessThan(urls.length));
      expect(lengths.lengthOf(urls.first), isNull);
    });

    test('tries a file it could not read again when asked again', () async {
      final cdn = _FakeCdn({});
      final lengths = over(cdn);
      await lengths.read([url], cancel: CancelToken());

      cdn.files[url] = _file(_mpeg1Frame(), 160000);
      await lengths.read([url], cancel: CancelToken());

      expect(lengths.lengthOf(url), const Duration(seconds: 10));
    });
  });
}
