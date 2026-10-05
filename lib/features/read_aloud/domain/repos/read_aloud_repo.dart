import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/read_aloud_settings.dart';
import '../entities/speech_engine.dart';
import '../entities/speech_event.dart';

abstract class ReadAloudRepo {
  /// The saved settings, or the defaults when none were saved.
  Future<ApiResult<ReadAloudSettings>> getSettings();

  Future<ApiResult<void>> saveSettings(ReadAloudSettings settings);

  /// Settings as they are saved, so a reading in progress can follow.
  Stream<ReadAloudSettings> get settingsChanges;

  /// What the engine reports about the utterance it is reading.
  Stream<SpeechEvent> get speechEvents;

  /// Switches to [engine] (null: the system default) where engines can be
  /// chosen, and reports what it offers.
  Future<ApiResult<SpeechEngineSnapshot>> inspectEngine({String? engine});

  Future<ApiResult<bool>> isLanguageAvailable(String locale);

  /// Whether each of [locales] has its voice data on the device. Empty on
  /// platforms that do not say.
  Future<ApiResult<Map<String, bool>>> areLanguagesInstalled(
    List<String> locales,
  );

  Future<ApiResult<void>> applyVoice(SpeechVoiceSetup setup);

  /// Reads [text] from its start, replacing anything being read.
  Future<ApiResult<void>> speak(String text);

  /// Pauses the utterance; false when the platform could not.
  Future<ApiResult<bool>> pause();

  /// Carries on with the paused utterance.
  Future<ApiResult<void>> resume();

  /// Stops reading. With [release], also hands audio back to other apps.
  Future<ApiResult<void>> stop({bool release = false});

  /// Writes [text] read aloud to an audio file and returns its path.
  Future<ApiResult<String>> synthesizeToFile(String text, {required String name});
}
