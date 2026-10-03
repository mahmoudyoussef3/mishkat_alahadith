import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/notification/prayer_time_notification_scheduler.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/widgets/error_dialg.dart';
import 'package:mishkat_almasabih/features/profile/logic/cubit/cubit/user_stats_cubit.dart';
import 'package:mishkat_almasabih/features/profile/ui/widgets/profile_screen_shimmer.dart';
import 'package:mishkat_almasabih/features/profile/ui/widgets/prayer_notification_section.dart';
import 'package:mishkat_almasabih/features/profile/ui/widgets/statistics_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/routing/routes.dart';
import '../logic/cubit/profile_cubit.dart';
import 'widgets/profile_header.dart';
import 'widgets/login_prompt_section.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _token;
  bool _prayerNotificationsEnabled = false;
  bool _isPrayerNotificationBusy = false;
  bool _batteryOptimizationIgnored = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeScreen();
    });
  }

  Future<void> _initializeScreen() async {
    await Future.wait([_checkToken(), _loadPrayerNotificationState()]);
  }

  Future<void> _loadPrayerNotificationState() async {
    final results = await Future.wait([
      PrayerNotificationScheduler.isEnabled(),
      PrayerNotificationScheduler.hasBatteryOptimizationExemption(),
    ]);
    if (!mounted) return;

    setState(() {
      _prayerNotificationsEnabled = results[0];
      _batteryOptimizationIgnored = results[1];
    });
  }

  Future<void> _improvePrayerNotificationReliability() async {
    await PrayerNotificationScheduler.openBatteryOptimizationSettings();
    // The user returns from the system settings screen; re-read the state so
    // the reliability tile hides once the app has been exempted.
    await _loadPrayerNotificationState();
  }

  Future<void> _checkToken() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    final storedToken = prefs.getString('token');
    setState(() {
      _token = storedToken;
    });

    if (storedToken != null && mounted) {
      final cubit = context.read<ProfileCubit>();
      await Future.wait([
        cubit.getUserProfile(),
        context.read<UserStatsCubit>().getUserStats(),
      ]);
    }
  }

  Future<void> _onRefresh() async {
    if (_token != null && mounted) {
      await context.read<ProfileCubit>().getUserProfile();
      await context.read<UserStatsCubit>().getUserStats();
    }
  }

  Future<void> _togglePrayerNotifications(bool enabled) async {
    if (_isPrayerNotificationBusy) return;

    setState(() {
      _isPrayerNotificationBusy = true;
    });

    final result = await PrayerNotificationScheduler.setEnabled(enabled);

    if (!mounted) return;

    setState(() {
      _isPrayerNotificationBusy = false;
      if (result.success) {
        _prayerNotificationsEnabled = enabled;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        backgroundColor:
            result.success ? ColorsManager.primaryPurple : ColorsManager.error,
      ),
    );
  }

  Future<void> _refreshPrayerNotifications() async {
    if (_isPrayerNotificationBusy) return;

    setState(() {
      _isPrayerNotificationBusy = true;
    });

    final result = await PrayerNotificationScheduler.refreshSchedule();

    if (!mounted) return;

    setState(() {
      _isPrayerNotificationBusy = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        backgroundColor:
            result.success ? ColorsManager.primaryPurple : ColorsManager.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: ColorsManager.primaryPurple,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: ColorsManager.primaryBackground,
          body: BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, state) {
              return CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // Login Prompt for guests
                  if (_token == null)
                    LoginPromptSection(
                      onLoginPressed: () {
                        Navigator.pushNamed(context, Routes.loginScreen);
                      },
                    ),

                  // Profile Header for logged-in users
                  if (_token != null) _buildProfileHeader(state),

                  PrayerNotificationSection(
                    enabled: _prayerNotificationsEnabled,
                    isBusy: _isPrayerNotificationBusy,
                    showBatteryReliabilityAction:
                        _prayerNotificationsEnabled &&
                        !_batteryOptimizationIgnored,
                    onChanged: _togglePrayerNotifications,
                    onRefresh: _refreshPrayerNotifications,
                    onImproveReliability:
                        _improvePrayerNotificationReliability,
                  ),

                  if (_token != null) const StatisticsSection(),

                  if (_token != null)
                    SliverPadding(padding: EdgeInsets.only(bottom: 60.h)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ProfileState state) {
    if (state is ProfileLoading) {
      return const ProfileShimmerScreen();
    } else if (state is ProfileError) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: ErrorState(error: state.message),
        ),
      );
    } else if (state is ProfileLoaded) {
      return ProfileHeader(user: state.user);
    }
    return const SliverToBoxAdapter(child: SizedBox.shrink());
  }
}
