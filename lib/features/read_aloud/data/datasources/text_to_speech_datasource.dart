import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:mishkat_almasabih/core/errors/exceptions.dart';
import 'package:path_provider/path_provider.dart';

import '../../domain/entities/speech_event.dart';

/// The device's text-to-speech engine, through flutter_tts.
///
/// flutter_tts sends every callback to the last [FlutterTts] created, so
/// the app must hold exactly one: register this class as a singleton.
class TextToSpeechDataSource {
  TextToSpeechDataSource([FlutterTts? tts]) : _tts = tts ?? FlutterTts() {
    _tts
      ..setStartHandler(() => _emit(const SpeechStarted()))
      ..setCompletionHandler(() => _emit(const SpeechCompleted()))
      ..setPauseHandler(() => _emit(const SpeechPaused()))
      ..setContinueHandler(() => _emit(const SpeechResumed()))
      ..setCancelHandler(() => _emit(const SpeechCancelled()))
      ..setProgressHandler(
        (text, start, end, _) =>
            _emit(SpeechProgress(text: text, start: start, end: end)),
      )
      ..setErrorHandler((message) => _emit(SpeechFailed('$message')));
  }

  final FlutterTts _tts;
  final StreamController<SpeechEvent> _events =
      StreamController<SpeechEvent>.broadcast();
  Future<void>? _configured;
  String? _engine;
  String? _lastUtterance;
  bool _sessionActive = false;
  bool _synthesizing = false;

  static const Duration _engineSwitchTimeout = Duration(seconds: 10);
  static const Duration _synthesisTimeout = Duration(seconds: 90);

  static bool get _isAndroid => !kIsWeb && Platform.isAndroid;

  static bool get _isIOS => !kIsWeb && Platform.isIOS;

  Stream<SpeechEvent> get events => _events.stream;

  /// The Android engine in use; null for the system default.
  String? get currentEngine => _engine;

  void _emit(SpeechEvent event) {
    // A recording reports through the same callbacks; it is not a reading.
    if (_synthesizing || _events.isClosed) return;
    _events.add(event);
  }

  /// One-time engine setup, retried on the next call if it fails.
  Future<void> configure() async {
    final pending = _configured ??= _configure();
    try {
      await pending;
    } catch (_) {
      if (identical(_configured, pending)) _configured = null;
      rethrow;
    }
  }

