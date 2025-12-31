part of 'qiblah_cubit.dart';

@immutable
sealed class QiblahState {
  const QiblahState();
}

final class QiblahInitial extends QiblahState {}

final class QiblahLoading extends QiblahState {}

final class QiblahReady extends QiblahState {}

final class QiblahSensorUnsupported extends QiblahState {}

final class QiblahLocationDisabled extends QiblahState {}

final class QiblahPermissionDenied extends QiblahState {}

final class QiblahPermissionDeniedForever extends QiblahState {}

final class QiblahError extends QiblahState {
  final String message;
  const QiblahError(this.message);
}
