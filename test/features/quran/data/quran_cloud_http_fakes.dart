import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// A reply from the fake service: a status and a JSON body.
typedef FakeReply = ({int status, Object? body});

FakeReply ok(Object? data) => (
  status: 200,
  body: {'code': 200, 'status': 'OK', 'data': data},
);

FakeReply notFound(String message) => (
  status: 404,
  body: {'code': 404, 'status': 'NOT FOUND', 'data': message},
);

/// Answers every request from [reply] and records what was asked.
///
/// [reply] may throw a [DioException] to fail as the network would, and
/// may hold the reply back on a [gate] to order concurrent requests.
class FakeQuranCloudAdapter implements HttpClientAdapter {
  FutureOr<FakeReply> Function(RequestOptions options) reply;
  final List<RequestOptions> requests = [];
  Completer<void>? gate;

  FakeQuranCloudAdapter(this.reply);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    await gate?.future;
    final answer = await reply(options);
    return ResponseBody.fromString(
      jsonEncode(answer.body),
      answer.status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// A Dio with no app headers, over [adapter].
Dio dioOver(FakeQuranCloudAdapter adapter) =>
    Dio()..httpClientAdapter = adapter;

Map<String, dynamic> edition(
  String identifier, {
  String format = 'text',
  String type = 'tafsir',
  String language = 'ar',
  String? name,
}) => {
  'identifier': identifier,
  'language': language,
  'name': name ?? identifier,
  'englishName': identifier,
  'format': format,
  'type': type,
  'direction': format == 'audio' ? null : 'rtl',
};

Map<String, dynamic> audioAyah(int number, {String reciter = 'ar.alafasy'}) => {
  'number': number,
  'audio': 'https://cdn.islamic.network/quran/audio/128/$reciter/$number.mp3',
  'audioSecondary': [
    'https://cdn.islamic.network/quran/audio/64/$reciter/$number.mp3',
  ],
  'text': 'نص الآية $number',
  'numberInSurah': number,
};

/// The default Arabic text the service sends for an edition it does not
/// know.
Map<String, dynamic> get defaultTextEdition =>
    edition('quran-uthmani-quran-academy', type: 'quran');

/// Where the 240 hizb quarters begin, as `/meta` lists them.
List<Map<String, int>> hizbReferences([int count = 240]) => [
  for (var i = 0; i < count; i++) {'surah': 2 + i ~/ 10, 'ayah': 1 + i % 10},
];
