import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/arabic_time_format.dart';
import 'package:mishkat_almasabih/core/helpers/extensions.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/features/prayer_times/presentation/logic/prayer_times_cubit.dart';

/// Opens the prayer times screen, then reloads Home's countdown in case the
/// location was changed there.
Future<void> openPrayerTimesFromHome(BuildContext context) async {
  final cubit = context.read<PrayerTimesCubit>();
  await context.pushNamed(Routes.prayerTimesScreen);
  if (!cubit.isClosed) await cubit.init();
}

/// Gold strip with the next prayer countdown and today's Hijri date.
class HomePrayerStrip extends StatelessWidget {
  const HomePrayerStrip({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrayerTimesCubit, PrayerTimesState>(
      // The cubit ticks every second; the strip only shows minutes, and the
      // cubit moves its date at midnight.
      buildWhen:
          (previous, current) =>
              _label(previous) != _label(current) ||
              _date(previous) != _date(current),
      builder: (context, state) {
        final label = _label(state);
        final hijriDate = formatArabicHijriDate(_date(state) ?? DateTime.now());

        return Semantics(
          button: true,
          label: '$label، $hijriDate',
          excludeSemantics: true,
          child: Material(
            color: ColorsManager.goldSoft,
            borderRadius: BorderRadius.circular(16.r),
            child: InkWell(
              borderRadius: BorderRadius.circular(16.r),
              onTap: () => openPrayerTimesFromHome(context),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                child: Row(
                  children: [
                    Icon(
                      Icons.wb_twilight_rounded,
                      size: 20.r,
                      color: ColorsManager.primaryGold,
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyles.chipLabel.copyWith(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: ColorsManager.goldInk,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      hijriDate,
                      style: TextStyles.chipLabel.copyWith(
                        fontWeight: FontWeight.w600,
                        color: ColorsManager.hadithGood,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static DateTime? _date(PrayerTimesState state) =>
      state is PrayerTimesLoaded ? state.date : null;

  /// A countdown within the last hour ("صلاة العصر بعد ٤٢ دقيقة · ٣:١٢ م"),
  /// otherwise just the time, which stays short enough for one line.
  static String _label(PrayerTimesState state) {
    if (state case PrayerTimesLoaded(
      :final nextPrayerLabel?,
      :final nextPrayerTime?,
      :final remaining?,
    )) {
      final clock = formatArabicClock(nextPrayerTime);
      if (remaining > const Duration(hours: 1)) {
        return 'صلاة $nextPrayerLabel · $clock';
      }
      return 'صلاة $nextPrayerLabel بعد ${formatArabicCountdown(remaining)}'
          ' · $clock';
    }
    return 'مواقيت الصلاة';
  }
}
