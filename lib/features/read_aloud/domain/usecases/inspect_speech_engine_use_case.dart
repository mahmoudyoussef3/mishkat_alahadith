import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/read_aloud_settings.dart';
import '../entities/speech_engine.dart';
import '../entities/speech_voice.dart';
import '../repos/read_aloud_repo.dart';
import '../services/arabic_voice_picker.dart';

/// Finds the Arabic voices the engine offers and which one will read.
class InspectSpeechEngineUseCase {
  final ReadAloudRepo _repo;

  InspectSpeechEngineUseCase(this._repo);

  Future<ApiResult<SpeechEngineReport>> call(ReadAloudSettings settings) async {
    final inspected = await _repo.inspectEngine(engine: settings.engine);
    final SpeechEngineSnapshot snapshot;
    switch (inspected) {
      case ApiSuccess(:final data):
        snapshot = data;
      case ApiFailure(:final failure):
        return ApiResult.failure(failure);
    }

    final locales = ArabicVoicePicker.arabicLocales([
      ...snapshot.languages,
      for (final voice in snapshot.voices) voice.locale,
    ]);
    SpeechEngineReport report({
      String? locale,
      List<SpeechVoice> voices = const [],
      SpeechVoice? autoVoice,
      SpeechVoice? voice,
      Set<String> missingLocales = const {},
    }) => SpeechEngineReport(
      locale: locale,
      voices: voices,
      autoVoice: autoVoice,
      voice: voice,
      missingLocales: missingLocales,
      engines: snapshot.engines,
      defaultEngine: snapshot.defaultEngine,
      currentEngine: snapshot.currentEngine,
      chosenEngineFailed:
          settings.engine != null && snapshot.currentEngine != settings.engine,
      rateRange: snapshot.rateRange,
      maxInputLength: snapshot.maxInputLength,
    );
    if (locales.isEmpty) return ApiResult.success(report());

    // Unknown installation state (iOS, or a failed query) counts as
    // installed: the engine will say so when it cannot read.
    final installed = await _repo.areLanguagesInstalled(locales);
    final missing = switch (installed) {
      ApiSuccess(:final data) => {
        for (final entry in data.entries)
          if (!entry.value) SpeechVoice.normalizeLocale(entry.key),
      },
      ApiFailure() => const <String>{},
    };

    final voices = ArabicVoicePicker.rank(
      snapshot.voices,
      missingLocales: missing,
      engineDefault: snapshot.defaultVoice,
    );
    final autoVoice = ArabicVoicePicker.best(voices);
    final voice = ArabicVoicePicker.find(voices, settings.voice) ?? autoVoice;
    final locale = voice?.locale ?? locales.first;

    // Without a voice to rely on, the engine must confirm the language.
    if (voice == null) {
      final available = await _repo.isLanguageAvailable(locale);
      if (available case ApiSuccess(data: false)) {
        return ApiResult.success(
          report(voices: voices, missingLocales: missing),
        );
      }
    }

    return ApiResult.success(
      report(
        locale: locale,
        voices: voices,
        autoVoice: autoVoice,
        voice: voice,
        missingLocales: missing,
      ),
    );
  }
}
