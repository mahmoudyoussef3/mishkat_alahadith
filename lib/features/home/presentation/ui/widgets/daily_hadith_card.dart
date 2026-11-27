import 'dart:math' as math;

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
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/core/widgets/app_badge.dart';
import 'package:mishkat_almasabih/core/widgets/app_icon_button.dart';
import 'package:mishkat_almasabih/features/hadith_daily/presentation/logic/daily_hadith_cubit.dart';
import 'package:mishkat_almasabih/features/hadith_details/presentation/ui/widgets/bookmark_appbar_action.dart';
import 'package:shimmer/shimmer.dart';

/// "حديث اليوم": the day's hadith on a parchment card marked with a faint
/// eight-pointed star, with quick actions and a way into its explanation.
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

/// Title, with [today]'s place in its month ("٧ / ٣٠") in a gold pill.
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
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                'حديث اليوم',
                style: TextStyles.sectionTitle.copyWith(
                  color: palette.primaryText,
                ),
              ),
            ),
          ),
          DecoratedBox(
            decoration: ShapeDecoration(
              color: palette.goldSoft,
              shape: const StadiumBorder(),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 12.r,
                    color: palette.goldInk,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    '${toArabicDigits('${today.day}')} / '
                    '${toArabicDigits('${today.daysInMonth}')}',
                    semanticsLabel:
                        'اليوم ${today.day} من ${today.daysInMonth}',
                    style: TextStyles.chipLabel.copyWith(
                      color: palette.goldInk,
                    ),
                  ),
                ],
              ),
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
    final radius = BorderRadius.circular(20.r);
    final starSize = 150.r;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: palette.featuredGlow,
            offset: Offset(0, 12.h),
            blurRadius: 28.r,
            spreadRadius: -20.r,
          ),
        ],
      ),
      child: Material(
        color: palette.cardBackground,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: palette.featuredBorder),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0, 0.6],
              colors: [palette.featuredWash, palette.cardBackground],
            ),
          ),
          child: Stack(
            children: [
              // A third of the star sits off the card, so it reads as a
              // watermark rather than an icon.
              PositionedDirectional(
                top: -starSize / 3,
                end: -starSize / 3,
                child: IgnorePointer(
                  child: CustomPaint(
                    size: Size.square(starSize),
                    painter: _StarPainter(
                      color: palette.ornament.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Only the hadith opens its explanation, so a tap that
                  // just misses a footer action does nothing.
                  InkWell(
                    onTap: () => _openExplanation(context),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 16.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            text.isEmpty ? 'نص الحديث غير متوفر' : text,
                            textAlign: TextAlign.start,
                            maxLines: 6,
                            // Fades the last line out instead of cutting a
                            // word with "…".
                            overflow: TextOverflow.fade,
                            style: TextStyles.readingLarge.copyWith(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w400,
                              height: 2,
                              color: palette.primaryText,
                            ),
                          ),
                          if (source.isNotEmpty || grade != null) ...[
                            SizedBox(height: 14.h),
                            _SourceLine(source: source, grade: grade),
                          ],
                        ],
                      ),
                    ),
                  ),
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: palette.featuredInnerBorder,
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(
                      10.w,
                      10.h,
                      16.w,
                      10.h,
                    ),
                    child: _FooterActions(
                      hadithId: hadith.id,
                      rawText: rawText,
                      text: text,
                      source: source,
                      onExplain: () => _openExplanation(context),
                    ),
                  ),
                ],
              ),
            ],
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
          size: 40.r,
        ),
        AppIconButton(
          tooltip: 'مشاركة الحديث',
          icon: Icons.share_outlined,
          variant: AppIconButtonVariant.ghost,
          size: 40.r,
          onPressed:
              text.isEmpty
                  ? null
                  : () => shareHadithAsImage(
                    context,
                    text: text,
                    source: source.isEmpty ? null : source,
                  ),
        ),
        AppIconButton(
          tooltip: 'نسخ الحديث',
          icon: Icons.content_copy_outlined,
          variant: AppIconButtonVariant.ghost,
          size: 40.r,
          onPressed: text.isEmpty ? null : () => copyHadithText(context, text),
        ),
        const Spacer(),
        _ExplainButton(onPressed: onExplain),
      ],
    );
  }
}

/// Outline of an eight-pointed star with a smaller one and a ring inside
/// it, drawn as hairlines.
class _StarPainter extends CustomPainter {
  const _StarPainter({required this.color});

  final Color color;

  /// Where two squares turned 45° apart cross, as a share of the radius.
  static final double _innerRatio =
      math.cos(math.pi / 4) / math.cos(math.pi / 8);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2;

    canvas
      ..drawPath(_star(center, radius), paint)
      ..drawPath(_star(center, radius * 0.6), paint)
      ..drawCircle(center, radius * 0.26, paint);
  }

  /// Star with its points on a circle of [radius].
  static Path _star(Offset center, double radius) {
    final path = Path();
    for (var vertex = 0; vertex < 16; vertex++) {
      final angle = vertex * math.pi / 8 - math.pi / 2;
      final distance = vertex.isEven ? radius : radius * _innerRatio;
      final point =
          center + Offset(math.cos(angle), math.sin(angle)) * distance;
      vertex == 0
          ? path.moveTo(point.dx, point.dy)
          : path.lineTo(point.dx, point.dy);
    }
    return path..close();
  }

  @override
  bool shouldRepaint(_StarPainter oldDelegate) => color != oldDelegate.color;
}

/// "— رواه البخاري" on one side, the grade on the other.
class _SourceLine extends StatelessWidget {
  const _SourceLine({required this.source, required this.grade});

  final String source;
  final HadithGrade? grade;

  @override
  Widget build(BuildContext context) {
    final palette = AppPaletteOverride.of(context);
    final grade = this.grade;

    return Row(
      children: [
        Expanded(
          child:
              source.isEmpty
                  ? const SizedBox.shrink()
                  : Row(
                    children: [
                      SizedBox(
                        width: 14.w,
                        height: 1.5,
                        child: ColoredBox(color: palette.ornamentInk),
                      ),
                      SizedBox(width: 8.w),
                      Flexible(
                        child: Text(
                          source,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyles.caption.copyWith(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: palette.secondaryText,
                          ),
                        ),
                      ),
                    ],
                  ),
        ),
        if (grade != null) ...[
          SizedBox(width: 8.w),
          AppBadge(
            label: grade.arabicLabel,
            // The seal vouches for authenticity, so only sahih carries it.
            icon: grade == HadithGrade.sahih ? Icons.verified_rounded : null,
            background: palette.gradeSoft(grade),
            foreground: palette.gradeAccent(grade),
          ),
        ],
      ],
    );
  }
}

/// Tonal "الشرح" action that opens the hadith with its explanation.
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
        color: palette.primarySoft,
        borderRadius: radius,
        child: InkWell(
          onTap: onPressed,
          borderRadius: radius,
          child: SizedBox(
            height: 40.r,
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(16.w, 0, 10.w, 0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'الشرح',
                    style: TextStyles.actionLabel.copyWith(
                      color: palette.purpleText,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20.r,
                    color: palette.purpleText,
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
          borderRadius: BorderRadius.circular(20.r),
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
        borderRadius: BorderRadius.circular(20.r),
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
