import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/arabic_digits.dart';
import 'package:mishkat_almasabih/core/helpers/extensions.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';
import 'package:mishkat_almasabih/core/theming/app_palette_override.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/core/widgets/snackbars.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_surah.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/recitation.dart';
import 'package:mishkat_almasabih/features/quran/presentation/logic/recitation/quran_recitation_cubit.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/helpers/quran_cloud_labels.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/models/mushaf_reader_args.dart';

class QuranNowPlaying extends StatelessWidget {
  const QuranNowPlaying({
    super.key,
    required this.state,
    required this.pendingSurah,
    required this.onChooseReciter,
    required this.onPlay,
  });

  final QuranRecitationState state;
  final QuranSurah? pendingSurah;
  final VoidCallback onChooseReciter;
  final VoidCallback? onPlay;

  @override
  Widget build(BuildContext context) {
    final palette = AppPaletteOverride.of(context);
    final cubit = context.read<QuranRecitationCubit>();
    final playback = state;
    final track = playback.currentTrack;
    final active = playback is RecitationActive ? playback : null;
    final playing = active?.isPlaying ?? false;
    final loading =
        playback is RecitationPreparing || (active?.isLoading ?? false);
    final status = switch (playback) {
      RecitationIdle() => 'اختر سورة لبدء الاستماع',
      RecitationSuspended() => 'متابعة آخر تلاوة',
      RecitationPreparing() => 'جارٍ تحميل التلاوة…',
      RecitationFailure(:final message) => message,
      RecitationActive() when loading => 'جارٍ تحميل الصوت…',
      RecitationActive() => 'الآية ${toArabicDigits('${track!.ayahNumber}')}',
    };
    final title =
        track?.surahTitle ??
        (pendingSurah == null
            ? 'القرآن الكريم'
            : 'سورة ${pendingSurah!.nameArabic}');
    final direction = Directionality.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [palette.primarySoft, palette.cardBackground],
        ),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: palette.border),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(16.w, 16.h, 16.w, 10.h),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 66.r,
                  height: 66.r,
                  decoration: BoxDecoration(
                    color: palette.goldBright,
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                  child: Icon(
                    Icons.graphic_eq_rounded,
                    size: 34.r,
                    color: palette.onGoldBright,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyles.titleLarge.copyWith(
                          color: palette.primaryText,
                        ),
                      ),
                      TextButton(
                        onPressed: onChooseReciter,
                        style: TextButton.styleFrom(
                          alignment: AlignmentDirectional.centerStart,
                          padding: EdgeInsets.zero,
                        ),
                        child: Text(
                          playback.settings.reciterName,
                          style: TextStyles.titleSmall.copyWith(
                            color: palette.purpleText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (track != null)
                  IconButton(
                    tooltip: 'فتح المصحف عند الآية',
                    icon: const Icon(Icons.menu_book_rounded),
                    onPressed:
                        () => context.pushNamed(
                          Routes.mushafReader,
                          arguments: MushafReaderArgs(
                            initialPage: track.page,
                            highlightAyahId: track.ayahId,
                            surahNumber: track.surahNumber,
                          ),
                        ),
                  ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              status,
              textAlign: TextAlign.center,
              style: TextStyles.caption.copyWith(
                color:
                    playback is RecitationFailure
                        ? palette.error
                        : palette.secondaryText,
              ),
            ),
            if (active != null)
              _AyahScrubber(key: ValueKey(track!.url), cubit: cubit),
            SizedBox(height: 6.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  tooltip: 'إيقاف التلاوة',
                  onPressed: playback is RecitationIdle ? null : cubit.stop,
                  icon: const Icon(Icons.stop_rounded),
                ),
                IconButton(
                  tooltip: 'الآية السابقة',
                  onPressed: active == null || loading ? null : cubit.previous,
                  icon: Icon(previousIcon(direction)),
                ),
                IconButton.filled(
                  tooltip: switch (playback) {
                    RecitationFailure() => 'إعادة المحاولة',
                    RecitationSuspended() => 'متابعة التلاوة',
                    _ => playing ? 'إيقاف مؤقت' : 'تشغيل',
                  },
                  onPressed: onPlay,
                  iconSize: 32.r,
                  style: IconButton.styleFrom(
                    minimumSize: Size.square(58.r),
                    backgroundColor: palette.goldBright,
                    foregroundColor: palette.onGoldBright,
                  ),
                  icon:
                      loading
                          ? SizedBox.square(
                            dimension: 20.r,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                          : Icon(switch (playback) {
                            RecitationFailure() => Icons.refresh_rounded,
                            _ =>
                              playing
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                          }),
                ),
                IconButton(
                  tooltip: 'الآية التالية',
                  onPressed:
                      active?.hasNext == true && !loading ? cubit.next : null,
                  icon: Icon(nextIcon(direction)),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AyahScrubber extends StatefulWidget {
  const _AyahScrubber({super.key, required this.cubit});

  final QuranRecitationCubit cubit;

  @override
  State<_AyahScrubber> createState() => _AyahScrubberState();
}

class _AyahScrubberState extends State<_AyahScrubber> {
  late final Stream<RecitationProgress?> _progress;
  double? _dragged;

  @override
  void initState() {
    super.initState();
    _progress =
        Stream.periodic(
          const Duration(milliseconds: 200),
          (_) => widget.cubit.progress,
        ).distinct();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<RecitationProgress?>(
      stream: _progress,
      initialData: widget.cubit.progress,
      builder: (context, snapshot) {
        final live = widget.cubit.progress;
        final progress = snapshot.data?.url == live?.url ? live : null;
        final duration = progress?.duration.inMilliseconds ?? 0;
        final max = duration > 0 ? duration.toDouble() : 1.0;
        final position = (_dragged ??
                progress?.position.inMilliseconds.toDouble() ??
                0.0)
            .clamp(0.0, max);
        final elapsed = _clock(Duration(milliseconds: position.round()));
        final total = _clock(progress?.duration ?? Duration.zero);
        return Column(
          children: [
            Directionality(
              textDirection: TextDirection.ltr,
              child: Slider(
                value: position,
                max: max,
                label: elapsed,
                semanticFormatterCallback:
                    (value) =>
                        'موضع الآية ${_clock(Duration(milliseconds: value.round()))}',
                onChanged:
                    progress == null
                        ? null
                        : (value) => setState(() => _dragged = value),
                onChangeEnd:
                    progress == null
                        ? null
                        : (value) => _seek(progress.url, value),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              textDirection: TextDirection.ltr,
              children: [
                Text(
                  elapsed,
                  textDirection: TextDirection.ltr,
                  style: TextStyles.caption,
                ),
                Text(
                  total,
                  textDirection: TextDirection.ltr,
                  style: TextStyles.caption,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _seek(String url, double milliseconds) async {
    final success = await widget.cubit.seek(
      url,
      Duration(milliseconds: milliseconds.round()),
    );
    if (!mounted) return;
    setState(() => _dragged = null);
    if (!success) showErrorSnackbar(context, 'تعذر تغيير موضع التلاوة');
  }

  static String _clock(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
