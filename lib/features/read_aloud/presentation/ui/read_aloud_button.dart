import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/entities/hadith_speech_request.dart';
import 'package:mishkat_almasabih/features/read_aloud/presentation/logic/read_aloud_cubit.dart';
import 'package:mishkat_almasabih/features/read_aloud/presentation/ui/read_aloud_host.dart';

/// «استماع»: reads [request] aloud, and pauses or resumes it once started.
class ReadAloudButton extends StatelessWidget {
  const ReadAloudButton({super.key, required this.request});

  final HadithSpeechRequest request;

  @override
  Widget build(BuildContext context) {
    final owner = ReadAloudHost.ownerOf(context);
    final status = context.select<ReadAloudCubit, ReadAloudStatus?>((cubit) {
      final state = cubit.state;
      return state.ownedBy(owner) && state.track?.key == request.key
          ? state.status
          : null;
    });
    final cubit = context.read<ReadAloudCubit>();
    final busy =
        status == ReadAloudStatus.playing ||
        status == ReadAloudStatus.preparing;
    final active = busy || status == ReadAloudStatus.paused;

    final label = switch (status) {
      ReadAloudStatus.playing => 'إيقاف مؤقت',
      ReadAloudStatus.preparing => 'جارٍ التحضير',
      ReadAloudStatus.paused => 'متابعة',
      ReadAloudStatus.completed => 'إعادة',
      _ => 'استماع',
    };
    final (background, foreground) =
        active
            ? (ColorsManager.primaryPurple, ColorsManager.white)
            : (ColorsManager.primarySoft, ColorsManager.purpleText);
    final iconSize = 18.r;

    final Widget icon = switch (status) {
      ReadAloudStatus.preparing => SizedBox.square(
        dimension: iconSize - 4,
        child: CircularProgressIndicator(strokeWidth: 2, color: foreground),
      ),
      ReadAloudStatus.playing => _SoundBars(color: foreground, size: iconSize),
      ReadAloudStatus.paused => Icon(
        Icons.play_arrow_rounded,
        size: iconSize,
        color: foreground,
      ),
      ReadAloudStatus.completed => Icon(
        Icons.replay_rounded,
        size: iconSize,
        color: foreground,
      ),
      _ => Icon(Icons.headphones_rounded, size: iconSize, color: foreground),
    };

    return Semantics(
      button: true,
      label: 'الاستماع إلى الحديث',
      value: label,
      excludeSemantics: true,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(12.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: busy ? cubit.pause : () => cubit.play(owner, request),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            child: Container(
              height: 32.r,
              padding: EdgeInsets.symmetric(horizontal: 11.w),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox.square(
                    dimension: iconSize,
                    child: Center(child: icon),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    label,
                    style: TextStyles.chipLabel.copyWith(
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w700,
                      color: foreground,
                    ),
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

/// Three bars rising and falling while a hadith is being read. Still when
/// the system asks for reduced motion.
class _SoundBars extends StatefulWidget {
  const _SoundBars({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  State<_SoundBars> createState() => _SoundBarsState();
}

class _SoundBarsState extends State<_SoundBars>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            for (var i = 0; i < 3; i++) ...[
              if (i > 0) SizedBox(width: size * 0.12),
              Container(
                width: size * 0.16,
                height:
                    size *
                    (0.35 +
                        0.5 *
                            (0.5 +
                                0.5 *
                                    math.sin(
                                      (_controller.value + i / 3) * 2 * math.pi,
                                    ))),
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(size),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
