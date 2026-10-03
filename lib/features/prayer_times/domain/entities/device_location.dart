enum LocationAccess { granted, serviceDisabled, denied, deniedForever }

class DevicePosition {
  final double latitude;
  final double longitude;

  const DevicePosition({required this.latitude, required this.longitude});
}
