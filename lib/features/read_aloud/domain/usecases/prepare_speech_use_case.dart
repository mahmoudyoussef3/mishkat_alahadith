import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/read_aloud_settings.dart';
import '../entities/speech_engine.dart';
import '../repos/read_aloud_repo.dart';
import 'inspect_speech_engine_use_case.dart';

/// Sets the engine up to read Arabic with the reader's voice and sound.
class PrepareSpeechUseCase {
  final ReadAloudRepo _repo;
  final InspectSpeechEngineUseCase _inspect;

  PrepareSpeechUseCase(this._repo, this._inspect);

  /// Pass the report of an earlier setup as [reuse] when only the rate,
  /// pitch or volume changed since: the engine is then not looked over
  /// again.
  Future<ApiResult<SpeechEngineReport>> call(
    ReadAloudSettings settings, {
    SpeechEngineReport? reuse,
  }) async {
    final SpeechEngineReport report;
    if (reuse != null) {
      report = reuse;
    } else {
      switch (await _inspect(settings)) {
        case ApiSuccess(:final data):
          report = data;
        case ApiFailure(:final failure):
          return ApiResult.failure(failure);
      }
    }

    final locale = report.locale;
    if (locale == null) {
      return const ApiResult.failure(ArabicVoiceUnavailableFailure());
    }

    final applied = await _repo.applyVoice(
      SpeechVoiceSetup(
        locale: locale,
        voice: report.voice,
        rate: report.rateRange.rateFor(settings.rate),
        pitch: settings.pitch,
        volume: settings.volume,
      ),
    );
    return switch (applied) {
      ApiSuccess() => ApiResult.success(report),
      ApiFailure(:final failure) => ApiResult.failure(failure),
    };
  }
}
