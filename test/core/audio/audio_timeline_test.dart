import 'package:audio_service/audio_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/audio/audio_timeline.dart';

MediaItem _entry(String surah, int ayah) =>
    MediaItem(id: 'https://cdn.example/$surah/$ayah.mp3', title: 'سورة $surah');

Duration _s(int seconds) => Duration(seconds: seconds);

void main() {
  // Two surahs back to back, as a juz queues them.
  final entries = [
    _entry('الفلق', 1),
    _entry('الفلق', 2),
    _entry('الفلق', 3),
    _entry('الناس', 1),
    _entry('الناس', 2),
  ];
  final lengths = {
    entries[0].id: _s(2),
    entries[1].id: _s(3),
    entries[2].id: _s(4),
    entries[3].id: _s(5),
    entries[4].id: _s(6),
  };

  AudioTimeline timeline(Map<String, Duration> known) =>
      AudioTimeline(entries, (url) => known[url]);

  group('parts', () {
    test('a part is the entries of one surah', () {
      expect(timeline(lengths).urlsOfPart(1), [
        for (final e in entries.take(3)) e.id,
      ]);
      expect(timeline(lengths).urlsOfPart(3), [
        for (final e in entries.skip(3)) e.id,
      ]);
    });

    test('an entry outside the queue has no part', () {
      expect(timeline(lengths).urlsOfPart(5), isEmpty);
      expect(timeline(lengths).lengthOfPart(-1), isNull);
    });
  });

  group('the bar', () {
    test('spans every ayah of the surah', () {
      expect(timeline(lengths).lengthOfPart(0), _s(9));
      expect(timeline(lengths).lengthOfPart(4), _s(11));
    });

    test('places each ayah after those before it in its surah', () {
      expect(timeline(lengths).startOf(0), Duration.zero);
      expect(timeline(lengths).startOf(2), _s(5));
      expect(timeline(lengths).startOf(3), Duration.zero);
      expect(timeline(lengths).startOf(4), _s(5));
    });

    test('is unknown while one ayah of the surah is', () {
      final partly = {...lengths}..remove(entries[1].id);

      expect(timeline(partly).lengthOfPart(0), isNull);
      expect(timeline(partly).startOf(0), isNull);
      expect(timeline(partly).locate(0, _s(1)), isNull);
    });

    test('of one surah does not wait for the next', () {
      final partly = {...lengths}..remove(entries[4].id);

      expect(timeline(partly).lengthOfPart(0), _s(9));
    });

    test('counts an ayah once each time it is repeated', () {
      final repeated = AudioTimeline([
        entries[0],
        entries[0],
        entries[1],
      ], (url) => lengths[url]);

      expect(repeated.lengthOfPart(0), _s(7));
      expect(repeated.startOf(1), _s(2));
      expect(repeated.locate(0, _s(3)), (1, _s(1)));
    });
  });

  group('locate', () {
    test('finds the ayah a point on the bar falls in', () {
      expect(timeline(lengths).locate(0, _s(6)), (2, _s(1)));
    });

    test('stays within the surah the player is on', () {
      expect(timeline(lengths).locate(4, _s(2)), (3, _s(2)));
    });

    test('a point at the start of an ayah is that ayah', () {
      expect(timeline(lengths).locate(0, _s(2)), (1, Duration.zero));
    });

    test('a point past the end is the end of the last ayah', () {
      expect(timeline(lengths).locate(0, _s(100)), (2, _s(4)));
    });
  });
}
