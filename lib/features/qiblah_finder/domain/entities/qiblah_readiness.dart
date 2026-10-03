enum QiblahReadiness {
  ready,
  sensorUnsupported,
  locationDisabled,
  permissionDenied,
  permissionDeniedForever,
}

enum QiblahPermission { granted, denied, deniedForever, undetermined }

class QiblahLocationStatus {
  final bool enabled;
  final QiblahPermission permission;

  const QiblahLocationStatus({required this.enabled, required this.permission});
}
