import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/extensions.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/widgets/screen_title_header.dart';
import 'package:mishkat_almasabih/features/authentication/session/presentation/logic/session_cubit.dart';
import 'package:mishkat_almasabih/features/authentication/session/presentation/ui/session_builder.dart';
import 'package:mishkat_almasabih/features/profile/presentation/logic/profile/profile_cubit.dart';
import 'package:mishkat_almasabih/features/profile/presentation/logic/user_stats/user_stats_cubit.dart';

import 'widgets/account_section.dart';
import 'widgets/appearance_section.dart';
import 'widgets/prayer_notification_settings_section.dart';
import 'widgets/profile_hero_card.dart';

/// "حسابي": the account card (or a sign-in invitation) followed by the
/// app's settings, which guests can use too.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAccount());
  }

  Future<void> _loadAccount() async {
    final signedIn = await context.read<SessionCubit>().checkSession();
    if (!signedIn || !mounted) return;
    await Future.wait([
      context.read<ProfileCubit>().getUserProfile(),
      context.read<UserStatsCubit>().getUserStats(),
    ]);
  }

  Future<void> _refresh() async {
    if (!context.read<SessionCubit>().isSignedIn) return;
    await Future.wait([
      context.read<ProfileCubit>().refreshProfile(),
      context.read<UserStatsCubit>().getUserStats(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: ColorsManager.secondaryBackground,
        body: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                const SliverToBoxAdapter(
                  child: ScreenTitleHeader(title: 'حسابي'),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 28.h),
                  sliver: SessionBuilder(
                    builder:
                        (context, isSignedIn) => SliverList.list(
                          children: [
                            if (isSignedIn)
                              const ProfileHeroCard()
                            else
                              GuestHeroCard(
                                onLogin:
                                    () => context.pushNamed(Routes.loginScreen),
                              ),
                            SizedBox(height: 18.h),
                            const AppearanceSection(),
                            SizedBox(height: 18.h),
                            const PrayerNotificationSettingsSection(),
                            SizedBox(height: 18.h),
                            AccountSection(isSignedIn: isSignedIn),
                          ],
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
