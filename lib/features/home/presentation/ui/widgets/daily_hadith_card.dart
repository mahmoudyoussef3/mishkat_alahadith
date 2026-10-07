import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/domain/entities/explained_hadith.dart';
import 'package:mishkat_almasabih/core/helpers/arabic_digits.dart';
import 'package:mishkat_almasabih/core/helpers/date_extensions.dart';
import 'package:mishkat_almasabih/core/helpers/extensions.dart';
import 'package:mishkat_almasabih/core/helpers/functions.dart';
import 'package:mishkat_almasabih/core/helpers/hadith_grade.dart';
import 'package:mishkat_almasabih/core/helpers/hadith_text.dart';
import 'package:mishkat_almasabih/core/notification/hadith_refresh_notifier.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';
import 'package:mishkat_almasabih/core/theming/app_palette_override.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/core/widgets/app_badge.dart';
import 'package:mishkat_almasabih/core/widgets/app_icon_button.dart';
import 'package:mishkat_almasabih/core/widgets/dashed_divider.dart';
import 'package:mishkat_almasabih/features/hadith_daily/presentation/logic/daily_hadith_cubit.dart';
import 'package:mishkat_almasabih/features/hadith_details/presentation/ui/widgets/bookmark_appbar_action.dart';
import 'package:shimmer/shimmer.dart';

/// "حديث اليوم": the day's hadith in a gold manuscript frame, with quick
/// actions and a way into its explanation.
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
          (context, state) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Rebuilt with each new hadith, so the day it counts never
              // lags behind the hadith below it.
              _SectionTitle(today: DateTime.now()),
              SizedBox(height: 10.h),
              switch (state) {
                DailyHadithSuccess(:final dailyHadithModel) => _FramedHadith(
                  hadith: dailyHadithModel,
                ),
                DailyHadithFailure() => _LoadError(onRetry: _reload),
                _ => const _FrameShimmer(),
              },
            ],
          ),
    );
  }
}

