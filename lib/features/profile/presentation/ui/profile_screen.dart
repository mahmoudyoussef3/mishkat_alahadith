import 'package:flutter/material.dart';
import 'package:mishkat_almasabih/features/authentication/session/presentation/ui/session_builder.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/widgets/error_dialg.dart';
import 'package:mishkat_almasabih/features/profile/presentation/logic/user_stats/user_stats_cubit.dart';
import 'package:mishkat_almasabih/features/profile/presentation/ui/widgets/profile_screen_shimmer.dart';
import 'package:mishkat_almasabih/features/profile/presentation/ui/widgets/prayer_notification_settings_section.dart';
import 'package:mishkat_almasabih/features/profile/presentation/ui/widgets/statistics_card.dart';
import 'package:mishkat_almasabih/features/authentication/session/presentation/logic/session_cubit.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';
import '../logic/profile/profile_cubit.dart';
import 'widgets/appearance_section.dart';
import 'widgets/profile_header.dart';
import 'widgets/login_prompt_section.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeScreen();
    });
  }

  Future<void> _initializeScreen() async {
    await _checkSession();
  }

  Future<void> _checkSession() async {
    final signedIn = await context.read<SessionCubit>().checkSession();

    if (signedIn && mounted) {
      final cubit = context.read<ProfileCubit>();
      await Future.wait([
        cubit.getUserProfile(),
        context.read<UserStatsCubit>().getUserStats(),
      ]);
    }
  }

  Future<void> _onRefresh() async {
    if (mounted && context.read<SessionCubit>().isSignedIn) {
      await context.read<ProfileCubit>().getUserProfile();
      await context.read<UserStatsCubit>().getUserStats();
    }
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
                  SessionBuilder(
                    builder:
                        (context, isSignedIn) =>
                            isSignedIn
                                ? const SliverToBoxAdapter()
                                : LoginPromptSection(
                                  onLoginPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      Routes.loginScreen,
                                    );
                                  },
                                ),
                  ),

                  SessionBuilder(
                    builder:
                        (context, isSignedIn) =>
                            isSignedIn
                                ? _buildProfileHeader(state)
                                : const SliverToBoxAdapter(),
                  ),

                  const AppearanceSection(),

                  const PrayerNotificationSettingsSection(),

                  SessionBuilder(
                    builder:
                        (context, isSignedIn) =>
                            isSignedIn
                                ? const StatisticsSection()
                                : const SliverToBoxAdapter(),
                  ),

                  SessionBuilder(
                    builder:
                        (context, isSignedIn) =>
                            isSignedIn
                                ? SliverPadding(
                                  padding: EdgeInsets.only(bottom: 60.h),
                                )
                                : const SliverToBoxAdapter(),
                  ),
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
