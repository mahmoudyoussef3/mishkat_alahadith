import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/di/dependency_injection.dart';
import 'package:mishkat_almasabih/core/helpers/arabic_digits.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/core/widgets/app_icon_button.dart';
import 'package:mishkat_almasabih/core/widgets/hero_surface.dart';
import 'package:mishkat_almasabih/features/profile/domain/entities/user_profile.dart';
import 'package:mishkat_almasabih/features/profile/presentation/logic/edit_profile/edit_profile_cubit.dart';
import 'package:mishkat_almasabih/features/profile/presentation/logic/profile/profile_cubit.dart';
import 'package:mishkat_almasabih/features/profile/presentation/logic/user_stats/user_stats_cubit.dart';
import 'package:mishkat_almasabih/features/profile/presentation/ui/edit_profile_screen.dart';
import 'package:shimmer/shimmer.dart';

/// Light text on the night hero, in two strengths.
Color get _onHero => ColorsManager.white;
Color get _onHeroMuted => ColorsManager.white.withValues(alpha: 0.78);

/// Signed-in account card: avatar, name, email and activity counts.
class ProfileHeroCard extends StatelessWidget {
  const ProfileHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      buildWhen: (previous, current) => current is! ProfileInitial,
      builder:
          (context, state) => switch (state) {
            ProfileLoaded(:final user) => _AccountHero(user: user),
            ProfileError(:final message) => _HeroError(
              message: message,
              onRetry: context.read<ProfileCubit>().refreshProfile,
            ),
            _ => const _HeroLoading(),
          },
    );
  }
}

/// Invitation to sign in, shown in place of the account card for guests.
class GuestHeroCard extends StatelessWidget {
  const GuestHeroCard({super.key, required this.onLogin});

  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return HeroSurface(
      scrim: HeroScrim.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _AvatarFrame(
                child: Icon(
                  Icons.person_rounded,
                  size: 32.r,
                  color: ColorsManager.onGoldBright,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مرحباً بك',
                      style: TextStyles.sectionTitle.copyWith(
                        fontSize: 19.sp,
                        color: _onHero,
                      ),
                    ),
                    Text(
                      'سجّل دخولك لتحفظ الأحاديث وتنظّمها في مجموعات تصلك على كل أجهزتك.',
                      style: TextStyles.caption.copyWith(
                        fontSize: 13.sp,
                        height: 1.6,
                        color: _onHeroMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          FilledButton.icon(
            onPressed: onLogin,
            style: FilledButton.styleFrom(
              backgroundColor: ColorsManager.goldBright,
              foregroundColor: ColorsManager.onGoldBright,
              minimumSize: Size.fromHeight(46.h),
            ),
            icon: const Icon(Icons.login_rounded),
            label: const Text('تسجيل الدخول'),
          ),
        ],
      ),
    );
  }
}

class _AccountHero extends StatelessWidget {
  const _AccountHero({required this.user});

  final UserProfile user;

