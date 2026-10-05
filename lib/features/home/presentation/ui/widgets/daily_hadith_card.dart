import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/domain/entities/explained_hadith.dart';
import 'package:mishkat_almasabih/core/helpers/extensions.dart';
import 'package:mishkat_almasabih/core/helpers/functions.dart';
import 'package:mishkat_almasabih/core/notification/hadith_refresh_notifier.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/core/widgets/app_badge.dart';
import 'package:mishkat_almasabih/core/widgets/app_icon_button.dart';
import 'package:mishkat_almasabih/features/hadith_daily/presentation/logic/daily_hadith_cubit.dart';
import 'package:shimmer/shimmer.dart';
import 'package:transparent_image/transparent_image.dart';

const _mosqueImage =
    'assets/images/moon-light-shine-through-window-into-islamic-mosque-interior.jpg';

/// Featured hadith of the day over a dimmed mosque photograph.
class HadithOfTheDayCard extends StatefulWidget {
  const HadithOfTheDayCard({super.key});

  @override
  State<HadithOfTheDayCard> createState() => _HadithOfTheDayCardState();
}

class _HadithOfTheDayCardState extends State<HadithOfTheDayCard> {
  final HadithRefreshNotifier _notifier = HadithRefreshNotifier();

  @override
  void initState() {
    super.initState();
    _notifier.addListener(_reload);
    WidgetsBinding.instance.addPostFrameCallback((_) => _reload());
  }

  @override
  void dispose() {
    _notifier.removeListener(_reload);
    super.dispose();
  }

  void _reload() {
    if (!mounted) return;
    context.read<DailyHadithCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DailyHadithCubit, DailyHadithState>(
      builder:
          (context, state) => switch (state) {
            DailyHadithSuccess(:final dailyHadithModel) => _HeroCard(
              hadith: dailyHadithModel,
            ),
            DailyHadithFailure() => _HeroError(onRetry: _reload),
            _ => const _HeroShimmer(),
          },
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.hadith});

  final ExplainedHadith hadith;

  void _open(BuildContext context) =>
      context.pushNamed(Routes.hadithOfTheDay, arguments: hadith);

  @override
  Widget build(BuildContext context) {
    final text = hadith.hadeeth ?? '';
    final source = hadith.attribution?.trim() ?? '';
    final radius = BorderRadius.circular(26.r);

    return ClipRRect(
      borderRadius: radius,
      child: ColoredBox(
        color: ColorsManager.heroBackground,
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.55,
                child: FadeInImage(
                  placeholder: MemoryImage(kTransparentImage),
                  image: const AssetImage(_mosqueImage),
                  fit: BoxFit.cover,
                  fadeInDuration: const Duration(milliseconds: 500),
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0, 0.7],
                    colors: [
                      ColorsManager.heroBackground.withValues(alpha: 0.35),
                      ColorsManager.heroBackground.withValues(alpha: 0.94),
                    ],
                  ),
                ),
              ),
            ),
            Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: () => _open(context),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: 300.h),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: EdgeInsets.all(18.r),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              AppBadge(
                                label: 'حديث اليوم',
                                icon: Icons.auto_stories_rounded,
                                background: ColorsManager.goldBright,
                                foreground: ColorsManager.onGoldBright,
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Text(
                                  source,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.end,
                                  style: TextStyles.chipLabel.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: ColorsManager.white.withValues(
                                      alpha: 0.85,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          SizedBox(height: 16.h),
                          Text(
                            text.isEmpty ? 'حديث اليوم' : text,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyles.readingLarge.copyWith(
                              height: 1.95,
                              color: ColorsManager.white,
                            ),
                          ),
                          SizedBox(height: 14.h),
                          Row(
                            children: [
                              Expanded(
                                child: _ReadButton(onTap: () => _open(context)),
                              ),
                              SizedBox(width: 8.w),
                              AppIconButton(
                                tooltip: 'مشاركة الحديث',
                                icon: Icons.share_rounded,
                                variant: AppIconButtonVariant.glass,
                                size: 46.h,
                                onPressed:
                                    text.isEmpty
                                        ? null
                                        : () => shareHadithAsImage(
                                          context,
                                          text: text,
                                        ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReadButton extends StatelessWidget {
  const _ReadButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // The hero is dark in both themes, so this button stays light.
    return Material(
      color: ColorsManager.white,
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: SizedBox(
          height: 46.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'اقرأ الحديث كاملاً',
                style: TextStyles.titleSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: ColorsManager.heroBackground,
                ),
              ),
              SizedBox(width: 4.w),
              Icon(
                Icons.chevron_right_rounded,
                size: 20.r,
                color: ColorsManager.heroBackground,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroShimmer extends StatelessWidget {
  const _HeroShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: ColorsManager.shimmerBase,
      highlightColor: ColorsManager.shimmerHighlight,
      child: Container(
        height: 300.h,
        decoration: BoxDecoration(
          color: ColorsManager.shimmerBase,
          borderRadius: BorderRadius.circular(26.r),
        ),
      ),
    );
  }
}

class _HeroError extends StatelessWidget {
  const _HeroError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 28.h),
      decoration: BoxDecoration(
        color: ColorsManager.cardBackground,
        borderRadius: BorderRadius.circular(26.r),
        border: Border.all(color: ColorsManager.border),
      ),
      child: Column(
        children: [
          Icon(Icons.cloud_off_rounded, size: 32.r, color: ColorsManager.gray),
          SizedBox(height: 10.h),
          Text(
            'تعذر تحميل حديث اليوم',
            style: TextStyles.titleSmall.copyWith(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 4.h),
          Text(
            'تحقق من اتصالك بالإنترنت ثم حاول مرة أخرى',
            textAlign: TextAlign.center,
            style: TextStyles.caption,
          ),
          SizedBox(height: 14.h),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}
