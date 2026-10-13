import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/hadith_speech_request.dart';
import '../entities/read_aloud_settings.dart';
import '../entities/speech_engine.dart';
import '../entities/speech_track.dart';
import '../repos/read_aloud_repo.dart';
import 'build_hadith_speech_track_use_case.dart';
import 'prepare_speech_use_case.dart';

/// Records a hadith read aloud into an audio file to share.
///
/// Only the hadith and its source are recorded, not its explanation: the
/// file is meant to be sent, and engines cap how much one file can hold.
class ExportHadithAudioUseCase {
  final ReadAloudRepo _repo;
  final PrepareSpeechUseCase _prepare;
  final BuildHadithSpeechTrackUseCase _buildTrack;

  ExportHadithAudioUseCase(this._repo, this._prepare, this._buildTrack);

  /// The path of the file written.
  Future<ApiResult<String>> call(
    HadithSpeechRequest request,
    ReadAloudSettings settings,
  ) async {
    final prepared = await _prepare(settings);
    final SpeechEngineReport report;
    switch (prepared) {
      case ApiSuccess(:final data):
        report = data;
      case ApiFailure(:final failure):
        return ApiResult.failure(failure);
    }

    final track = _buildTrack(
      request,
      settings.copyWith(readExplanation: false),
    );
    final script = joinSegments(track.segments);
    if (script.isEmpty) return const ApiResult.failure(SpeechFailure());

    final maxLength = report.maxInputLength;
    if (maxLength != null && script.length > maxLength) {
      return const ApiResult.failure(
        SpeechFailure(FailureMessages.speechTooLong),
      );
    }
    return _repo.synthesizeToFile(script, name: fileNameFor(request));
  }

  static const _pause = {'.', '!', '?', '؟', '…', '،', '؛', ':', ','};

  /// One text for the whole recording, with a sentence break between parts
  /// so the voice pauses where the screen starts a new block.
  static String joinSegments(List<SpeechSegment> segments) {
    final buffer = StringBuffer();
    for (final segment in segments) {
      final text = segment.spoken.trim();
      if (text.isEmpty) continue;
      if (buffer.isNotEmpty) {
        final written = buffer.toString();
        buffer.write(_pause.contains(written[written.length - 1]) ? ' ' : '. ');
      }
      buffer.write(text);
    }
    return buffer.toString();
  }

  /// A file name safe on every platform, without extension.
  static String fileNameFor(HadithSpeechRequest request) {
    final safe = request.key
        .replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    return safe.isEmpty ? 'hadith' : 'hadith_$safe';
  }
}
