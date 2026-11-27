import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/di/dependency_injection.dart';
import 'package:mishkat_almasabih/core/helpers/arabic_digits.dart';
import 'package:mishkat_almasabih/core/helpers/arabic_plurals.dart';
import 'package:mishkat_almasabih/core/notification/notification_toggle/notification_toggle_cubit.dart';
import 'package:mishkat_almasabih/core/prayer/prayer_defaults.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/widgets/app_switch.dart';
import 'package:mishkat_almasabih/core/widgets/settings_group.dart';
import 'package:mishkat_almasabih/core/widgets/snackbars.dart';
import 'package:mishkat_almasabih/features/daily_ayah/domain/usecases/sync_daily_ayah_use_case.dart';
import 'package:mishkat_almasabih/features/daily_ayah/presentation/logic/daily_ayah_reminder_cubit.dart';
import 'package:mishkat_almasabih/features/hadith_daily/presentation/logic/daily_hadith_notification_cubit.dart';
import 'package:mishkat_almasabih/features/prayer_times/presentation/logic/notifications/prayer_notifications_cubit.dart';
import 'package:mishkat_almasabih/features/prayer_times/presentation/logic/notifications/prayer_pre_reminder_cubit.dart';
import 'package:mishkat_almasabih/features/quran_wird/domain/usecases/sync_quran_wird_reminder_use_case.dart';
import 'package:mishkat_almasabih/features/quran_wird/presentation/logic/quran_wird_reminder_cubit.dart';

import 'prayer_notification_settings_section.dart';

/// A switch for every notification the app sends, then the prayer times
/// those for prayer are calculated from.
class NotificationSettingsSection extends StatelessWidget {
  const NotificationSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<PrayerNotificationsCubit>()..load()),
        BlocProvider(create: (_) => getIt<PrayerPreReminderCubit>()..load()),
        BlocProvider(
          create: (_) => getIt<DailyHadithNotificationCubit>()..load(),
        ),
        BlocProvider(create: (_) => getIt<DailyAyahReminderCubit>()..load()),
        BlocProvider(create: (_) => getIt<QuranWirdReminderCubit>()..load()),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<PrayerNotificationsCubit, PrayerNotificationsState>(
            listenWhen:
                (previous, current) =>
                    current.notice != null &&
                    !identical(previous.notice, current.notice),
            listener: (context, state) {
              final notice = state.notice!;
              _showNotice(context, notice.message, isError: notice.isError);
            },
          ),
          // Adding or removing the reminders reschedules every prayer
          // notification, so the sync time shown below moves on.
          _noticeListener<PrayerPreReminderCubit>(
            onSuccess:
                (context) => context.read<PrayerNotificationsCubit>().load(),
          ),
          _noticeListener<DailyHadithNotificationCubit>(),
          _noticeListener<DailyAyahReminderCubit>(),
          _noticeListener<QuranWirdReminderCubit>(),
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _NotificationsGroup(),
            SizedBox(height: 18.h),
            const PrayerNotificationSettingsSection(),
          ],
        ),
      ),
    );
  }

  static BlocListener<C, NotificationToggleState>
  _noticeListener<C extends NotificationToggleCubit>({
    void Function(BuildContext context)? onSuccess,
  }) => BlocListener<C, NotificationToggleState>(
    listenWhen:
        (previous, current) =>
            current.notice != null &&
            !identical(previous.notice, current.notice),
    listener: (context, state) {
      final notice = state.notice!;
      _showNotice(context, notice.message, isError: notice.isError);
      if (!notice.isError) onSuccess?.call(context);
    },
  );

  static void _showNotice(
    BuildContext context,
    String message, {
    required bool isError,
  }) {
    if (isError) {
      showErrorSnackbar(context, message);
    } else {
      showInfoSnackbar(context, message);
    }
  }
}

class _NotificationsGroup extends StatelessWidget {
  const _NotificationsGroup();

  static final String _ayahSubtitle =
      'آية من القرآن الكريم كل يوم الساعة '
      '${_arabicHour(SyncDailyAyahUseCase.reminderHour)}';

  static final String _wirdSubtitle =
      'تذكير بقراءة وردك كل يوم الساعة '
      '${_arabicHour(SyncQuranWirdReminderUseCase.reminderHour)}';

