import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/entities/read_aloud_settings.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/usecases/get_read_aloud_settings_use_case.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/usecases/inspect_speech_engine_use_case.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/usecases/save_read_aloud_settings_use_case.dart';
import 'package:mishkat_almasabih/features/read_aloud/presentation/logic/read_aloud_settings_cubit.dart';

import '../read_aloud_fakes.dart';

void main() {
  late FakeReadAloudRepo repo;
  late ReadAloudSettingsCubit cubit;

  setUp(() {
    repo = FakeReadAloudRepo();
    cubit = ReadAloudSettingsCubit(
      GetReadAloudSettingsUseCase(repo),
      SaveReadAloudSettingsUseCase(repo),
      InspectSpeechEngineUseCase(repo),
    );
  });

  tearDown(() => cubit.close());

  test('load reads the saved settings', () async {
    repo.settings = const ReadAloudSettings(rate: 0.75);

    await cubit.load();

    expect(cubit.state.loaded, isTrue);
    expect(cubit.state.settings.rate, 0.75);
  });

  test('inspectEngine lists the Arabic voices', () async {
    await cubit.inspectEngine();

    expect(cubit.state.report?.voices, [arabicVoice, secondArabicVoice]);
    expect(cubit.state.inspecting, isFalse);
  });

  test('a change applies at once and is saved', () async {
    await cubit.load();

    await cubit.setAutoContinue(true);

    expect(cubit.state.settings.autoContinue, isTrue);
    expect(repo.settings.autoContinue, isTrue);
  });

  test('cycleRate steps to the next speed', () async {
    await cubit.load();

    await cubit.cycleRate();

    expect(repo.settings.rate, 1.25);
  });

  test('selecting a voice saves it, and none returns to automatic', () async {
    await cubit.load();

    await cubit.selectVoice(secondArabicVoice);
    expect(repo.settings.voice, secondArabicVoice.ref);

    await cubit.selectVoice(null);
    expect(repo.settings.voice, isNull);
  });

  test('a new engine clears the voice and is inspected', () async {
    await cubit.inspectEngine();
    await cubit.selectVoice(secondArabicVoice);

    await cubit.selectEngine('com.google.android.tts');

    expect(repo.settings.voice, isNull);
    expect(repo.inspectedEngine, 'com.google.android.tts');
  });

  test('reset returns every setting to its default', () async {
    await cubit.load();
    await cubit.setHighlightWords(false);

    await cubit.reset();

    expect(repo.settings, ReadAloudSettings.defaults);
  });
}
