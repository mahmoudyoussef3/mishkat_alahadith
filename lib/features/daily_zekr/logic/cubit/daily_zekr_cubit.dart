import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:mishkat_almasabih/core/notification/local_notification.dart';
import 'package:mishkat_almasabih/features/daily_zekr/data/models/zekr_item.dart';
import 'package:mishkat_almasabih/features/daily_zekr/data/repo/zekr_repository.dart';

part 'daily_zekr_state.dart';

class DailyZekrCubit extends Cubit<DailyZekrState> {
  final ZekrRepository _repo;

  DailyZekrCubit(this._repo) : super(DailyZekrInitial());

  /// Load persisted states and ensure notifications reflect current status.
  Future<void> init() async {
    emit(DailyZekrLoading());
    try {
      final items = await _repo.loadAll();
      // Sync notifications for each section
      for (final item in items) {
        await _syncNotifications(item);
      }
      emit(DailyZekrLoaded(items));
    } catch (e) {
      emit(DailyZekrError('حدث خطأ أثناء تحميل البيانات')); // Arabic error
    }
  }

  /// Toggle a section, persist the change, and schedule/cancel notifications.
  Future<void> toggle(ZekrSection section) async {
    final current = state;
    if (current is! DailyZekrLoaded) return;

    final items = current.items
        .map((it) {
          if (it.section == section) return it.copyWith(checked: !it.checked);
          return it;
        })
        .toList(growable: false);

    // Persist and sync notifications for the toggled item
    final updatedItem = items.firstWhere((it) => it.section == section);
    await _repo.setChecked(section, updatedItem.checked);
    await _syncNotifications(updatedItem);

    emit(DailyZekrLoaded(items));
  }

  Future<void> _syncNotifications(ZekrItem item) async {
    if (item.checked) {
      // Stop notifications for checked sections
      await LocalNotification.cancelReminder(item.section.notificationId);
    } else {
      // Schedule hourly reminder when unchecked
      await LocalNotification.scheduleHourlyReminder(
        id: item.section.notificationId,
        channelId: item.section.channelId,
        channelName: item.section.channelName,
        title: item.section.title,
        body: item.section.reminderBody,
        payload: item.section.name,
      );
    }
  }
}
