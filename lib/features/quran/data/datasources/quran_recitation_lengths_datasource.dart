import 'dart:async';
import 'dart:developer';
import 'dart:math' show min;
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// How long each ayah's recitation lasts, which the service does not say.
/// Read from the head of its file, a few kilobytes of it, so the system's
/// progress bar can span a whole surah though it is played ayah by ayah.
/// What is read is kept for as long as the app runs.
class QuranRecitationLengthsDataSource {
  final Dio _dio;
  final Map<String, Duration> _known = {};

  QuranRecitationLengthsDataSource(this._dio);

  /// The length of the recitation at [url], once read.
  Duration? lengthOf(String url) => _known[url];

  /// Reads the lengths of [urls] not known yet, a few files at a time, until
  /// [cancel] says they are no longer needed. Stops at the first file that
  /// cannot be read, as the bar needs every one of them; those left are
  /// read the next time they are asked for. Never throws.
  Future<void> read(Iterable<String> urls, {required CancelToken cancel}) {
    final pending = [
      for (final url in urls.toSet())
        if (!_known.containsKey(url)) url,
    ];
    var next = 0;
    var failed = false;

    Future<void> readNext() async {
      while (!failed && !cancel.isCancelled && next < pending.length) {
        final url = pending[next++];
        try {
          final length = await _readLength(url, cancel);
          if (length == null) {
            failed = true;
            log('Quran recitation length unreadable: $url');
          } else {
            _known[url] = length;
          }
        } catch (error, stackTrace) {
          if (!failed &&
              !(error is DioException && CancelToken.isCancel(error))) {
            log(
              'Quran recitation length unavailable',
              error: error,
              stackTrace: stackTrace,
            );
          }
          failed = true;
        }
      }
    }

    return Future.wait([
      for (var i = 0; i < _filesAtOnce; i++) readNext(),
    ]).then((_) {});
  }

  Future<Duration?> _readLength(String url, CancelToken cancel) async {
    final head = await _fetch(url, 0, _headBytes, cancel);
    if (head == null) return null;
    final (bytes, size) = head;
    final start = Mp3Head.audioStart(bytes);
    if (start >= size) return null;
    Uint8List? frame = Uint8List.sublistView(bytes, min(start, bytes.length));
    if (frame.length < _frameBytes && bytes.length < size) {
      // A tag at the head longer than what was read: the audio after it.
      frame = (await _fetch(url, start, _tagTailBytes, cancel))?.$1;
    }
    if (frame == null) return null;
    return Mp3Head.length(frame, audioBytes: size - start);
  }

  /// Up to [count] bytes of the file at [url] from [from], and the whole
  /// file's size; null unless the service sends just that range, as one
  /// sending the whole file instead is left unread.
  Future<(Uint8List, int)?> _fetch(
    String url,
    int from,
    int count,
    CancelToken cancel,
  ) async {
    final response = await _dio.get<ResponseBody>(
      url,
      cancelToken: cancel,
      options: Options(
        responseType: ResponseType.stream,
        headers: {
          'range': 'bytes=$from-${from + count - 1}',
          // Asked for compressed, the service sends the whole file instead.
          'accept-encoding': 'identity',
        },
      ),
    );
    final body = response.data;
    if (body == null) return null;
    final size =
        response.statusCode == 206
            ? int.tryParse(
              response.headers.value('content-range')?.split('/').last ?? '',
            )
            : null;
    if (size == null) {
      await body.stream.listen(null).cancel();
      return null;
    }
    final bytes = BytesBuilder(copy: false);
    await for (final chunk in body.stream) {
      bytes.add(chunk);
      if (bytes.length >= count) break;
    }
    return (bytes.takeBytes(), size);
  }

  /// Enough for the tag the service puts at the head of its files, and the
  /// first frame of audio after it.
  static const _headBytes = 4096;

  /// Of the first frame, enough to hold its Xing, Info or VBRI tag.
  static const _frameBytes = 512;

  /// After a tag longer than [_headBytes], enough to find the first frame.
  static const _tagTailBytes = 2048;

  static const _filesAtOnce = 6;
}

/// The length of an MP3 file, from its head.
abstract final class Mp3Head {
  /// Where the audio starts in [bytes], the head of the file: after the
  /// ID3v2 tag there, if any.
  static int audioStart(Uint8List bytes) {
    if (bytes.length < 10 || String.fromCharCodes(bytes, 0, 3) != 'ID3') {
      return 0;
    }
    final size =
        (bytes[6] & 0x7f) << 21 |
        (bytes[7] & 0x7f) << 14 |
        (bytes[8] & 0x7f) << 7 |
        (bytes[9] & 0x7f);
    final hasFooter = (bytes[5] & 0x10) != 0;
    return 10 + size + (hasFooter ? 10 : 0);
  }

