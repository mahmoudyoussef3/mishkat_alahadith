part of 'read_aloud_settings_cubit.dart';

class ReadAloudSettingsState {
  final ReadAloudSettings settings;

  /// What the engine offers; null until inspected.
  final SpeechEngineReport? report;

  /// The saved settings have been read.
  final bool loaded;
  final bool inspecting;
  final bool inspectionFailed;

  const ReadAloudSettingsState({
    this.settings = ReadAloudSettings.defaults,
    this.report,
    this.loaded = false,
    this.inspecting = false,
    this.inspectionFailed = false,
  });

  ReadAloudSettingsState copyWith({
    ReadAloudSettings? settings,
    SpeechEngineReport? report,
    bool? loaded,
    bool? inspecting,
    bool? inspectionFailed,
  }) {
    return ReadAloudSettingsState(
      settings: settings ?? this.settings,
      report: report ?? this.report,
      loaded: loaded ?? this.loaded,
      inspecting: inspecting ?? this.inspecting,
      inspectionFailed: inspectionFailed ?? this.inspectionFailed,
    );
  }
}