  Future<void> _edit(BuildContext context) async {
    final profile = context.read<ProfileCubit>();
    final updated = await Navigator.of(context).push<UserProfile>(
      MaterialPageRoute(
        builder:
            (_) => BlocProvider(
              create: (_) => getIt<EditProfileCubit>(),
              child: EditProfileScreen(userData: user),
            ),
      ),
    );
    if (updated != null && !profile.isClosed) {
      profile.applyUpdatedProfile(updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = user.username?.trim();
    final email = user.email?.trim();

    return HeroSurface(
      scrim: HeroScrim.horizontal,
      child: Column(
        children: [
          Row(
            children: [
              _Avatar(user: user),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name == null || name.isEmpty ? 'المستخدم' : name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyles.sectionTitle.copyWith(
                        fontSize: 19.sp,
                        color: _onHero,
                      ),
                    ),
                    if (email != null && email.isNotEmpty)
                      Text(
                        email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textDirection: TextDirection.ltr,
                        style: TextStyles.caption.copyWith(
                          fontSize: 13.sp,
                          color: _onHeroMuted,
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              AppIconButton(
                tooltip: 'تعديل الملف الشخصي',
                icon: Icons.edit_rounded,
                variant: AppIconButtonVariant.glass,
                onPressed: () => _edit(context),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          const _StatsStrip(),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.user});

  final UserProfile user;

  static const _defaultAvatarName = 'default-avatar';
  static const _apiBase = 'https://api.hadith-shareef.com/api';

  /// The user's own photo, or null when they still have the default one.
  String? get _photoUrl {
    final url = user.avatarUrl?.trim();
    if (url == null || url.isEmpty || url.contains(_defaultAvatarName)) {
      return null;
    }
    if (url.startsWith('http')) return url;
    if (url.startsWith('/uploads/')) return '$_apiBase$url';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final initial = Text(
      _initialOf(user.username),
      style: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 26.sp,
        fontWeight: FontWeight.w800,
        color: ColorsManager.onGoldBright,
      ),
    );
    final photo = _photoUrl;

    return _AvatarFrame(
      child:
          photo == null
              ? initial
              : Image.network(
                photo,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (_, _, _) => Center(child: initial),
              ),
    );
  }

  static String _initialOf(String? name) {
    final trimmed = name?.trim() ?? '';
    return trimmed.isEmpty ? '؟' : trimmed.characters.first.toUpperCase();
  }
}

class _AvatarFrame extends StatelessWidget {
  const _AvatarFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64.r,
      height: 64.r,
      alignment: Alignment.center,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: ColorsManager.goldBright,
        borderRadius: BorderRadius.circular(22.r),
      ),
      child: child,
    );
  }
}

/// Saved, collections, cards and searches counts in one translucent strip.
class _StatsStrip extends StatelessWidget {
  const _StatsStrip();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserStatsCubit, UserStatsState>(
      builder: (context, state) {
        final stats = state is UserStatsLoaded ? state.stats : null;
        final items = [
          ('المحفوظات', stats?.bookmarksCount),
          ('المجموعات', stats?.collectionsCount),
          ('البطاقات', stats?.cardsCount),
          ('عمليات البحث', stats?.searchesCount),
        ];

        return Container(
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 4.w),
          decoration: BoxDecoration(
            color: ColorsManager.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: ColorsManager.white.withValues(alpha: 0.16),
            ),
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  if (i > 0)
                    VerticalDivider(
                      width: 1,
                      thickness: 1,
                      color: ColorsManager.white.withValues(alpha: 0.16),
                    ),
                  Expanded(
                    child: _Stat(
                      label: items[i].$1,
                      value: items[i].$2,
                      highlight: i == items.length - 1,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, this.highlight = false});

  final String label;
  final int? value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final value = this.value;
    return Semantics(
      label: '$label: ${value ?? 'غير متاح'}',
      excludeSemantics: true,
      child: Column(
        children: [
          Text(
            value == null ? '–' : toArabicDigits('$value'),
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 18.sp,
              height: 1.3,
              fontWeight: FontWeight.w800,
              color: highlight ? ColorsManager.goldBright : _onHero,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyles.labelSmall.copyWith(
              fontWeight: FontWeight.w600,
              color: _onHeroMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroLoading extends StatelessWidget {
  const _HeroLoading();

  @override
  Widget build(BuildContext context) {
    final block = ColorsManager.white.withValues(alpha: 0.14);
    Widget bar(double width, double height) => Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: block,
        borderRadius: BorderRadius.circular(6.r),
      ),
    );

    return HeroSurface(
      scrim: HeroScrim.horizontal,
      child: Shimmer.fromColors(
        baseColor: ColorsManager.white.withValues(alpha: 0.5),
        highlightColor: ColorsManager.white,
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 64.r,
                  height: 64.r,
                  decoration: BoxDecoration(
                    color: block,
                    borderRadius: BorderRadius.circular(22.r),
                  ),
                ),
                SizedBox(width: 14.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    bar(120.w, 16.h),
                    SizedBox(height: 10.h),
                    bar(170.w, 12.h),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16.h),
            bar(double.infinity, 56.h),
          ],
        ),
      ),
    );
  }
}

class _HeroError extends StatelessWidget {
  const _HeroError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return HeroSurface(
      scrim: HeroScrim.horizontal,
      child: Row(
        children: [
          Icon(Icons.cloud_off_rounded, size: 28.r, color: _onHeroMuted),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تعذر تحميل حسابك',
                  style: TextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    color: _onHero,
                  ),
                ),
                Text(
                  message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyles.caption.copyWith(color: _onHeroMuted),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          AppIconButton(
            tooltip: 'إعادة المحاولة',
            icon: Icons.refresh_rounded,
            variant: AppIconButtonVariant.glass,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}
