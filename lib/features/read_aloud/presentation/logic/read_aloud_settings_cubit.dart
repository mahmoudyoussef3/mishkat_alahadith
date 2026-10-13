import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/entities/read_aloud_settings.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/entities/speech_engine.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/entities/speech_voice.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/usecases/get_read_aloud_settings_use_case.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/usecases/inspect_speech_engine_use_case.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/usecases/save_read_aloud_settings_use_case.dart';

part 'read_aloud_settings_state.dart';

/// The reader's listening settings, and the voices and engines the device
/// offers to choose from. Changes apply at once and are saved behind; a
/// reading in progress follows them.
class ReadAloudSettingsCubit extends Cubit<ReadAloudSettingsState> {
  final GetReadAloudSettingsUseCase _getSettings;
  final SaveReadAloudSettingsUseCase _saveSettings;
  final InspectSpeechEngineUseCase _inspectEngine;

  ReadAloudSettingsCubit(
    this._getSettings,
    this._saveSettings,
    this._inspectEngine,
  ) : super(const ReadAloudSettingsState());

  Future<void>? _loading;

  /// Reads the saved settings once.
  Future<void> load() => _loading ??= _load();

  Future<void> _load() async {
    final result = await _getSettings();
    if (isClosed) return;
    emit(
      state.copyWith(
        settings: switch (result) {
          ApiSuccess(:final data) => data,
          ApiFailure() => state.settings,
        },
        loaded: true,
      ),
    );
  }

  /// Finds the voices and engines the device offers, and which voice will
  /// read.
  Future<void> inspectEngine() async {
    await load();
    if (isClosed) return;
    final settings = state.settings;
    emit(state.copyWith(inspecting: true, inspectionFailed: false));
    final result = await _inspectEngine(settings);
    // A newer choice is already being inspected.
    if (isClosed || state.settings.engine != settings.engine) return;
    emit(switch (result) {
      ApiSuccess(:final data) => state.copyWith(
        report: data,
        inspecting: false,
      ),
      ApiFailure() => state.copyWith(inspecting: false, inspectionFailed: true),
    });
  }

  Future<void> setRate(double rate) =>
      _update(state.settings.copyWith(rate: rate));

  /// Steps to the next speed, from the fastest back to the slowest.
  Future<void> cycleRate() => setRate(state.settings.nextRate);

  Future<void> setPitch(double pitch) =>
      _update(state.settings.copyWith(pitch: pitch));

  Future<void> setVolume(double volume) =>
      _update(state.settings.copyWith(volume: volume));

  Future<void> setHighlightWords(bool value) =>
      _update(state.settings.copyWith(highlightWords: value));

  Future<void> setAnnounceHeadings(bool value) =>
      _update(state.settings.copyWith(announceHeadings: value));

  Future<void> setReadExplanation(bool value) =>
      _update(state.settings.copyWith(readExplanation: value));

  Future<void> setAutoContinue(bool value) =>
      _update(state.settings.copyWith(autoContinue: value));

  Future<void> setPartGap(SpeechPartGap gap) =>
      _update(state.settings.copyWith(partGap: gap));

  /// Null returns to automatic selection.
  Future<void> selectVoice(SpeechVoice? voice) => _update(
    voice == null
        ? state.settings.copyWith(clearVoice: true)
        : state.settings.copyWith(voice: voice.ref),
    reinspect: true,
  );

  /// Null follows the system default. Voices belong to an engine, so the
  /// voice returns to automatic.
  Future<void> selectEngine(String? engine) => _update(
    state.settings.copyWith(
      engine: engine,
      clearEngine: engine == null,
      clearVoice: true,
    ),
    reinspect: true,
  );

  Future<void> reset() => _update(ReadAloudSettings.defaults, reinspect: true);

  Future<void> _update(ReadAloudSettings next, {bool reinspect = false}) async {
    final normalized = next.normalized();
    if (normalized == state.settings) return;
    emit(state.copyWith(settings: normalized));
    await _saveSettings(normalized);
    if (reinspect && state.report != null) await inspectEngine();
  }
}
