import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/di/dependency_injection.dart';
import 'package:mishkat_almasabih/core/helpers/arabic_time_format.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/core/widgets/app_icon_button.dart';
import 'package:mishkat_almasabih/core/widgets/app_switch.dart';
import 'package:mishkat_almasabih/core/widgets/detail_header.dart';
import 'package:mishkat_almasabih/core/widgets/settings_group.dart';
import 'package:mishkat_almasabih/core/widgets/snackbars.dart';
import 'package:mishkat_almasabih/core/widgets/state_message.dart';
import 'package:mishkat_almasabih/features/prayer_times/presentation/logic/notifications/prayer_notifications_cubit.dart';
import 'package:mishkat_almasabih/features/prayer_times/presentation/logic/prayer_times_cubit.dart';
import 'package:mishkat_almasabih/features/prayer_times/presentation/ui/widgets/location_selection_dialog.dart';
import 'package:mishkat_almasabih/features/prayer_times/presentation/ui/widgets/next_prayer_card.dart';
import 'package:mishkat_almasabih/features/prayer_times/presentation/ui/widgets/prayer_times_grid.dart';

/// Today's countdown to the next prayer, the times of any day, and the
/// location and alert settings behind them.
class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PrayerTimesCubit>().init();
  }

  void _chooseLocation() {
    final cubit = context.read<PrayerTimesCubit>();
    showPrayerLocationSheet(
      context,
      current: cubit.currentLocation,
      onSelected: cubit.updateLocation,
      onUseCurrentLocation: cubit.useCurrentLocation,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PrayerNotificationsCubit>()..load(),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: ColorsManager.secondaryBackground,
          body: SafeArea(
            bottom: false,
            child: BlocConsumer<PrayerTimesCubit, PrayerTimesState>(
              listenWhen: (_, current) => current is PrayerTimesError,
              listener:
                  (context, state) => showErrorSnackbar(
                    context,
                    (state as PrayerTimesError).message,
                  ),
              // The cubit ticks every second; only the countdown follows
              // the ticks (see _Countdown). A failure that keeps the old
              // times is reported by the listener alone.
              buildWhen: (previous, current) {
                if (current is PrayerTimesError) {
                  return previous is! PrayerTimesLoaded;
                }
                if (previous is PrayerTimesLoaded &&
                    current is PrayerTimesLoaded) {
                  return previous.date != current.date ||
                      previous.selectedDate != current.selectedDate ||
                      !identical(previous.selectedTimes, current.selectedTimes) ||
                      previous.nextPrayerTime != current.nextPrayerTime;
                }
                return true;
              },
              builder: (context, state) {
                final cubit = context.read<PrayerTimesCubit>();
                return Column(
                  children: [
                    DetailHeader(
                      title: 'مواقيت الصلاة',
                      showDivider: false,
                      actions: [
                        _LocationButton(
                          city: cubit.currentLocation.cityName,
                          onTap: _chooseLocation,
                        ),
                      ],
                    ),
                    Expanded(
                      child: switch (state) {
                        PrayerTimesLoaded() => _Timetable(state: state),
                        PrayerTimesError(:final message) => StateMessage.error(
                          message: message,
                          onRetry: cubit.init,
                        ),
                        _ => const Center(child: CircularProgressIndicator()),
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _Timetable extends StatelessWidget {
  const _Timetable({required this.state});

  final PrayerTimesLoaded state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PrayerTimesCubit>();

    return ListView(
      padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 28.h),
      children: [
        const _Countdown(),
        SizedBox(height: 16.h),
        _DayNavigator(
          date: state.selectedDate,
          isToday: state.isShowingToday,
          onPrevious: () => cubit.showAdjacentDay(-1),
          onNext: () => cubit.showAdjacentDay(1),
          onToday: cubit.showToday,
        ),
        SizedBox(height: 16.h),
        BlocSelector<PrayerNotificationsCubit, PrayerNotificationsState, bool>(
          selector: (notifications) => notifications.enabled,
          builder:
              (context, notificationsEnabled) => PrayerTimesList(
                times: state.selectedTimes,
                isToday: state.isShowingToday,
                isPastDay: state.selectedDate.isBefore(state.date),
                notificationsEnabled: notificationsEnabled,
                nextPrayerTime: state.nextPrayerTime,
              ),
        ),
        SizedBox(height: 16.h),
        const _Settings(),
      ],
    );
  }
}

/// The next-prayer card, the only part rebuilt on every tick.
class _Countdown extends StatelessWidget {
  const _Countdown();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrayerTimesCubit, PrayerTimesState>(
      buildWhen: (_, current) => current is PrayerTimesLoaded,
      builder: (context, state) {
        if (state case PrayerTimesLoaded(
          nextPrayerLabel: final label?,
          nextPrayerTime: final time?,
          remaining: final remaining?,
        )) {
          return NextPrayerCard(
            nextPrayerLabel: label,
            nextPrayerTime: time,
            remaining: remaining,
            previousPrayerLabel: state.previousPrayerLabel,
            previousPrayerTime: state.previousPrayerTime,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _LocationButton extends StatelessWidget {
  const _LocationButton({required this.city, required this.onTap});

  final String city;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ColorsManager.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.r),
        side: BorderSide(color: ColorsManager.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_on_rounded,
                size: 19.r,
                color: ColorsManager.purpleText,
              ),
              SizedBox(width: 6.w),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 110.w),
                child: Text(
                  city,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyles.labelLarge.copyWith(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Icon(Icons.expand_more_rounded, size: 18.r, color: ColorsManager.gray),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayNavigator extends StatelessWidget {
  const _DayNavigator({
    required this.date,
    required this.isToday,
    required this.onPrevious,
    required this.onNext,
    required this.onToday,
  });

  final DateTime date;
  final bool isToday;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onToday;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppIconButton(
          tooltip: 'اليوم السابق',
          icon: Icons.chevron_left_rounded,
          size: 38.r,
          onPressed: onPrevious,
        ),
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(12.r),
            onTap: isToday ? null : onToday,
            child: Column(
              children: [
                Text(
                  '${arabicWeekday(date)}، ${formatArabicHijriDate(date)}',
                  textAlign: TextAlign.center,
                  style: TextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.4,
                  ),
                ),
                Text(
                  isToday
                      ? '${formatArabicGregorianDate(date)} · اليوم'
                      : '${formatArabicGregorianDate(date)} · العودة لليوم',
                  style: TextStyles.caption.copyWith(
                    color:
                        isToday
                            ? ColorsManager.secondaryText
                            : ColorsManager.purpleText,
                    fontWeight: isToday ? FontWeight.w500 : FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        AppIconButton(
          tooltip: 'اليوم التالي',
          icon: Icons.chevron_right_rounded,
          size: 38.r,
          onPressed: onNext,
        ),
      ],
    );
  }
}

/// Prayer alerts on/off and how the times are calculated.
class _Settings extends StatelessWidget {
  const _Settings();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PrayerNotificationsCubit, PrayerNotificationsState>(
      listenWhen:
          (previous, current) =>
              current.notice != null && !identical(previous.notice, current.notice),
      listener: (context, state) {
        final notice = state.notice!;
        notice.isError
            ? showErrorSnackbar(context, notice.message)
            : showInfoSnackbar(context, notice.message);
      },
      builder: (context, state) {
        final cubit = context.read<PrayerNotificationsCubit>();
        return SettingsGroup(
          title: 'الإعدادات',
          children: [
            SettingsTile(
              icon: Icons.notifications_rounded,
              iconBackground: ColorsManager.goldSoft,
              iconColor: ColorsManager.primaryGold,
              title: 'تنبيهات الصلاة',
              subtitle: state.enabled ? 'تصلك عند دخول كل وقت' : 'معطّلة',
              onTap: state.isBusy ? null : () => cubit.toggle(!state.enabled),
              trailing: AppSwitch(
                value: state.enabled,
                semanticLabel: 'تنبيهات الصلاة',
                onChanged: state.isBusy ? null : cubit.toggle,
              ),
            ),
            const SettingsTile(
              icon: Icons.calculate_rounded,
              title: 'طريقة الحساب',
              subtitle: 'الهيئة المصرية العامة للمساحة · المذهب الشافعي',
            ),
          ],
        );
      },
    );
  }
}
