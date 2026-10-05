import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/arabic_digits.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/core/widgets/app_icon_button.dart';
import 'package:mishkat_almasabih/features/read_aloud/presentation/logic/read_aloud_cubit.dart';
import 'package:mishkat_almasabih/features/read_aloud/presentation/logic/read_aloud_settings_cubit.dart';
import 'package:mishkat_almasabih/features/read_aloud/presentation/ui/read_aloud_host.dart';
import 'package:mishkat_almasabih/features/read_aloud/presentation/ui/read_aloud_labels.dart';
import 'package:mishkat_almasabih/features/read_aloud/presentation/ui/read_aloud_settings_sheet.dart';

/// The bottom of a hadith screen: the reading controls while this screen
/// is reading aloud, above [below] (the screen's own bar, if any).
class ReadAloudBottomBar extends StatelessWidget {
  const ReadAloudBottomBar({super.key, this.below});

  final Widget? below;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const ReadAloudPlayer(),
        // The bar below keeps clear of the home indicator itself.
        below ?? const SafeArea(top: false, child: SizedBox(width: double.infinity)),
      ],
    );
  }
}

/// Controls of the reading this screen started: what is being read, how
/// far along, speed, settings, and play, pause and skip.
class ReadAloudPlayer extends StatelessWidget {
  const ReadAloudPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final owner = ReadAloudHost.ownerOf(context);
    final visible = context.select<ReadAloudCubit, bool>(
      (cubit) => cubit.state.ownedBy(owner) && cubit.state.isActive,
    );
    return AnimatedSize(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      alignment: Alignment.bottomCenter,
      child:
          visible
              ? const _PlayerPanel()
              : const SizedBox(width: double.infinity),
    );
  }
}

