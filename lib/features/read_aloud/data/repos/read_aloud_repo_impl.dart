import 'dart:async';

import 'package:mishkat_almasabih/core/errors/exceptions.dart';
import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../../domain/entities/read_aloud_settings.dart';
import '../../domain/entities/speech_engine.dart';
import '../../domain/entities/speech_event.dart';
import '../../domain/repos/read_aloud_repo.dart';
import '../datasources/read_aloud_settings_local_datasource.dart';
import '../datasources/text_to_speech_datasource.dart';
import '../mappers/speech_voice_mapper.dart';
import '../models/read_aloud_settings_model.dart';

class ReadAloudRepoImpl implements ReadAloudRepo {
  final TextToSpeechDataSource _tts;
  final ReadAloudSettingsLocalDataSource _local;

  ReadAloudRepoImpl(this._tts, this._local);

  /// Bounds calls that wait on the engine starting: flutter_tts holds them
  /// until it has, which a broken engine never does.
  static const Duration _engineTimeout = Duration(seconds: 25);

  /// Settings for this session; storage is read once.
  ReadAloudSettings? _settings;
  final StreamController<ReadAloudSettings> _settingsChanges =
      StreamController<ReadAloudSettings>.broadcast();

  @override
  Stream<ReadAloudSettings> get settingsChanges => _settingsChanges.stream;

  @override
  Stream<SpeechEvent> get speechEvents => _tts.events;

  @override
  Future<ApiResult<ReadAloudSettings>> getSettings() async {
    final cached = _settings;
    if (cached != null) return ApiResult.success(cached);
    final String? stored;
    try {
      stored = await _local.getSettings();
    } catch (_) {
      return const ApiResult.failure(CacheFailure());
    }
    final settings = _decode(stored);
    _settings = settings;
    return ApiResult.success(settings);
  }

  /// Unreadable storage is not worth failing over: defaults apply.
  static ReadAloudSettings _decode(String? stored) {
    if (stored == null || stored.isEmpty) return ReadAloudSettings.defaults;
    try {
      return ReadAloudSettingsModel.decode(stored).toEntity();
    } on FormatException {
      return ReadAloudSettings.defaults;
    }
  }

  @override
  Future<ApiResult<void>> saveSettings(ReadAloudSettings settings) async {
    // Kept for the session even when writing fails.
    final changed = settings != _settings;
    _settings = settings;
    if (changed) _settingsChanges.add(settings);
    try {
      await _local.saveSettings(
        ReadAloudSettingsModel.fromEntity(settings).encode(),
      );
      return const ApiResult.success(null);
    } catch (_) {
      return const ApiResult.failure(CacheFailure());
    }
  }

  @override
  Future<ApiResult<SpeechEngineSnapshot>> inspectEngine({String? engine}) =>
      _guard(timeout: _engineTimeout, () async {
        await _tts.configure();
        await _tts.useEngine(engine);
        final range = await _tts.rateRange();
        final defaultVoice = await _tts.defaultVoice();
        return SpeechEngineSnapshot(
          languages: await _tts.languages(),
          voices: [
            for (final voice in await _tts.voices())
              if (SpeechVoiceMapper.fromPlatform(voice) case final mapped?)
                mapped,
          ],
          defaultVoice:
              defaultVoice == null
                  ? null
                  : SpeechVoiceMapper.fromPlatform(defaultVoice),
          engines: await _tts.engines(),
          defaultEngine: await _tts.defaultEngine(),
          currentEngine: _tts.currentEngine,
          rateRange:
              range == null
                  ? SpeechRateRange.fallback
                  : SpeechRateRange(
                    min: range.min,
                    normal: range.normal,
                    max: range.max,
                  ),
          maxInputLength: await _tts.maxInputLength(),
        );
      });

  @override
  Future<ApiResult<bool>> isLanguageAvailable(String locale) =>
      _guard(() => _tts.isLanguageAvailable(locale));

  @override
  Future<ApiResult<Map<String, bool>>> areLanguagesInstalled(
    List<String> locales,
  ) => _guard(() => _tts.areLanguagesInstalled(locales));

  @override
  Future<ApiResult<void>> applyVoice(SpeechVoiceSetup setup) =>
      _guard(timeout: _engineTimeout, () async {
        await _tts.configure();
        // Setting the language on iOS drops the chosen voice, so it goes first.
        await _tts.setLanguage(setup.locale);
        final voice = setup.voice;
        final voiceSet =
            voice != null &&
            await _tts.setVoice(SpeechVoiceMapper.toPlatform(voice));
        if (!voiceSet) {
          // Back to the engine default, which may not be Arabic, then onto the
          // default voice of the Arabic locale.
          await _tts.clearVoice();
          if (!await _tts.setLanguage(setup.locale)) {
            throw const TextToSpeechException('Arabic is not available');
          }
        }
        await _tts.setSpeechRate(setup.rate);
        await _tts.setPitch(setup.pitch);
        await _tts.setVolume(setup.volume);
      });

  @override
  Future<ApiResult<void>> speak(String text) => _guard(() async {
    await _tts.configure();
    if (!await _tts.speak(text)) {
      throw const TextToSpeechException('The engine did not start speaking');
    }
  });

  @override
  Future<ApiResult<bool>> pause() => _guard(_tts.pause);

  @override
  Future<ApiResult<void>> resume() => _guard(() async {
    if (!await _tts.resume()) {
      throw const TextToSpeechException('Nothing to resume');
    }
  });

  @override
  Future<ApiResult<void>> stop({bool release = false}) =>
      _guard(() => _tts.stop(release: release));

  @override
  Future<ApiResult<String>> synthesizeToFile(
    String text, {
    required String name,
  }) => _guard(() async {
    await _tts.configure();
    return _tts.synthesizeToFile(text, name);
  });

  /// Runs a platform call, mapping anything it throws, or taking longer
  /// than [timeout], to a [SpeechFailure].
  static Future<ApiResult<T>> _guard<T>(
    Future<T> Function() call, {
    Duration? timeout,
  }) async {
    try {
      final result = call();
      return ApiResult.success(
        await (timeout == null ? result : result.timeout(timeout)),
      );
    } catch (_) {
      return const ApiResult.failure(SpeechFailure());
    }
  }
}
