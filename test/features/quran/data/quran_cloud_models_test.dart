import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/features/quran/data/mappers/quran_cloud_mappers.dart';
import 'package:mishkat_almasabih/features/quran/data/models/quran_cloud_models.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_edition.dart';

/// The edition of `/ayah/262/ar.alafasy`, as the service sends it.
const Map<String, dynamic> _alafasyEdition = {
  'identifier': 'ar.alafasy',
  'language': 'ar',
  'name': 'مشاري العفاسي',
  'englishName': 'Alafasy',
  'format': 'audio',
  'type': 'versebyverse',
  'direction': null,
};

const Map<String, dynamic> _muyassarEdition = {
  'identifier': 'ar.muyassar',
  'language': 'ar',
  'name': 'تفسير المیسر',
  'englishName': 'King Fahad Quran Complex',
  'format': 'text',
  'type': 'tafsir',
  'direction': 'rtl',
};

/// What an unknown edition is quietly swapped for.
const Map<String, dynamic> _defaultTextEdition = {
  'identifier': 'quran-uthmani-quran-academy',
  'language': 'ar',
  'name': 'القرآن الكريم',
  'englishName': 'Uthmani',
  'format': 'text',
  'type': 'quran',
  'direction': 'rtl',
};

const Map<String, dynamic> _alafasyAyah = {
  'number': 262,
  'audio': 'https://cdn.islamic.network/quran/audio/128/ar.alafasy/262.mp3',
  'audioSecondary': [
    'https://cdn.islamic.network/quran/audio/64/ar.alafasy/262.mp3',
  ],
  'text': 'ٱللَّهُ لَآ إِلَٰهَ إِلَّا هُوَ',
  'edition': _alafasyEdition,
  'numberInSurah': 255,
  'juz': 3,
  'page': 42,
  'sajda': false,
};

Map<String, dynamic> _withEdition(
  Map<String, dynamic> edition,
  Map<String, dynamic> changes,
) => {...edition, ...changes};

