import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';

part 'notification_toggle_state.dart';

/// The switch for one kind of notification the reader turns on or off.
///
/// Each kind subclasses it with its own use cases and wording, so each has a
/// type of its own to be provided and looked up by.
class NotificationToggleCubit extends Cubit<NotificationToggleState> {
  final Future<ApiResult<bool>> Function() _isEnabled;
  final Future<ApiResult<void>> Function(bool enabled) _setEnabled;
  final String _enabledMessage;
  final String _disabledMessage;

  NotificationToggleCubit({
    required Future<ApiResult<bool>> Function() isEnabled,
    required Future<ApiResult<void>> Function(bool enabled) setEnabled,
    required String enabledMessage,
    required String disabledMessage,
  }) : _isEnabled = isEnabled,
       _setEnabled = setEnabled,
       _enabledMessage = enabledMessage,
       _disabledMessage = disabledMessage,
       super(const NotificationToggleState());

  Future<void> load() async {
    final enabled = await _currentlyEnabled();
    if (isClosed) return;
    emit(state.copyWith(enabled: enabled));
  }

  Future<void> toggle(bool enabled) async {
    if (state.isBusy) return;
    emit(state.copyWith(isBusy: true));

    final result = await _setEnabled(enabled);
    if (isClosed) return;
    switch (result) {
      case ApiSuccess():
        emit(
          state.copyWith(
            isBusy: false,
            enabled: enabled,
            notice: NotificationToggleNotice(
              enabled ? _enabledMessage : _disabledMessage,
            ),
          ),
        );
      case ApiFailure(:final failure):
        // The choice may have been saved even though applying it failed, so
        // the switch shows what was actually kept.
        final current = await _currentlyEnabled();
        if (isClosed) return;
        emit(
          state.copyWith(
            isBusy: false,
            enabled: current,
            notice: NotificationToggleNotice(failure.message, isError: true),
          ),
        );
    }
  }

  /// Null when it cannot be read, so the switch keeps what it shows.
  Future<bool?> _currentlyEnabled() async => switch (await _isEnabled()) {
    ApiSuccess(:final data) => data,
    ApiFailure() => null,
  };
}
