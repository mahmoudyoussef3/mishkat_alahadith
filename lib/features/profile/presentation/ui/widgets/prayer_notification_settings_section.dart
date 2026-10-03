import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/core/di/dependency_injection.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/features/prayer_times/presentation/logic/notifications/prayer_notifications_cubit.dart';

import 'prayer_notification_section.dart';

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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(notice.message),
              backgroundColor:
                  notice.isError
                      ? ColorsManager.error
                      : ColorsManager.primaryPurple,
            ),
          );
        },
        builder: (context, state) {
          final cubit = context.read<PrayerNotificationsCubit>();
          return PrayerNotificationSection(
            enabled: state.enabled,
            isBusy: state.isBusy,
            showBatteryReliabilityAction: state.showBatteryReliabilityAction,
            onChanged: cubit.toggle,
            onRefresh: cubit.refresh,
            onImproveReliability: cubit.improveReliability,
          );
        },
      ),
    );
  }
}
