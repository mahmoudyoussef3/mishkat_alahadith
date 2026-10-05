import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/helpers/hadith_text.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/entities/speech_event.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/entities/speech_track.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/usecases/build_hadith_speech_track_use_case.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/usecases/export_hadith_audio_use_case.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/usecases/get_read_aloud_settings_use_case.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/usecases/inspect_speech_engine_use_case.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/usecases/pause_speech_use_case.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/usecases/prepare_speech_use_case.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/usecases/resume_speech_use_case.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/usecases/save_read_aloud_settings_use_case.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/usecases/speak_text_use_case.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/usecases/stop_speech_use_case.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/usecases/watch_read_aloud_settings_use_case.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/usecases/watch_speech_events_use_case.dart';
import 'package:mishkat_almasabih/features/read_aloud/presentation/logic/read_aloud_cubit.dart';
import 'package:mishkat_almasabih/features/read_aloud/presentation/logic/read_aloud_settings_cubit.dart';
import 'package:mishkat_almasabih/features/read_aloud/presentation/ui/read_aloud_button.dart';
import 'package:mishkat_almasabih/features/read_aloud/presentation/ui/read_aloud_host.dart';
import 'package:mishkat_almasabih/features/read_aloud/presentation/ui/read_aloud_text.dart';

import '../read_aloud_fakes.dart';

final _matn = HadithTextParts.split(bookHadith.text).matn;

/// The cubits a hosted screen reads from, over a fake engine.
///
/// Built inside each test body: futures made outside a widget test's fake
/// clock never complete inside it.
class _Harness {
  _Harness() {
    final prepare = PrepareSpeechUseCase(
      repo,
      InspectSpeechEngineUseCase(repo),
    );
    readAloud = ReadAloudCubit(
      const BuildHadithSpeechTrackUseCase(),
      prepare,
      GetReadAloudSettingsUseCase(repo),
      WatchReadAloudSettingsUseCase(repo),
      WatchSpeechEventsUseCase(repo),
      SpeakTextUseCase(repo),
      PauseSpeechUseCase(repo),
      ResumeSpeechUseCase(repo),
      StopSpeechUseCase(repo),
      ExportHadithAudioUseCase(
        repo,
        prepare,
        const BuildHadithSpeechTrackUseCase(),
      ),
    );
    settings = ReadAloudSettingsCubit(
      GetReadAloudSettingsUseCase(repo),
      SaveReadAloudSettingsUseCase(repo),
      InspectSpeechEngineUseCase(repo),
    );
  }

  final repo = FakeReadAloudRepo();
  late final ReadAloudCubit readAloud;
  late final ReadAloudSettingsCubit settings;

  Future<void> dispose() async {
    await readAloud.close();
    await settings.close();
  }
}

void main() {
  late FakeReadAloudRepo repo;
  late ReadAloudCubit readAloud;
  late ReadAloudSettingsCubit settings;

  void useHarness() {
    final harness = _Harness();
    addTearDown(harness.dispose);
    repo = harness.repo;
    readAloud = harness.readAloud;
    settings = harness.settings;
  }

  /// [child] inside a host, with the host's owner handed to [onOwner].
  Widget hosted(Widget child, {ValueSetter<Object>? onOwner}) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: readAloud),
        BlocProvider.value(value: settings),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        builder:
            (_, _) => MaterialApp(
              home: Directionality(
                textDirection: TextDirection.rtl,
                child: Scaffold(
                  body: ReadAloudHost(
                    child: Builder(
                      builder: (context) {
                        onOwner?.call(ReadAloudHost.ownerOf(context));
                        return child;
                      },
                    ),
                  ),
                ),
              ),
            ),
      ),
    );
  }

  /// The span drawn with the highlight background, if any.
  TextSpan? highlighted(WidgetTester tester) {
    final rich = tester.widget<RichText>(
      find.descendant(
        of: find.byType(ReadAloudText),
        matching: find.byType(RichText),
      ),
    );
    TextSpan? found;
    rich.text.visitChildren((span) {
      if (span is TextSpan &&
          span.style?.backgroundColor == ColorsManager.goldSoft) {
        found = span;
        return false;
      }
      return true;
    });
    return found;
  }

  testWidgets('highlights the word being read on this screen', (tester) async {
    useHarness();
    late Object owner;
    await tester.pumpWidget(
      hosted(
        ReadAloudText(_matn, part: SpeechPart.matn, style: const TextStyle()),
        onOwner: (value) => owner = value,
      ),
    );

    await readAloud.play(owner, bookHadith);
    await readAloud.next();
    repo.emit(const SpeechStarted());
    final start = matnText.indexOf('الأعمال');
    repo.emit(
      SpeechProgress(
        text: matnText,
        start: start,
        end: start + 'الأعمال'.length,
      ),
    );
    await tester.pump();

    expect(highlighted(tester)?.text, 'الأعمال');
  });

  testWidgets('leaves text alone while another screen reads it', (
    tester,
  ) async {
    useHarness();
    await tester.pumpWidget(
      hosted(
        ReadAloudText(_matn, part: SpeechPart.matn, style: const TextStyle()),
      ),
    );

    await readAloud.play(Object(), bookHadith);
    await readAloud.next();
    repo.emit(const SpeechStarted());
    repo.emit(SpeechProgress(text: matnText, start: 0, end: 4));
    await tester.pump();

    expect(highlighted(tester), isNull);
  });

  testWidgets('leaves text alone when highlighting is off', (tester) async {
    useHarness();
    late Object owner;
    await tester.pumpWidget(
      hosted(
        ReadAloudText(_matn, part: SpeechPart.matn, style: const TextStyle()),
        onOwner: (value) => owner = value,
      ),
    );
    await settings.setHighlightWords(false);

    await readAloud.play(owner, bookHadith);
    await readAloud.next();
    repo.emit(const SpeechStarted());
    repo.emit(SpeechProgress(text: matnText, start: 0, end: 4));
    await tester.pump();

    expect(highlighted(tester), isNull);
  });

  testWidgets('closing the screen stops what it was reading', (tester) async {
    useHarness();
    late Object owner;
    await tester.pumpWidget(
      hosted(const SizedBox(), onOwner: (value) => owner = value),
    );
    await readAloud.play(owner, bookHadith);

    await tester.pumpWidget(const SizedBox());
    await tester.pump();

    expect(readAloud.state.status, ReadAloudStatus.idle);
  });

  testWidgets('the listen button starts, then pauses, the reading', (
    tester,
  ) async {
    useHarness();
    await tester.pumpWidget(hosted(const ReadAloudButton(request: bookHadith)));
    expect(find.text('استماع'), findsOneWidget);

    await tester.tap(find.byType(ReadAloudButton));
    await tester.pump();
    await tester.pump();
    expect(find.text('إيقاف مؤقت'), findsOneWidget);

    await tester.tap(find.byType(ReadAloudButton));
    await tester.pump();
    expect(find.text('متابعة'), findsOneWidget);
    expect(readAloud.state.status, ReadAloudStatus.paused);
  });
}
