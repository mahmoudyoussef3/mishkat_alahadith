import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/widgets/answer_view.dart';

const _answer = '''
## المعنى الإجمالي
يأمر النبي ﷺ بإتمام الركوع والسجود والطمأنينة فيهما، وهذا **أصل عظيم** في الصلاة.

من فوائد الحديث:
1. وجوب الطمأنينة في الركوع والسجود.
2. معجزة للنبي ﷺ في رؤيته من خلفه في الصلاة.

«أَتِمُّوا الرُّكُوعَ وَالسُّجُودَ»
''';

Widget _host(Widget child) => ScreenUtilInit(
  designSize: const Size(375, 812),
  builder:
      (_, _) => MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(body: SingleChildScrollView(child: child)),
        ),
      ),
);

void main() {
  testWidgets('typesets headings, numbered points and quotes', (tester) async {
    await tester.pumpWidget(_host(const AnswerView(text: _answer)));

    expect(find.text('المعنى الإجمالي'), findsOneWidget);
    expect(find.text('من فوائد الحديث'), findsOneWidget);
    expect(find.text('١'), findsOneWidget);
    expect(find.text('٢'), findsOneWidget);
    expect(find.text('«أَتِمُّوا الرُّكُوعَ وَالسُّجُودَ»'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('leads plain text with the fallback heading', (tester) async {
    await tester.pumpWidget(
      _host(
        const AnswerView(
          text: 'هذا تحليل في فقرة واحدة.',
          fallbackHeading: 'المعنى الإجمالي',
        ),
      ),
    );

    expect(find.text('المعنى الإجمالي'), findsOneWidget);
  });

  testWidgets('lays out on a narrow screen without overflow', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_host(const AnswerView(text: _answer)));

    expect(tester.takeException(), isNull);
  });
}
