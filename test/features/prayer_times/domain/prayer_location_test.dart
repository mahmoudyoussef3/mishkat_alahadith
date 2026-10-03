import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/features/prayer_times/domain/entities/prayer_location.dart';

void main() {
  PrayerLocation deviceAt(int offsetHours) => PrayerLocation.currentDevice(
    latitude: 1,
    longitude: 2,
    utcOffset: Duration(hours: offsetHours),
  );

  test('labels the device position as the current location', () {
    expect(deviceAt(2).cityName, 'موقعك الحالي');
  });

  test('formats a positive UTC offset with a plus sign', () {
    expect(deviceAt(3).timezone, '+3.0');
  });

  test('formats a negative UTC offset with its minus sign', () {
    expect(deviceAt(-5).timezone, '-5.0');
  });
}
