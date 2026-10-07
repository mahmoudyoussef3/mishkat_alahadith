import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/di/dependency_injection.dart';
import 'package:mishkat_almasabih/core/helpers/arabic_time_format.dart';
import 'package:mishkat_almasabih/core/helpers/extensions.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/core/widgets/app_switch.dart';
import 'package:mishkat_almasabih/core/widgets/settings_group.dart';
import 'package:mishkat_almasabih/core/widgets/snackbars.dart';
import 'package:mishkat_almasabih/features/prayer_times/presentation/logic/notifications/prayer_notifications_cubit.dart';

/// Prayer notifications on/off, manual re-sync, the location times are
/// calculated for, and a battery hint when the OS may delay alerts.
class PrayerNotificationSettingsSection extends StatelessWidget {
  const PrayerNotificationSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PrayerNotificationsCubit>()..load(),
      child: BlocConsumer<PrayerNotificationsCubit, PrayerNotificationsState>(
        listenWhen:
            (previous, current) =>
                current.notice != null &&
                !identical(previous.notice, current.notice),
        listener: (context, state) {
          final notice = state.notice!;
          if (notice.isError) {
            showErrorSnackbar(context, notice.message);
          } else {
            showInfoSnackbar(context, notice.message);
          }
        },
        builder: (context, state) => _PrayerSettings(state: state),
      ),
    );
  }
}

class _PrayerSettings extends StatelessWidget {
  const _PrayerSettings({required this.state});

  final PrayerNotificationsState state;

  /// The location is changed on the prayer times screen; reload afterwards.
  Future<void> _openLocation(BuildContext context) async {
    final cubit = context.read<PrayerNotificationsCubit>();
    await context.pushNamed(Routes.prayerTimesScreen);
    if (!cubit.isClosed) await cubit.load();
  }

  String get _syncSubtitle {
    final lastSyncedAt = state.lastSyncedAt;
    if (!state.enabled) return 'تعمل عند تفعيل الإشعارات';
    if (lastSyncedAt == null) return 'لم تتم المزامنة بعد';
    return 'آخر مزامنة: ${formatArabicDayAndTime(lastSyncedAt, now: DateTime.now())}';
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PrayerNotificationsCubit>();
    final busy = state.isBusy;

    return SettingsGroup(
      title: 'مواقيت الصلاة',
      footer:
          state.showBatteryReliabilityAction
              ? _BatteryHint(onTap: busy ? null : cubit.improveReliability)
              : null,
      children: [
        SettingsTile(
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
        ),
        SettingsTile(
          icon: Icons.sync_rounded,
          title: 'مزامنة الإشعارات',
          subtitle: _syncSubtitle,
          trailing: _SyncButton(
            busy: busy,
            onPressed: state.enabled && !busy ? cubit.refresh : null,
          ),
        ),
        SettingsTile(
          icon: Icons.location_on_rounded,
          title: 'الموقع',
          subtitle: state.locationName ?? '…',
          onTap: () => _openLocation(context),
        ),
      ],
    );
  }
}

class _SyncButton extends StatelessWidget {
  const _SyncButton({required this.busy, required this.onPressed});

  final bool busy;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    if (busy) {
      return SizedBox.square(
        dimension: 20.r,
        child: const CircularProgressIndicator(strokeWidth: 2),
      );
    }
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: ColorsManager.primarySoft,
        disabledBackgroundColor: ColorsManager.lightGray,
        minimumSize: Size(0, 32.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
      child: Text(
        'مزامنة',
        style: TextStyles.chipLabel.copyWith(
          color:
              onPressed == null
                  ? ColorsManager.disabledText
                  : ColorsManager.purpleText,
        ),
      ),
    );
  }
}

class _BatteryHint extends StatelessWidget {
  const _BatteryHint({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ColorsManager.goldSoft,
      borderRadius: BorderRadius.circular(20.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.battery_alert_rounded,
                size: 22.r,
                color: ColorsManager.primaryGold,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'لضمان وصول التنبيهات في وقتها، استثنِ التطبيق من تحسين البطارية.',
                      style: TextStyles.caption.copyWith(
                        fontSize: 13.sp,
                        height: 1.8,
                        color: ColorsManager.goldInk,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Text(
                          'تحسين موثوقية التنبيهات',
                          style: TextStyles.actionLabel,
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 18.r,
                          color: ColorsManager.purpleText,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
