part of 'notification_toggle_cubit.dart';

class NotificationToggleNotice {
  final String message;
  final bool isError;

  NotificationToggleNotice(this.message, {this.isError = false});
}

class NotificationToggleState {
  final bool enabled;
  final bool isBusy;
  final NotificationToggleNotice? notice;

  const NotificationToggleState({
    this.enabled = false,
    this.isBusy = false,
    this.notice,
  });

  /// A [notice] is shown once, so it is dropped unless passed again.
  NotificationToggleState copyWith({
    bool? enabled,
    bool? isBusy,
    NotificationToggleNotice? notice,
  }) {
    return NotificationToggleState(
      enabled: enabled ?? this.enabled,
      isBusy: isBusy ?? this.isBusy,
      notice: notice,
    );
  }
}