void main() {
  group('QuranEditionModel.tryFromJson', () {
    test('reads every field of an edition', () {
      final model = QuranEditionModel.tryFromJson(_muyassarEdition)!;

      expect(model.identifier, 'ar.muyassar');
      expect(model.language, 'ar');
      expect(model.englishName, 'King Fahad Quran Complex');
      expect(model.format, 'text');
      expect(model.type, 'tafsir');
      expect(model.direction, 'rtl');
    });

    test('reads a null direction as none', () {
      expect(QuranEditionModel.tryFromJson(_alafasyEdition)!.direction, isNull);
    });

    test('accepts a search edition that leaves out format and direction', () {
      final model =
          QuranEditionModel.tryFromJson({
            'identifier': 'ar.muyassar',
            'language': 'ar',
            'name': 'تفسير المیسر',
            'englishName': 'King Fahad Quran Complex',
            'type': 'tafsir',
          })!;

      expect(model.format, isEmpty);
      expect(model.direction, isNull);
    });

    test('is null without an identifier', () {
      expect(
        QuranEditionModel.tryFromJson(
          _withEdition(_muyassarEdition, {'identifier': ''}),
        ),
        isNull,
      );
    });

    test('is null for something that is not a map', () {
      expect(QuranEditionModel.tryFromJson('ar.muyassar'), isNull);
    });

    test('round-trips through toJson', () {
      final model = QuranEditionModel.tryFromJson(_muyassarEdition)!;

      final again = QuranEditionModel.tryFromJson(model.toJson())!;

      expect(again.toJson(), model.toJson());
    });
  });

  group('CloudAyahModel.tryFromJson', () {
    test('reads an audio ayah with its addresses and edition', () {
      final ayah = CloudAyahModel.tryFromJson(_alafasyAyah)!;

      expect(ayah.number, 262);
      expect(ayah.audio, endsWith('/128/ar.alafasy/262.mp3'));
      expect(ayah.audioSecondary, [
        'https://cdn.islamic.network/quran/audio/64/ar.alafasy/262.mp3',
      ]);
      expect(ayah.edition?.identifier, 'ar.alafasy');
    });

    test('leaves out secondary addresses that are not text', () {
      final ayah =
          CloudAyahModel.tryFromJson({
            ..._alafasyAyah,
            'audioSecondary': [64, 'https://cdn.example/64.mp3', null],
          })!;

      expect(ayah.audioSecondary, ['https://cdn.example/64.mp3']);
    });

    test('is null without a number', () {
      expect(
        CloudAyahModel.tryFromJson({..._alafasyAyah, 'number': '262'}),
        isNull,
      );
    });

    test('reads missing text as empty', () {
      final ayah = CloudAyahModel.tryFromJson({'number': 1})!;

      expect(ayah.text, isEmpty);
      expect(ayah.audio, isNull);
      expect(ayah.edition, isNull);
    });

    test('listFromJson skips entries that cannot be read', () {
      final ayahs = CloudAyahModel.listFromJson([
        _alafasyAyah,
        'not an ayah',
        {'text': 'no number'},
      ]);

      expect(ayahs.map((a) => a.number), [262]);
    });

    test('listFromJson reads anything but a list as empty', () {
      expect(CloudAyahModel.listFromJson({'number': 1}), isEmpty);
    });
  });

  group('CloudAyahGroupModel.tryFromJson', () {
    test('reads the ayahs and the edition they share', () {
      final group =
          CloudAyahGroupModel.tryFromJson({
            'number': 1,
            'ayahs': [_alafasyAyah],
            'surahs': {'1': {}},
            'edition': _alafasyEdition,
          })!;

      expect(group.ayahs, hasLength(1));
      expect(group.edition?.identifier, 'ar.alafasy');
    });

    test('is null without a list of ayahs', () {
      expect(
        CloudAyahGroupModel.tryFromJson({'edition': _alafasyEdition}),
        isNull,
      );
    });
  });

  group('CloudSearchModel.tryFromJson', () {
    test('takes the total of a paged search', () {
      final search =
          CloudSearchModel.tryFromJson({
            'count': 2,
            'total': 144,
            'offset': 0,
            'limit': 2,
            'matches': [_alafasyAyah, _alafasyAyah],
          })!;

      expect(search.total, 144);
      expect(search.matches, hasLength(2));
    });

    test('falls back to the count without a total', () {
      final search =
          CloudSearchModel.tryFromJson({
            'count': 167,
            'matches': [_alafasyAyah],
          })!;

      expect(search.total, 167);
    });

    test('falls back to the matches without a total or count', () {
      final search =
          CloudSearchModel.tryFromJson({
            'matches': [_alafasyAyah],
          })!;

      expect(search.total, 1);
    });

    test('is null for something that is not a map', () {
      expect(CloudSearchModel.tryFromJson([]), isNull);
    });
  });

  group('edition mapper', () {
    QuranEdition? entityOf(Map<String, dynamic> json) =>
        QuranEditionModel.tryFromJson(json)!.toEntity();

    test('an audio edition is a recitation', () {
      expect(entityOf(_alafasyEdition)?.type, QuranEditionType.recitation);
    });

    test('a tafsir edition is a tafsir', () {
      expect(entityOf(_muyassarEdition)?.type, QuranEditionType.tafsir);
    });

    test('a translation edition is a translation', () {
      final edition = entityOf({
        'identifier': 'en.sahih',
        'language': 'en',
        'name': 'Saheeh International',
        'englishName': 'Saheeh International',
        'format': 'text',
        'type': 'translation',
        'direction': 'ltr',
      });

      expect(edition?.type, QuranEditionType.translation);
      expect(edition?.isRightToLeft, isFalse);
    });

    test('the Quran text in another script is of no use', () {
      expect(entityOf(_defaultTextEdition), isNull);
    });

    test('a search edition without a format is still a tafsir', () {
      final edition = entityOf({
        'identifier': 'ar.muyassar',
        'language': 'ar',
        'name': 'تفسير المیسر',
        'englishName': 'King Fahad Quran Complex',
        'type': 'tafsir',
      });

      expect(edition?.type, QuranEditionType.tafsir);
    });

    test('writes Arabic names with Arabic yeh and kaf', () {
      expect(entityOf(_muyassarEdition)?.name, 'تفسير الميسر');
      expect(
        entityOf(_withEdition(_muyassarEdition, {'name': 'تفسیر کبیر'}))?.name,
        'تفسير كبير',
      );
    });

    test('keeps the Persian spelling of a Persian name', () {
      final edition = entityOf({
        'identifier': 'fa.ayati',
        'language': 'fa',
        'name': 'آیتی',
        'englishName': 'AbdolMohammad Ayati',
        'format': 'text',
        'type': 'translation',
        'direction': 'rtl',
      });

      expect(edition?.name, 'آیتی');
    });

    test('an identifier that could reshape a request is refused', () {
      expect(
        entityOf(_withEdition(_muyassarEdition, {'identifier': 'ar/../x'})),
        isNull,
      );
    });

    test('names an edition without a native name by its English one', () {
      expect(
        entityOf(_withEdition(_muyassarEdition, {'name': '  '}))?.name,
        'King Fahad Quran Complex',
      );
    });

    test('without a direction, Arabic and Urdu run right to left', () {
      expect(entityOf(_alafasyEdition)?.isRightToLeft, isTrue);
      expect(
        entityOf(
          _withEdition(_alafasyEdition, {
            'identifier': 'ur.khan',
            'language': 'ur',
          }),
        )?.isRightToLeft,
        isTrue,
      );
    });

    test('without a direction, English runs left to right', () {
      expect(
        entityOf(
          _withEdition(_alafasyEdition, {
            'identifier': 'en.walk',
            'language': 'en',
          }),
        )?.isRightToLeft,
        isFalse,
      );
    });
  });

  group('toRecitationAudio', () {
    CloudAyahModel ayah(Map<String, dynamic> changes) =>
        CloudAyahModel.tryFromJson({..._alafasyAyah, ...changes})!;

    test('keeps the main address and the secondary ones', () {
      final audio = ayah({}).toRecitationAudio()!;

      expect(audio.ayahId, 262);
      expect(audio.url, endsWith('/128/ar.alafasy/262.mp3'));
      expect(audio.lowBitrateUrls, [
        'https://cdn.islamic.network/quran/audio/64/ar.alafasy/262.mp3',
      ]);
    });

    test('is null without audio', () {
      expect(ayah({'audio': null}).toRecitationAudio(), isNull);
    });

    test('is null for an address that is not secure', () {
      expect(
        ayah({
          'audio': 'http://cdn.islamic.network/quran/audio/128/x/262.mp3',
        }).toRecitationAudio(),
        isNull,
      );
    });

    test('is null for an address without a host', () {
      expect(ayah({'audio': 'https:///262.mp3'}).toRecitationAudio(), isNull);
    });

    test('is null for an ayah outside the mushaf', () {
      expect(ayah({'number': 6237}).toRecitationAudio(), isNull);
      expect(ayah({'number': 0}).toRecitationAudio(), isNull);
    });

    test('drops secondary addresses that are not secure', () {
      final audio =
          ayah({
            'audioSecondary': [
              'http://cdn.islamic.network/quran/audio/64/x/262.mp3',
              'https://cdn.islamic.network/quran/audio/32/x/262.mp3',
            ],
          }).toRecitationAudio()!;

      expect(audio.lowBitrateUrls, [
        'https://cdn.islamic.network/quran/audio/32/x/262.mp3',
      ]);
    });
  });

  group('toEditionText', () {
    const muyassarAyah = {
      'number': 255,
      'text': 'وقال لهم نبيهم: إن علامة ملكه أن يأتيكم التابوت',
      'edition': _muyassarEdition,
      'numberInSurah': 248,
    };

    test('takes the edition the ayah names', () {
      final entry = CloudAyahModel.tryFromJson(muyassarAyah)!.toEditionText()!;

      expect(entry.ayahId, 255);
      expect(entry.text.edition.identifier, 'ar.muyassar');
      expect(entry.text.text, startsWith('وقال لهم نبيهم'));
    });

    test('takes the parent edition for an ayah nested in a surah', () {
      final nested =
          CloudAyahModel.tryFromJson({'number': 255, 'text': 'نص التفسير'})!;

      final entry =
          nested.toEditionText(
            parent: QuranEditionModel.tryFromJson(_muyassarEdition),
          )!;

      expect(entry.text.edition.identifier, 'ar.muyassar');
    });

    test('trims the passage', () {
      final entry =
          CloudAyahModel.tryFromJson({
            ...muyassarAyah,
            'text': '  نص  ',
          })!.toEditionText()!;

      expect(entry.text.text, 'نص');
    });

    test('is null for an empty passage', () {
      expect(
        CloudAyahModel.tryFromJson({
          ...muyassarAyah,
          'text': '   ',
        })!.toEditionText(),
        isNull,
      );
    });

    test('is null without an edition', () {
      expect(
        CloudAyahModel.tryFromJson({
          'number': 255,
          'text': 'نص',
        })!.toEditionText(),
        isNull,
      );
    });

    test('is null for the default text swapped in for an unknown edition', () {
      expect(
        CloudAyahModel.tryFromJson({
          ...muyassarAyah,
          'edition': _defaultTextEdition,
        })!.toEditionText(),
        isNull,
      );
    });

    test('is null for an ayah outside the mushaf', () {
      expect(
        CloudAyahModel.tryFromJson({
          ...muyassarAyah,
          'number': 7000,
        })!.toEditionText(),
        isNull,
      );
    });
  });
}