  /// How long [audioBytes] of MPEG Layer III audio last, [bytes] being
  /// where they start: exactly, from the frame count of the Xing, Info or
  /// VBRI tag in the first frame; else from its bitrate, as for a file of a
  /// constant one. Null when [bytes] hold no frame.
  static Duration? length(Uint8List bytes, {required int audioBytes}) {
    for (var at = 0; at + 4 <= bytes.length; at++) {
      final frame = _Frame.at(bytes, at);
      if (frame == null) continue;
      final frames = frame.taggedFrameCount(bytes, at);
      if (frames != null) {
        return Duration(
          microseconds:
              frames *
              frame.samples *
              Duration.microsecondsPerSecond ~/
              frame.sampleRate,
        );
      }
      return Duration(
        microseconds:
            (audioBytes - at) *
            8 *
            Duration.microsecondsPerSecond ~/
            frame.bitrate,
      );
    }
    return null;
  }
}

/// The header of an MPEG Layer III frame.
class _Frame {
  final bool mpeg1;
  final bool mono;

  /// In bits a second.
  final int bitrate;
  final int sampleRate;

  const _Frame({
    required this.mpeg1,
    required this.mono,
    required this.bitrate,
    required this.sampleRate,
  });

  /// The header at [at] in [bytes], if one is there.
  static _Frame? at(Uint8List bytes, int at) {
    if (at + 4 > bytes.length || bytes[at] != 0xff) return null;
    final b1 = bytes[at + 1], b2 = bytes[at + 2], b3 = bytes[at + 3];
    if ((b1 & 0xe0) != 0xe0) return null;
    // 3: MPEG-1, 2: MPEG-2, 0: MPEG-2.5. Layer 1 is Layer III.
    final version = (b1 >> 3) & 3;
    final layer = (b1 >> 1) & 3;
    final bitrateIndex = b2 >> 4;
    final rateIndex = (b2 >> 2) & 3;
    if (version == 1 ||
        layer != 1 ||
        bitrateIndex == 0 ||
        bitrateIndex == 15 ||
        rateIndex == 3) {
      return null;
    }
    final mpeg1 = version == 3;
    return _Frame(
      mpeg1: mpeg1,
      mono: (b3 >> 6) == 3,
      bitrate: (mpeg1 ? _mpeg1Kbps : _mpeg2Kbps)[bitrateIndex] * 1000,
      sampleRate:
          _mpeg1Rates[rateIndex] ~/
          switch (version) {
            3 => 1,
            2 => 2,
            _ => 4,
          },
    );
  }

  int get samples => mpeg1 ? 1152 : 576;

  /// The frame count the Xing, Info or VBRI tag in this frame, at [at] in
  /// [bytes], gives; null without one.
  int? taggedFrameCount(Uint8List bytes, int at) {
    final sideInfo = mpeg1 ? (mono ? 17 : 32) : (mono ? 9 : 17);
    // After the side information, or after the checksum before it too.
    for (final tag in [at + 4 + sideInfo, at + 6 + sideInfo]) {
      if (tag + 12 > bytes.length) break;
      final name = String.fromCharCodes(bytes, tag, tag + 4);
      if (name != 'Xing' && name != 'Info') continue;
      final flags = _uint32(bytes, tag + 4);
      return (flags & 1) == 0 ? null : _uint32(bytes, tag + 8);
    }
    // Fraunhofer's, always 32 bytes after the header.
    final vbri = at + 36;
    if (vbri + 18 <= bytes.length &&
        String.fromCharCodes(bytes, vbri, vbri + 4) == 'VBRI') {
      return _uint32(bytes, vbri + 14);
    }
    return null;
  }

  static int _uint32(Uint8List bytes, int at) =>
      bytes[at] << 24 |
      bytes[at + 1] << 16 |
      bytes[at + 2] << 8 |
      bytes[at + 3];

  static const _mpeg1Kbps = [
    0, 32, 40, 48, 56, 64, 80, 96, 112, 128, 160, 192, 224, 256, 320, //
  ];
  static const _mpeg2Kbps = [
    0, 8, 16, 24, 32, 40, 48, 56, 64, 80, 96, 112, 128, 144, 160, //
  ];
  static const _mpeg1Rates = [44100, 48000, 32000];
}
