import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/helpers/deep_linker_helper.dart';

void main() {
  group('DeepLinkHandler', () {
    late StreamController<Uri> links;
    late List<Object> errors;
    late DeepLinkHandler handler;

    setUp(() {
      // app_links exposes a broadcast stream.
      links = StreamController<Uri>.broadcast();
      errors = [];
      handler = DeepLinkHandler(
        linkStream: links.stream,
        onError: (error, _) => errors.add(error),
      );
    });

    tearDown(() async {
      handler.dispose();
      await links.close();
    });

    test('opens the same link again when it is tapped a second time', () async {
      final received = <Uri>[];
      handler.init((uri) async => received.add(uri));
      final link = Uri.parse('https://api.hadith-shareef.com/api/hadith/1');

      links
        ..add(link)
        ..add(link);
      await pumpEventQueue();

      expect(received, [link, link]);
    });

    test('reports a failed link and keeps listening', () async {
      var calls = 0;
      handler.init((uri) async {
        calls++;
        throw StateError('navigation failed');
      });

      links
        ..add(Uri.parse('mishkat://hadith/1'))
        ..add(Uri.parse('mishkat://hadith/2'));
      await pumpEventQueue();

      expect(calls, 2);
      expect(errors, hasLength(2));
    });

    test('delivers each link once when init is called twice', () async {
      final received = <Uri>[];
      handler
        ..init((uri) async => received.add(uri))
        ..init((uri) async => received.add(uri));

      links.add(Uri.parse('mishkat://hadith/1'));
      await pumpEventQueue();

      expect(received, hasLength(1));
    });

    test('stops delivering links after dispose', () async {
      final received = <Uri>[];
      handler
        ..init((uri) async => received.add(uri))
        ..dispose();

      links.add(Uri.parse('mishkat://hadith/1'));
      await pumpEventQueue();

      expect(received, isEmpty);
    });
  });
}