class _PlayerPanel extends StatelessWidget {
  const _PlayerPanel();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ColorsManager.cardBackground,
        border: Border(top: BorderSide(color: ColorsManager.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _ProgressLine(),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 10.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _NowReading(),
                SizedBox(height: 8.h),
                const _Transport(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressLine extends StatelessWidget {
  const _ProgressLine();

  @override
  Widget build(BuildContext context) {
    final progress = context.select<ReadAloudCubit, double>(
      (cubit) => cubit.state.progress,
    );
    return TweenAnimationBuilder<double>(
      tween: Tween(end: progress),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      builder:
          (context, value, _) => LinearProgressIndicator(
            value: value,
            minHeight: 3,
            backgroundColor: ColorsManager.lightGray,
            color: ColorsManager.primaryPurple,
            semanticsLabel: 'تقدم القراءة',
            semanticsValue: '${toArabicDigits('${(value * 100).round()}')}٪',
          ),
    );
  }
}

class _NowReading extends StatelessWidget {
  const _NowReading();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReadAloudCubit, ReadAloudState>(
      buildWhen:
          (previous, current) =>
              previous.track != current.track ||
              previous.index != current.index ||
              previous.status != current.status ||
              previous.previewing != current.previewing,
      builder: (context, state) {
        final track = state.track;
        if (track == null) return const SizedBox.shrink();
        final cubit = context.read<ReadAloudCubit>();
        final completed = state.status == ReadAloudStatus.completed;
        final position = toArabicDigits(
          '${state.index + 1} من ${track.segments.length}',
        );
        final heading =
            state.previewing
                ? 'تجربة الصوت'
                : completed
                ? 'اكتملت القراءة'
                : '${state.segment?.part.label ?? ''} · $position';

        return Row(
          children: [
            Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                color: ColorsManager.primarySoft,
                borderRadius: BorderRadius.circular(13.r),
              ),
              child: Icon(
                completed ? Icons.done_all_rounded : Icons.headphones_rounded,
                size: 21.r,
                color: ColorsManager.purpleText,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Semantics(
                liveRegion: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      heading,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyles.titleSmall.copyWith(
                        fontWeight: FontWeight.w800,
                        height: 1.4,
                      ),
                    ),
                    Text(
                      track.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyles.caption,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 6.w),
            const _SpeedChip(),
            SizedBox(width: 6.w),
            AppIconButton(
              tooltip: 'إعدادات الاستماع',
              icon: Icons.tune_rounded,
              size: 38.r,
              onPressed: () => showReadAloudSettingsSheet(context),
            ),
            SizedBox(width: 6.w),
            AppIconButton(
              tooltip: 'إنهاء الاستماع',
              icon: Icons.close_rounded,
              size: 38.r,
              onPressed: cubit.stop,
            ),
          ],
        );
      },
    );
  }
}

/// Current speed; a tap steps to the next one.
class _SpeedChip extends StatelessWidget {
  const _SpeedChip();

  @override
  Widget build(BuildContext context) {
    final rate = context.select<ReadAloudSettingsCubit, double>(
      (cubit) => cubit.state.settings.rate,
    );
    final label = speechRateLabel(rate);
    return Tooltip(
      message: 'سرعة القراءة',
      child: Semantics(
        button: true,
        label: 'سرعة القراءة $label',
        excludeSemantics: true,
        child: Material(
          color: ColorsManager.secondaryBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
            side: BorderSide(color: ColorsManager.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: context.read<ReadAloudSettingsCubit>().cycleRate,
            child: Container(
              height: 38.r,
              constraints: BoxConstraints(minWidth: 46.r),
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              alignment: Alignment.center,
              child: Text(
                label,
                style: TextStyles.chipLabel.copyWith(
                  fontWeight: FontWeight.w800,
                  color: ColorsManager.purpleText,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Transport extends StatelessWidget {
  const _Transport();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReadAloudCubit, ReadAloudState>(
      buildWhen:
          (previous, current) =>
              previous.status != current.status ||
              previous.canGoBack != current.canGoBack ||
              previous.canGoForward != current.canGoForward,
      builder: (context, state) {
        final cubit = context.read<ReadAloudCubit>();
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppIconButton(
              tooltip: 'الجزء السابق',
              size: 44.r,
              onPressed: state.canGoBack ? cubit.previous : null,
              child: const _DirectionalIcon(Icons.skip_previous_rounded),
            ),
            SizedBox(width: 20.w),
            _PlayPauseButton(status: state.status),
            SizedBox(width: 20.w),
            AppIconButton(
              tooltip: 'الجزء التالي',
              size: 44.r,
              onPressed: state.canGoForward ? cubit.next : null,
              child: const _DirectionalIcon(Icons.skip_next_rounded),
            ),
          ],
        );
      },
    );
  }
}

class _PlayPauseButton extends StatelessWidget {
  const _PlayPauseButton({required this.status});

  final ReadAloudStatus status;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ReadAloudCubit>();
    final (tooltip, icon, onPressed) = switch (status) {
      ReadAloudStatus.playing => ('إيقاف مؤقت', Icons.pause_rounded, cubit.pause),
      ReadAloudStatus.preparing => ('إيقاف مؤقت', null, cubit.pause),
      ReadAloudStatus.completed => (
        'إعادة القراءة',
        Icons.replay_rounded,
        cubit.restart,
      ),
      _ => ('متابعة', Icons.play_arrow_rounded, cubit.resume),
    };
    final size = 56.r;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: ColorsManager.primaryPurple,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: SizedBox.square(
            dimension: size,
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 160),
                child:
                    icon == null
                        ? SizedBox.square(
                          key: const ValueKey('preparing'),
                          dimension: size * 0.4,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: ColorsManager.white,
                          ),
                        )
                        : Icon(
                          icon,
                          key: ValueKey(icon),
                          size: size * 0.52,
                          color: ColorsManager.white,
                        ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Skip icons point the way the text reads: mirrored right to left.
class _DirectionalIcon extends StatelessWidget {
  const _DirectionalIcon(this.icon);

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Transform.flip(
      flipX: Directionality.of(context) == TextDirection.rtl,
      child: Icon(icon),
    );
  }
}