  @override
  Widget build(BuildContext context) {
    return SettingsGroup(
      title: 'الإشعارات',
      children: [
        const _PrayerTile(),
        const _PreReminderTile(),
        _ToggleTile<DailyHadithNotificationCubit>(
          icon: Icons.format_quote_rounded,
          title: 'حديث اليوم',
          subtitle: 'حديث نبوي مع شرحه كل يوم',
        ),
        _ToggleTile<DailyAyahReminderCubit>(
          icon: Icons.menu_book_rounded,
          iconColor: ColorsManager.success,
          iconBackground: ColorsManager.successSoft,
          title: 'آية اليوم',
          subtitle: _ayahSubtitle,
        ),
        _ToggleTile<QuranWirdReminderCubit>(
          icon: Icons.auto_stories_rounded,
          iconColor: ColorsManager.success,
          iconBackground: ColorsManager.successSoft,
          title: 'الورد اليومي',
          subtitle: _wirdSubtitle,
        ),
      ],
    );
  }
}

/// "٨ صباحًا", "٨ مساءً": an hour on the hour, the way the subtitles say it.
String _arabicHour(int hour) {
  final onDial = hour % 12 == 0 ? 12 : hour % 12;
  return '${toArabicDigits('$onDial')} ${hour < 12 ? 'صباحًا' : 'مساءً'}';
}

class _PrayerTile extends StatelessWidget {
  const _PrayerTile();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrayerNotificationsCubit, PrayerNotificationsState>(
      buildWhen:
          (previous, current) =>
              previous.enabled != current.enabled ||
              previous.isBusy != current.isBusy,
      builder: (context, state) {
        final cubit = context.read<PrayerNotificationsCubit>();
        final busy = state.isBusy;
        return SettingsTile(
          icon: Icons.notifications_rounded,
          iconBackground: ColorsManager.goldSoft,
          iconColor: ColorsManager.primaryGold,
          title: 'إشعارات الصلاة',
          subtitle: 'الفجر · الظهر · العصر · المغرب · العشاء',
          onTap: busy ? null : () => cubit.toggle(!state.enabled),
          trailing: AppSwitch(
            value: state.enabled,
            semanticLabel: 'إشعارات الصلاة',
            onChanged: busy ? null : cubit.toggle,
          ),
        );
      },
    );
  }
}

/// Goes out with the prayer notifications, so it waits on their switch.
class _PreReminderTile extends StatelessWidget {
  const _PreReminderTile();

  static final String _subtitle =
      'قبل الأذان بـ'
      '${arabicCount(PrayerDefaults.preReminderLead.inMinutes, ArabicNoun.minute)}'
      ' للاستعداد للصلاة';

  @override
  Widget build(BuildContext context) {
    return BlocSelector<PrayerNotificationsCubit, PrayerNotificationsState, bool>(
      selector: (state) => state.enabled,
      builder:
          (context, prayerEnabled) => _ToggleTile<PrayerPreReminderCubit>(
            icon: Icons.alarm_rounded,
            iconBackground: ColorsManager.goldSoft,
            iconColor: ColorsManager.primaryGold,
            title: 'التذكير قبل الصلاة',
            subtitle: prayerEnabled ? _subtitle : 'يعمل مع إشعارات الصلاة',
            available: prayerEnabled,
          ),
    );
  }
}

/// One notification's switch, rebuilt alone when its cubit changes.
class _ToggleTile<C extends NotificationToggleCubit> extends StatelessWidget {
  const _ToggleTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconColor,
    this.iconBackground,
    this.available = true,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color? iconColor;
  final Color? iconBackground;

  /// False while it depends on another notification that is off.
  final bool available;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<C, NotificationToggleState>(
      builder: (context, state) {
        final onChanged =
            state.isBusy || !available ? null : context.read<C>().toggle;
        return SettingsTile(
          icon: icon,
          iconColor: iconColor,
          iconBackground: iconBackground,
          title: title,
          subtitle: subtitle,
          onTap: onChanged == null ? null : () => onChanged(!state.enabled),
          trailing: AppSwitch(
            value: state.enabled,
            semanticLabel: title,
            onChanged: onChanged,
          ),
        );
      },
    );
  }
}
