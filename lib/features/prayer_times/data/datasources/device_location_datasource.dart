import 'package:geolocator/geolocator.dart';

import '../../domain/entities/device_location.dart';

class DeviceLocationDataSource {
  Future<LocationAccess> requestAccess() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return LocationAccess.serviceDisabled;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return switch (permission) {
      LocationPermission.denied => LocationAccess.denied,
      LocationPermission.deniedForever => LocationAccess.deniedForever,
      _ => LocationAccess.granted,
    };
  }

  Future<DevicePosition> getCurrentPosition() async {
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      ),
    );
    return DevicePosition(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }
}
