import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_commentary.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_edition.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_edition_search.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_metrics.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/recitation_settings.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/filter_quran_editions_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/get_ayah_commentary_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/get_hizb_index_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/get_quran_editions_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/get_reflection_ayah_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/get_surah_commentary_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/quran_study_settings_use_cases.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/search_quran_edition_use_case.dart';
import 'package:mishkat_almasabih/features/quran/presentation/logic/ayah_commentary/ayah_commentary_cubit.dart';
import 'package:mishkat_almasabih/features/quran/presentation/logic/hizb_index/quran_hizb_index_cubit.dart';
import 'package:mishkat_almasabih/features/quran/presentation/logic/quran_editions/quran_editions_cubit.dart';
import 'package:mishkat_almasabih/features/quran/presentation/logic/reflection/quran_reflection_cubit.dart';
import 'package:mishkat_almasabih/features/quran/presentation/logic/surah_tafsir/surah_tafsir_cubit.dart';
import 'package:mishkat_almasabih/features/quran/presentation/logic/tafsir_search/quran_tafsir_search_cubit.dart';

import '../quran_fakes.dart';

void main() {
  group('AyahCommentaryCubit', () {
    late FakeQuranCloudRepo cloud;
    late FakeQuranReadingRepo reading;
    late AyahCommentaryCubit cubit;

    setUp(() {
      cloud = FakeQuranCloudRepo(
        ayahTexts: {
          2: [
            passage(muyassar, 'الثناء على الله'),
            passage(jalalayn, 'جملة خبرية'),
            passage(sahih, 'All praise'),
          ],
        },
      );
      reading = FakeQuranReadingRepo();
      cubit = AyahCommentaryCubit(
        GetCommentarySettingsUseCase(reading),
        SaveCommentarySettingsUseCase(reading),
        GetAyahCommentaryUseCase(cloud),
      );
    });

    tearDown(() => cubit.close());

    test('shows the saved tafsir of the ayah', () async {
      await cubit.load(2);

      final state = cubit.state as AyahCommentaryLoaded;
      expect(state.commentary.tafsir?.text, 'الثناء على الله');
      expect(state.commentary.translation, isNull);
    });

    test('says why the commentary could not be fetched', () async {
      cloud.failure = const NetworkFailure();

      await cubit.load(2);

      expect(
        (cubit.state as AyahCommentaryFailure).message,
        FailureMessages.noConnection,
      );
    });

    test('tries the same ayah again', () async {
      cloud.failure = const NetworkFailure();
      await cubit.load(2);
      cloud.failure = null;

      await cubit.retry();

      expect(cubit.state, isA<AyahCommentaryLoaded>());
    });

    test('switches tafsir, keeping the choice for next time', () async {
      await cubit.load(2);

      await cubit.setTafsir(jalalayn);

      final state = cubit.state as AyahCommentaryLoaded;
      expect(state.commentary.tafsir?.text, 'جملة خبرية');
      expect(reading.commentarySettings.tafsirId, 'ar.jalalayn');
    });

    test('adds a translation, then removes it', () async {
      await cubit.load(2);

      await cubit.setTranslation(sahih);
      expect(
        (cubit.state as AyahCommentaryLoaded).commentary.translation?.text,
        'All praise',
      );

      await cubit.setTranslation(null);
      expect(
        (cubit.state as AyahCommentaryLoaded).commentary.translation,
        isNull,
      );
      expect(reading.commentarySettings.translationId, isNull);
    });

    test('uses the default tafsir when the settings cannot be read', () async {
      reading.failReads = true;

      await cubit.load(2);

      expect(cubit.state.settings, CommentarySettings.defaults);
      expect(cubit.state, isA<AyahCommentaryLoaded>());
    });
  });

  group('SurahTafsirCubit', () {
    late FakeQuranCloudRepo cloud;
    late SurahTafsirCubit cubit;

    setUp(() {
      cloud = FakeQuranCloudRepo(
        surahTexts: [
          AyahEditionText(ayahId: 1, text: passage(muyassar, 'أ')),
          AyahEditionText(ayahId: 2, text: passage(muyassar, 'ب')),
          AyahEditionText(ayahId: 8, text: passage(muyassar, 'الم')),
        ],
      );
      final reading = FakeQuranReadingRepo();
      cubit = SurahTafsirCubit(
        GetCommentarySettingsUseCase(reading),
        SaveCommentarySettingsUseCase(reading),
        GetSurahCommentaryUseCase(cloud, FakeQuranRepo()),
      );
    });

    tearDown(() => cubit.close());

    test('starts at the ayah it was opened on', () async {
      await cubit.load(1, startAyah: 2);

      final state = cubit.state as SurahTafsirLoaded;
      expect(state.startsMidway, isTrue);
      expect(cloud.surahTextRequests.single.offset, 1);
    });

    test('loads the next page after the one shown', () async {
      await cubit.load(2);

      await cubit.loadMore();

      expect(cloud.surahTextRequests.map((r) => r.offset), [0, 10]);
      expect((cubit.state as SurahTafsirLoaded).ayahs, hasLength(2));
    });

    test('has nothing more to load after the surah\'s end', () async {
      await cubit.load(1);

      await cubit.loadMore();

      expect((cubit.state as SurahTafsirLoaded).hasMore, isFalse);
      expect(cloud.surahTextRequests, hasLength(1));
    });

    test('keeps what is shown when the next page fails', () async {
      await cubit.load(2);
      cloud.failure = const NetworkFailure();

      await cubit.loadMore();

      final state = cubit.state as SurahTafsirLoaded;
      expect(state.ayahs, hasLength(1));
      expect(state.loadMoreFailure, FailureMessages.noConnection);
      expect(state.isLoadingMore, isFalse);
    });

    test('goes back to the surah\'s first ayah', () async {
      await cubit.load(1, startAyah: 2);

      await cubit.showFromStart();

      expect(cloud.surahTextRequests.last.offset, 0);
      expect((cubit.state as SurahTafsirLoaded).startsMidway, isFalse);
    });

    test('says why the surah could not be fetched', () async {
      cloud.failure = const NetworkFailure();

      await cubit.load(1);

      expect(cubit.state, isA<SurahTafsirFailure>());
    });
  });

  group('QuranTafsirSearchCubit', () {
    late FakeQuranCloudRepo cloud;
    late FakeQuranReadingRepo reading;
    late QuranTafsirSearchCubit cubit;

    setUp(() {
      cloud = FakeQuranCloudRepo(
        searchMatches: [
          for (var i = 0; i < 25; i++)
            const AyahEditionMatch(ayahId: 1, text: 'باسم الله الرحمن'),
        ],
      );
      reading = FakeQuranReadingRepo();
      cubit = QuranTafsirSearchCubit(
        GetCommentarySettingsUseCase(reading),
        SaveCommentarySettingsUseCase(reading),
        SearchQuranEditionUseCase(cloud, FakeQuranRepo()),
        debounce: Duration.zero,
      );
    });

    tearDown(() => cubit.close());

    test('searches the saved tafsir', () async {
      reading.commentarySettings = const CommentarySettings(
        tafsirId: 'ar.jalalayn',
      );

      await cubit.search('الرحمن');

      expect(cloud.searchRequests.single.edition, 'ar.jalalayn');
      final state = cubit.state as QuranTafsirSearchSuccess;
      expect(state.total, 25);
      expect(state.hasMore, isTrue);
    });

    test('adds the next page of results', () async {
      await cubit.search('الرحمن');

      await cubit.loadMore();

      final state = cubit.state as QuranTafsirSearchSuccess;
      expect(state.hits, hasLength(25));
      expect(state.hasMore, isFalse);
      expect(cloud.searchRequests.last.offset, 20);
    });

    test('says so when nothing is found', () async {
      cloud.searchMatches = const [];

      await cubit.search('غائب');

      expect(cubit.state, isA<QuranTafsirSearchEmpty>());
    });

    test('stays idle for a single letter', () async {
      await cubit.search('ر');

      expect(cubit.state, isA<QuranTafsirSearchIdle>());
      expect(cloud.searchRequests, isEmpty);
    });

    test('searches another tafsir for the same words', () async {
      await cubit.search('الرحمن');

      await cubit.setTafsir(jalalayn);

      expect(cloud.searchRequests.last.edition, 'ar.jalalayn');
      expect(cloud.searchRequests.last.query, 'الرحمن');
      expect(reading.commentarySettings.tafsirId, 'ar.jalalayn');
    });

    test('drops results that arrive after the field is cleared', () async {
      final searching = cubit.search('الرحمن');

      cubit.clear();
      await searching;

      expect(cubit.state, isA<QuranTafsirSearchIdle>());
    });
  });

  group('QuranHizbIndexCubit', () {
    test('loads once, however often it is asked', () async {
      var loads = 0;
      final cloud = FakeQuranCloudRepo(
        hizbStarts: [
          for (var i = 0; i < QuranMetrics.hizbQuarterCount; i++)
            (surah: 1, ayah: 1),
        ],
      );
      final cubit = QuranHizbIndexCubit(
        GetHizbIndexUseCase(cloud, FakeQuranRepo()),
      );
      addTearDown(cubit.close);
      final sub = cubit.stream.listen((s) {
        if (s is QuranHizbIndexLoading) loads++;
      });
      addTearDown(sub.cancel);

      await cubit.loadIfNeeded();
      await cubit.loadIfNeeded();

      expect(loads, 1);
    });

    test('tries again after a failure when asked', () async {
      final cloud = FakeQuranCloudRepo(failure: const NetworkFailure());
      final cubit = QuranHizbIndexCubit(
        GetHizbIndexUseCase(cloud, FakeQuranRepo()),
      );
      addTearDown(cubit.close);

      await cubit.loadIfNeeded();
      expect(cubit.state, isA<QuranHizbIndexFailure>());

      cloud.failure = null;
      cloud.hizbStarts = [(surah: 1, ayah: 1)];
      await cubit.loadIfNeeded();
      // Still refused — 1 of 240 quarters — but it was asked again.
      expect(cubit.state, isA<QuranHizbIndexFailure>());
    });
  });

  group('QuranReflectionCubit', () {
    test('keeps the ayah shown while another loads', () async {
      final cloud = FakeQuranCloudRepo(
        random: AyahEditionText(ayahId: 2, text: passage(muyassar, 'ثناء')),
      );
      final cubit = QuranReflectionCubit(
        GetCommentarySettingsUseCase(FakeQuranReadingRepo()),
        GetReflectionAyahUseCase(cloud, FakeQuranRepo()),
      );
      addTearDown(cubit.close);
      await cubit.load();
      final states = <QuranReflectionState>[];
      final sub = cubit.stream.listen(states.add);
      addTearDown(sub.cancel);

      await cubit.load();

      expect((states.first as QuranReflectionLoading).previous?.ayah, hamd);
      expect(cubit.state, isA<QuranReflectionLoaded>());
    });

    test('says why no ayah could be fetched', () async {
      final cubit = QuranReflectionCubit(
        GetCommentarySettingsUseCase(FakeQuranReadingRepo()),
        GetReflectionAyahUseCase(
          FakeQuranCloudRepo(failure: const NetworkFailure()),
          FakeQuranRepo(),
        ),
      );
      addTearDown(cubit.close);

      await cubit.load();

      expect(
        (cubit.state as QuranReflectionFailure).message,
        FailureMessages.noConnection,
      );
    });
  });

  group('QuranEditionsCubit', () {
    test('lists the reciters and narrows them by name', () async {
      final cubit = QuranEditionsCubit(
        GetQuranEditionsUseCase(FakeQuranCloudRepo()),
        FilterQuranEditionsUseCase(),
      );
      addTearDown(cubit.close);
      await cubit.load(QuranEditionType.recitation);

      cubit.filter('الحصري');

      final state = cubit.state as QuranEditionsLoaded;
      expect(state.editions, [alafasy, husary]);
      expect(state.visible, [husary]);
      expect(state.find('ar.alafasy'), alafasy);
    });

    test('says why the list could not be fetched', () async {
      final cubit = QuranEditionsCubit(
        GetQuranEditionsUseCase(
          FakeQuranCloudRepo(failure: const NetworkFailure()),
        ),
        FilterQuranEditionsUseCase(),
      );
      addTearDown(cubit.close);

      await cubit.load(QuranEditionType.tafsir);

      expect(cubit.state, isA<QuranEditionsFailure>());
    });
  });

  test('the default settings name a reciter and tafsir that exist', () {
    expect(
      RecitationSettings.defaults.reciterId,
      DefaultQuranEditions.reciter.identifier,
    );
    expect(
      CommentarySettings.defaults.tafsirId,
      DefaultQuranEditions.tafsir.identifier,
    );
  });
}
