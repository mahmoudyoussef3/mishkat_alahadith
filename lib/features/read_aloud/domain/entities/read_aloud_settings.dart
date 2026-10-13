import 'speech_voice.dart';

/// Silence left between two parts of a reading, e.g. after the chain of
/// narrators and before the words of the Prophet ﷺ.
enum SpeechPartGap {
  none(0),
  short(350),
  medium(800),
  long(1500);

  const SpeechPartGap(this.milliseconds);

  final int milliseconds;

  Duration get duration => Duration(milliseconds: milliseconds);
}

/// How hadiths are read aloud. Rate, pitch and volume are what the reader
/// picks; mapping them onto each platform's scale happens when applied.
class ReadAloudSettings {
  /// Reading speed as a multiple of the engine's normal speed.
  final double rate;
  final double pitch;
  final double volume;

  /// The chosen voice; null picks the best Arabic voice automatically.
  final SpeechVoiceRef? voice;

  /// Android speech engine package; null follows the system default.
  final String? engine;

  /// Marks the word being read and keeps it on screen.
  final bool highlightWords;

  /// Reads the hadith number and the section titles («الشرح»…).
  final bool announceHeadings;

  /// Goes on to the explanation, lessons and word meanings after the hadith.
  final bool readExplanation;

  /// Moves to the next hadith of the chapter when one finishes.
  final bool autoContinue;
  final SpeechPartGap partGap;

  const ReadAloudSettings({
    this.rate = 1.0,
    this.pitch = 1.0,
    this.volume = 1.0,
    this.voice,
    this.engine,
    this.highlightWords = true,
    this.announceHeadings = true,
    this.readExplanation = true,
    this.autoContinue = false,
    this.partGap = SpeechPartGap.short,
  });

  static const ReadAloudSettings defaults = ReadAloudSettings();

  /// Speeds offered to the reader, slowest first.
  static const List<double> rates = [0.5, 0.75, 1.0, 1.25, 1.5];

  static const double minPitch = 0.5;
  static const double maxPitch = 1.5;
  static const double minVolume = 0.2;
  static const double maxVolume = 1.0;

  /// The next speed in [rates], wrapping to the slowest after the fastest.
  double get nextRate {
    final index = rates.indexWhere((r) => r > rate + 0.001);
    return index == -1 ? rates.first : rates[index];
  }

  /// Values pulled back into their ranges, e.g. after reading old storage.
  ReadAloudSettings normalized() => ReadAloudSettings(
    rate: rate.clamp(rates.first, rates.last).toDouble(),
    pitch: pitch.clamp(minPitch, maxPitch).toDouble(),
    volume: volume.clamp(minVolume, maxVolume).toDouble(),
    voice: voice,
    engine: engine,
    highlightWords: highlightWords,
    announceHeadings: announceHeadings,
    readExplanation: readExplanation,
    autoContinue: autoContinue,
    partGap: partGap,
  );

  /// True when both make the engine sound the same.
  bool soundsLike(ReadAloudSettings other) =>
      other.rate == rate &&
      other.pitch == pitch &&
      other.volume == volume &&
      other.voice == voice &&
      other.engine == engine;

  ReadAloudSettings copyWith({
    double? rate,
    double? pitch,
    double? volume,
    SpeechVoiceRef? voice,
    bool clearVoice = false,
    String? engine,
    bool clearEngine = false,
    bool? highlightWords,
    bool? announceHeadings,
    bool? readExplanation,
    bool? autoContinue,
    SpeechPartGap? partGap,
  }) {
    return ReadAloudSettings(
      rate: rate ?? this.rate,
      pitch: pitch ?? this.pitch,
      volume: volume ?? this.volume,
      voice: clearVoice ? null : voice ?? this.voice,
      engine: clearEngine ? null : engine ?? this.engine,
      highlightWords: highlightWords ?? this.highlightWords,
      announceHeadings: announceHeadings ?? this.announceHeadings,
      readExplanation: readExplanation ?? this.readExplanation,
      autoContinue: autoContinue ?? this.autoContinue,
      partGap: partGap ?? this.partGap,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ReadAloudSettings &&
      soundsLike(other) &&
      other.highlightWords == highlightWords &&
      other.announceHeadings == announceHeadings &&
      other.readExplanation == readExplanation &&
      other.autoContinue == autoContinue &&
      other.partGap == partGap;

  @override
  int get hashCode => Object.hash(
    rate,
    pitch,
    volume,
    voice,
    engine,
    highlightWords,
    announceHeadings,
    readExplanation,
    autoContinue,
    partGap,
  );
}