  Future<void> _configure() async {
    // Readings move on from the completion callback, so speak() should
    // return at once…
    await _tts.awaitSpeakCompletion(false);
    // …while a recording is only useful once its file is complete.
    await _tts.awaitSynthCompletion(true);
    if (_isAndroid) {
      // A new utterance replaces whatever is still queued (QUEUE_FLUSH).
      await _tts.setQueueMode(0);
    }
    if (_isIOS) {
      // Spoken audio, like an audiobook: heard with the silent switch on,
      // and other audio pauses rather than plays underneath. The session
      // stays active between the parts of a reading and is released when
      // the reading ends, so other apps are not resumed between sentences.
      await _tts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        const [],
        IosTextToSpeechAudioMode.spokenAudio,
      );
      await _tts.autoStopSharedSession(false);
    }
  }

  Future<List<String>> languages() async => _strings(await _tts.getLanguages);

  Future<List<Map<String, String>>> voices() async =>
      _maps(await _tts.getVoices);

  /// The engine's default voice; Android only.
  Future<Map<String, String>?> defaultVoice() async {
    if (!_isAndroid) return null;
    final voice = _map(await _tts.getDefaultVoice);
    return voice == null || voice.isEmpty ? null : voice;
  }

  /// Installed speech engines; Android only.
  Future<List<String>> engines() async =>
      _isAndroid ? _strings(await _tts.getEngines) : const [];

  Future<String?> defaultEngine() async {
    if (!_isAndroid) return null;
    final engine = await _tts.getDefaultEngine;
    return engine == null || '$engine'.isEmpty ? null : '$engine';
  }

  /// Switches the Android engine; null returns to the system default. When
  /// [engine] cannot start, the system default is restored and false
  /// returned. Switches run one at a time: each restarts the engine.
  Future<bool> useEngine(String? engine) {
    final switched = _engineSwitch.then((_) => _useEngine(engine));
    _engineSwitch = switched.then((_) {}, onError: (_) {});
    return switched;
  }

  Future<void> _engineSwitch = Future.value();

  Future<bool> _useEngine(String? engine) async {
    if (!_isAndroid || engine == _engine) return true;
    final target = engine ?? await defaultEngine();
    if (target == null) return false;
    try {
      await _tts.setEngine(target).timeout(_engineSwitchTimeout);
      _engine = engine;
      return true;
    } catch (_) {
      final fallback = await defaultEngine();
      if (fallback != null && fallback != target) {
        await _tts.setEngine(fallback).timeout(_engineSwitchTimeout);
      }
      _engine = null;
      return false;
    }
  }

  Future<SpeechRateValidRange?> rateRange() async {
    try {
      return await _tts.getSpeechRateValidRange;
    } catch (_) {
      return null;
    }
  }

  /// Longest text the engine takes in one utterance; Android only.
  Future<int?> maxInputLength() async =>
      _isAndroid ? await _tts.getMaxSpeechInputLength : null;

  Future<bool> isLanguageAvailable(String locale) async =>
      _isTrue(await _tts.isLanguageAvailable(locale));

  /// Whether each of [locales] has its voice data downloaded; Android only,
  /// empty elsewhere.
  Future<Map<String, bool>> areLanguagesInstalled(List<String> locales) async {
    if (!_isAndroid || locales.isEmpty) return const {};
    final result = await _tts.areLanguagesInstalled(locales);
    if (result is! Map) return const {};
    return {
      for (final entry in result.entries)
        if (entry.key != null) '${entry.key}': _isTrue(entry.value),
    };
  }

  Future<bool> setLanguage(String locale) async =>
      _isTrue(await _tts.setLanguage(locale));

  Future<bool> setVoice(Map<String, String> voice) async =>
      _isTrue(await _tts.setVoice(voice));

  /// Back to the engine's default voice.
  Future<void> clearVoice() => _tts.clearVoice();

  Future<void> setSpeechRate(double rate) => _tts.setSpeechRate(rate);

  Future<void> setPitch(double pitch) => _tts.setPitch(pitch);

  Future<void> setVolume(double volume) => _tts.setVolume(volume);

  /// Reads [text] from its start, replacing anything being read.
  Future<bool> speak(String text) async {
    await _activateSession();
    // iOS treats speak() on a paused utterance as "carry on", whatever the
    // text, so a paused utterance is cleared first.
    await _tts.stop();
    _lastUtterance = text;
    // On Android, focus ducks other audio for as long as this is read.
    return _isTrue(await _tts.speak(text, focus: true));
  }

  /// Carries on with the paused utterance: iOS continues it natively, and
  /// Android starts again from the last word it reached.
  Future<bool> resume() async {
    final text = _lastUtterance;
    if (text == null) return false;
    await _activateSession();
    return _isTrue(await _tts.speak(text, focus: true));
  }

  Future<bool> pause() async => _isTrue(await _tts.pause());

  /// Stops reading; with [release], hands audio back to other apps.
  Future<void> stop({bool release = false}) async {
    await _tts.stop();
    if (release) await _releaseSession();
  }

  /// Writes [text] read aloud to `<temp>/<name>.wav` (`.caf` on iOS, its
  /// native format) and returns the path.
  Future<String> synthesizeToFile(String text, String name) async {
    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/$name.${_isIOS ? 'caf' : 'wav'}';
    final file = File(path);
    if (await file.exists()) await file.delete();

    await _tts.stop();
    _lastUtterance = null;
    _synthesizing = true;
    try {
      final result = await _tts
          .synthesizeToFile(text, path, true)
          .timeout(_synthesisTimeout);
      if (!_isTrue(result) || !await file.exists() || await file.length() == 0) {
        throw const TextToSpeechException('No audio was written');
      }
      return path;
    } finally {
      _synthesizing = false;
    }
  }

  Future<void> _activateSession() async {
    if (!_isIOS || _sessionActive) return;
    await _tts.setSharedInstance(true);
    _sessionActive = true;
  }

  Future<void> _releaseSession() async {
    if (!_isIOS || !_sessionActive) return;
    _sessionActive = false;
    await _tts.setSharedInstance(false);
  }

  static bool _isTrue(Object? result) =>
      result == true || result == 1 || result == '1';

  static List<String> _strings(Object? value) => [
    if (value is List)
      for (final item in value)
        if (item != null && '$item'.isNotEmpty) '$item',
  ];

  static Map<String, String>? _map(Object? value) {
    if (value is! Map) return null;
    return {
      for (final entry in value.entries)
        if (entry.key != null && entry.value != null)
          '${entry.key}': '${entry.value}',
    };
  }

  static List<Map<String, String>> _maps(Object? value) => [
    if (value is List)
      for (final item in value)
        if (_map(item) case final map?) map,
  ];
}
