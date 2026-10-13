import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/theming/app_palette.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/widgets/app_badge.dart';
import 'package:mishkat_almasabih/features/ahadith/presentation/ui/widgets/chapter_ahadith_card.dart';

Widget _card({String? grade, String? category, String? bookName}) =>
    ScreenUtilInit(
      designSize: const Size(375, 812),
      builder:
          (_, __) => MaterialApp(
            home: Directionality(
              textDirection: TextDirection.rtl,
              child: Scaffold(
                body: ChapterAhadithCard(
                  number: '1',
                  text: 'إِنَّمَا الْأَعْمَالُ بِالنِّيَّاتِ',
                  grade: grade,
                  hadithCategory: category,
                  bookName: bookName,
                  reference: 'كتاب بدء الوحي',
                ),
              ),
            ),
          ),
    );

void main() {
  tearDown(() => ColorsManager.usePalette(AppPalette.light));

  testWidgets('shows a recognised grade as a grade badge', (tester) async {
    await tester.pumpWidget(_card(grade: 'Sahih'));

    expect(find.byType(GradeBadge), findsOneWidget);
    expect(find.text('صحيح'), findsOneWidget);
  });

  testWidgets('shows a compound grade such as "Hasan Sahih" as a badge', (
    tester,
  ) async {
    await tester.pumpWidget(_card(grade: 'Hasan Sahih'));

    expect(find.byType(GradeBadge), findsOneWidget);
  });

  testWidgets('shows a non-grade value, such as a position, as plain text', (
    tester,
  ) async {
    await tester.pumpWidget(_card(grade: '٣'));

    expect(find.byType(GradeBadge), findsNothing);
    expect(find.text('٣'), findsOneWidget);
  });

  testWidgets('joins the book and reference into the source line', (
    tester,
  ) async {
    await tester.pumpWidget(_card(bookName: 'صحيح البخاري'));

    expect(find.text('صحيح البخاري · كتاب بدء الوحي'), findsOneWidget);
  });

  for (final palette in [AppPalette.light, AppPalette.dark]) {
    final name = palette.isDark ? 'dark' : 'light';

    testWidgets('lays out a long category without overflow in $name mode', (
      tester,
    ) async {
      ColorsManager.usePalette(palette);
      await tester.pumpWidget(
        _card(
          grade: 'حسن صحيح',
          category: 'فضائل الأعمال والآداب والأخلاق الإسلامية الحميدة',
        ),
      );

      expect(tester.takeException(), isNull);
    });
  }
}
