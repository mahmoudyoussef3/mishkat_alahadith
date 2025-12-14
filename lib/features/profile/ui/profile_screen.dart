import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/widgets/error_dialg.dart';
import 'package:mishkat_almasabih/features/profile/logic/cubit/cubit/user_stats_cubit.dart';
import 'package:mishkat_almasabih/features/profile/ui/widgets/notification_system.dart';
import 'package:mishkat_almasabih/features/profile/ui/widgets/profile_screen_shimmer.dart';
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
  bool _dailyHadithNotification = true;
  bool _azkarNotification = false;
  bool _werdNotification = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeScreen();
    });
  }

  Future<void> _initializeScreen() async {
    await _checkToken();
    await _loadNotificationSettings();
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

  Future<void> _loadNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    setState(() {
      _dailyHadithNotification = prefs.getBool('daily_hadith_notification') ?? true;
      _azkarNotification = prefs.getBool('azkar_notification') ?? false;
      _werdNotification = prefs.getBool('werd_notification') ?? false;
    });
  }

  Future<void> _saveNotificationSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _onRefresh() async {
    if (_token != null && mounted) {
      await context.read<ProfileCubit>().getUserProfile();
      await context.read<UserStatsCubit>().getUserStats();
    }
  }

  void _onNotificationChanged(String key, bool value) {
    setState(() {
      switch (key) {
        case 'daily_hadith_notification':
          _dailyHadithNotification = value;
          break;
        case 'azkar_notification':
          _azkarNotification = value;
          break;
        case 'werd_notification':
          _werdNotification = value;
          break;
      }
    });
    _saveNotificationSetting(key, value);
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

                  // Notification Settings
                  NotificationSection(
                    dailyHadithNotification: _dailyHadithNotification,
                    azkarNotification: _azkarNotification,
                    werdNotification: _werdNotification,
                    onNotificationChanged: _onNotificationChanged,
                  ),

                  // Statistics Section
                  if (_token != null) const StatisticsSection(),

                  // Bottom Padding
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