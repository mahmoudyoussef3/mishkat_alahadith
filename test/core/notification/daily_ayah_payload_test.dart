import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/notification/daily_ayah_payload.dart';
import 'package:mishkat_almasabih/core/notification/firebase_service/notification_factories.dart';
import 'package:mishkat_almasabih/core/notification/firebase_service/notification_handler.dart';

void main() {
  const ayatAlKursi = DailyAyahPayload(ayahId: 262, page: 42, surahNumber: 2);

  test('reads back what it writes', () {
    expect(DailyAyahPayload.tryParse(ayatAlKursi.encode()), ayatAlKursi);
  });

  test('is written in the format the native widget hands back', () {
    expect(ayatAlKursi.encode(), 'daily_ayah:262:42:2');
  });

  for (final other in [
    null,
    '',
    'project_status',
    'daily_ayah',
    'daily_ayah:262:42',
    'daily_ayah:262:42:2:9',
    'daily_ayah:x:42:2',
    'daily_ayah:0:42:2',
    'daily_ayah:6237:42:2',
    'daily_ayah:262:605:2',
    'daily_ayah:262:42:115',
    'other:262:42:2',
  ]) {
    test('is not read from "$other"', () {
      expect(DailyAyahPayload.tryParse(other), isNull);
    });
  }

  test('a tapped daily ayah notification opens that ayah', () {
    final handler = NotificationHandlerFactory.getHandler(ayatAlKursi.encode());

    expect(
      handler,
      isA<OpenDailyAyah>().having((h) => h.payload, 'payload', ayatAlKursi),
    );
  });

  test('other notification types keep their own handlers', () {
    expect(
      NotificationHandlerFactory.getHandler('order_status'),
      isA<OrderStatus>(),
    );
  });
}
