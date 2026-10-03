import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/data/models/new_daily_hadith_model.dart';
import 'package:mishkat_almasabih/features/hadith_daily/data/datasources/daily_hadith_local_datasource.dart';
import 'package:shared_preferences/shared_preferences.dart';

const MethodChannel _homeWidgetChannel = MethodChannel('home_widget');

/// Mocks the home_widget platform channel and records every call, so tests can
/// assert what reached the native widget storage. When [fail] is true every
/// call throws, simulating a device where the widget can't be updated.
List<MethodCall> _mockHomeWidget({bool fail = false}) {
  final calls = <MethodCall>[];
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_homeWidgetChannel, (call) async {
        calls.add(call);
        if (fail) throw PlatformException(code: 'widget_unavailable');
        return true;
      });
  return calls;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_homeWidgetChannel, null);
  });

  group('DailyHadithLocalDataSource.saveHadith', () {
    test('pushes the new hadith text to the home screen widget', () async {
      final calls = _mockHomeWidget();

      await DailyHadithLocalDataSource().saveHadith(
        const NewDailyHadithModel(id: '1', hadeeth: 'حديث جديد'),
      );

      expect(calls.map((call) => call.method), [
        'saveWidgetData',
        'updateWidget',
      ]);
      expect(calls[0].arguments, {'id': 'hadith_text', 'data': 'حديث جديد'});
      expect(calls[1].arguments, containsPair('name', 'HadithWidgetProvider'));
    });

    test('leaves the widget untouched when the hadith text is empty', () async {
      final calls = _mockHomeWidget();

      await DailyHadithLocalDataSource().saveHadith(
        const NewDailyHadithModel(id: '1', hadeeth: ''),
      );

      expect(calls, isEmpty);
    });

    test('still persists the hadith when the widget update fails', () async {
      _mockHomeWidget(fail: true);
      final repo = DailyHadithLocalDataSource();

      await repo.saveHadith(
        const NewDailyHadithModel(id: '1', hadeeth: 'حديث جديد'),
      );

      expect((await repo.getHadith())?.hadeeth, 'حديث جديد');
    });
  });
}