/// Title, a hairline, and [today]'s place in its month ("٧ / ٣٠").
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.today});

  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final palette = AppPaletteOverride.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2.w),
      child: Row(
        children: [
          Semantics(
            header: true,
            child: Text(
              'حديث اليوم',
              style: TextStyles.sectionTitle.copyWith(
                color: palette.primaryText,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: SizedBox(
              height: 1,
              child: ColoredBox(color: palette.mediumGray),
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            '${toArabicDigits('${today.day}')} / '
            '${toArabicDigits('${today.daysInMonth}')}',
            semanticsLabel: 'اليوم ${today.day} من ${today.daysInMonth}',
            style: TextStyles.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: palette.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}

class _FramedHadith extends StatelessWidget {
  const _FramedHadith({required this.hadith});

  final ExplainedHadith hadith;

  void _openExplanation(BuildContext context) =>
      context.pushNamed(Routes.hadithOfTheDay, arguments: hadith);

  @override
  Widget build(BuildContext context) {
    final palette = AppPaletteOverride.of(context);
    final rawText = hadith.hadeeth?.trim() ?? '';
    final text = HadithTextParts.typeset(rawText);
    final source = toArabicDigits(hadith.attribution?.trim() ?? '');
    final grade = HadithGrade.tryParse(hadith.grade);
    final innerRadius = Radius.circular(19.r);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.cardBackground,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: palette.featuredBorder),
        boxShadow: [
          BoxShadow(
            color: palette.featuredGlow,
            offset: Offset(0, 14.h),
            blurRadius: 30.r,
            spreadRadius: -22.r,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(6.r),
        child: Material(
          type: MaterialType.transparency,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(innerRadius),
              border: Border.all(color: palette.featuredInnerBorder),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0, 0.45],
                colors: [palette.featuredWash, palette.cardBackground],
              ),
            ),
            child: Column(
              children: [
                // Only the hadith opens its explanation, so a tap that just
                // misses a footer action does nothing.
                InkWell(
                  borderRadius: BorderRadius.vertical(top: innerRadius),
                  onTap: () => _openExplanation(context),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 22.h, 20.w, 14.h),
                    child: Column(
                      children: [
                        const _Ornament(),
                        SizedBox(height: 12.h),
                        Text(
                          text.isEmpty ? 'نص الحديث غير متوفر' : text,
                          textAlign: TextAlign.center,
                          maxLines: 6,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyles.readingLarge.copyWith(
                            fontSize: 23.sp,
                            fontWeight: FontWeight.w700,
                            height: 2,
                            color: palette.primaryText,
                          ),
                        ),
                        if (source.isNotEmpty || grade != null) ...[
                          SizedBox(height: 12.h),
                          _SourceLine(source: source, grade: grade),
                        ],
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
                  child: Column(
                    children: [
                      DashedDivider(color: palette.featuredBorder),
                      SizedBox(height: 12.h),
                      _FooterActions(
                        hadithId: hadith.id,
                        rawText: rawText,
                        text: text,
                        source: source,
                        onExplain: () => _openExplanation(context),
                      ),
                    ],
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

/// Save, share and copy on one side; "الشرح" on the other.
class _FooterActions extends StatelessWidget {
  const _FooterActions({
    required this.hadithId,
    required this.rawText,
    required this.text,
    required this.source,
    required this.onExplain,
  });

  final String? hadithId;

  /// The text as the API sent it, saved as is so a bookmark made here
  /// matches one made from the hadith's own screen.
  final String rawText;

  /// The text with typographic quotes, for sharing and copying.
  final String text;
  final String source;
  final VoidCallback onExplain;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        BookmarkAppBarAction(
          bookName: '',
          bookSlug: '',
          chapter: '',
          hadithNumber: '',
          bookmarkId: hadithId,
          hadithText: rawText,
          variant: AppIconButtonVariant.ghost,
          icon: Icons.bookmark_border_rounded,
          size: 38.r,
        ),
        SizedBox(width: 6.w),
        AppIconButton(
          tooltip: 'مشاركة الحديث',
          icon: Icons.share_outlined,
          variant: AppIconButtonVariant.ghost,
          size: 38.r,
          onPressed:
              text.isEmpty
                  ? null
                  : () => shareHadithAsImage(
                    context,
                    text: text,
                    source: source.isEmpty ? null : source,
                  ),
        ),
        SizedBox(width: 6.w),
        AppIconButton(
          tooltip: 'نسخ الحديث',
          icon: Icons.content_copy_outlined,
          variant: AppIconButtonVariant.ghost,
          size: 38.r,
          onPressed: text.isEmpty ? null : () => copyHadithText(context, text),
        ),
        const Spacer(),
        _ExplainButton(onPressed: onExplain),
      ],
    );
  }
}

/// "۞" between two gold hairlines.
class _Ornament extends StatelessWidget {
  const _Ornament();

  @override
  Widget build(BuildContext context) {
    final palette = AppPaletteOverride.of(context);

    return ExcludeSemantics(
      child: Row(
        children: [
          Expanded(
            child: _OrnamentLine(
              color: palette.ornament,
              towards: AlignmentDirectional.centerStart,
            ),
          ),
          SizedBox(width: 10.w),
          Text(
            '۞',
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 20.sp,
              height: 1,
              color: palette.ornamentInk,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: _OrnamentLine(
              color: palette.ornament,
              towards: AlignmentDirectional.centerEnd,
            ),
          ),
        ],
      ),
    );
  }
}

/// Hairline that is clear beside the glyph and gold at its outer end,
/// [towards].
class _OrnamentLine extends StatelessWidget {
  const _OrnamentLine({required this.color, required this.towards});

  final Color color;
  final AlignmentDirectional towards;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: -towards,
            end: towards,
            // Fades to the same hue, not to black, so the middle never greys.
            colors: [color.withValues(alpha: 0), color],
          ),
        ),
      ),
    );
  }
}

/// "رواه البخاري" with the grade beside it.
class _SourceLine extends StatelessWidget {
  const _SourceLine({required this.source, required this.grade});

  final String source;
  final HadithGrade? grade;

  @override
  Widget build(BuildContext context) {
    final palette = AppPaletteOverride.of(context);
    final grade = this.grade;
    final badge =
        grade == null
            ? null
            : AppBadge(
              label: grade.arabicLabel,
              background: palette.gradeSoft(grade),
              foreground: palette.gradeAccent(grade),
            );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (source.isNotEmpty)
          Flexible(
            child: Text(
              source,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyles.caption.copyWith(
                fontWeight: FontWeight.w600,
                color: palette.secondaryText,
              ),
            ),
          ),
        if (source.isNotEmpty && badge != null) SizedBox(width: 6.w),
        if (badge != null) badge,
      ],
    );
  }
}

/// Solid "الشرح" action that opens the hadith with its explanation.
class _ExplainButton extends StatelessWidget {
  const _ExplainButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = AppPaletteOverride.of(context);
    final radius = BorderRadius.circular(12.r);

    return Semantics(
      button: true,
      child: Material(
        color: palette.primaryPurple,
        borderRadius: radius,
        child: InkWell(
          onTap: onPressed,
          borderRadius: radius,
          child: SizedBox(
            height: 38.r,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'الشرح',
                    style: TextStyles.actionLabel.copyWith(
                      color: ColorsManager.white,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18.r,
                    color: ColorsManager.white,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FrameShimmer extends StatelessWidget {
  const _FrameShimmer();

  @override
  Widget build(BuildContext context) {
    final palette = AppPaletteOverride.of(context);

    return Shimmer.fromColors(
      baseColor: palette.shimmerBase,
      highlightColor: palette.shimmerHighlight,
      child: Container(
        height: 300.h,
        decoration: BoxDecoration(
          color: palette.shimmerBase,
          borderRadius: BorderRadius.circular(24.r),
        ),
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final palette = AppPaletteOverride.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 28.h),
      decoration: BoxDecoration(
        color: palette.cardBackground,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: palette.featuredBorder),
      ),
      child: Column(
        children: [
          Icon(Icons.cloud_off_rounded, size: 32.r, color: palette.gray),
          SizedBox(height: 10.h),
          Text(
            'تعذر تحميل حديث اليوم',
            style: TextStyles.titleSmall.copyWith(
              fontWeight: FontWeight.w700,
              color: palette.primaryText,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'تحقق من اتصالك بالإنترنت ثم حاول مرة أخرى',
            textAlign: TextAlign.center,
            style: TextStyles.caption.copyWith(color: palette.secondaryText),
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
