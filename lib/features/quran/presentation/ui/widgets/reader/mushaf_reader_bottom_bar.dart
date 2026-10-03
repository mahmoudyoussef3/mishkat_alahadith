import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/quran_decorations.dart';
import 'package:mishkat_almasabih/core/theming/quran_styles.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_metrics.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_surah.dart';
import 'package:mishkat_almasabih/features/quran/presentation/logic/mushaf_reader/mushaf_reader_cubit.dart';
import 'package:mushaf_text/mushaf_text.dart';

/// Index, page scrubber, page number and the page's rules — the ways to move
/// around the mushaf, kept below the page so the page keeps its height.
class MushafReaderBottomBar extends StatelessWidget {
  final MushafColors colors;
  final List<QuranSurah> surahs;
  final ValueChanged<int> onJumpToPage;
  final VoidCallback onOpenIndex;
  final VoidCallback onGoToPage;
  final VoidCallback onOpenPageRules;

  const MushafReaderBottomBar({
    super.key,
    required this.colors,
    required this.surahs,
    required this.onJumpToPage,
    required this.onOpenIndex,
    required this.onGoToPage,
    required this.onOpenPageRules,
  });

  @override
  Widget build(BuildContext context) {
    // A Material of its own, so the ink of the page chip is painted above the
    // bar rather than on the page's surface beneath it.
    return Material(
      color: colors.paper,
      shape: QuranDecorations.readerBottomBarShape(colors),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Row(
            children: [
              IconButton(
                tooltip: 'فهرس السور والأجزاء',
                onPressed: onOpenIndex,
                icon: Icon(Icons.menu_book_rounded, color: colors.accent),
              ),
              Expanded(
                child: _PageSlider(
                  colors: colors,
                  surahs: surahs,
                  onJumpToPage: onJumpToPage,
                ),
              ),
              _PageChip(colors: colors, onTap: onGoToPage),
              IconButton(
                tooltip: 'أحكام التجويد في الصفحة',
                onPressed: onOpenPageRules,
                icon: Icon(Icons.auto_awesome_outlined, color: colors.accent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Scrubs through all 604 pages, naming the surah under the thumb, and only
/// turns the page when the thumb is let go.
class _PageSlider extends StatefulWidget {
  final MushafColors colors;
  final List<QuranSurah> surahs;
  final ValueChanged<int> onJumpToPage;

  const _PageSlider({
    required this.colors,
    required this.surahs,
    required this.onJumpToPage,
  });

  @override
  State<_PageSlider> createState() => _PageSliderState();
}

class _PageSliderState extends State<_PageSlider> {
  double? _dragValue;

  String _label(int page) {
    final surah = QuranSurah.openingAt(widget.surahs, page);
    final number = 'ص ${toArabicNumerals(page)}';
    return surah == null ? number : '$number · ${surah.nameArabic}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    return BlocSelector<MushafReaderCubit, MushafReaderState, int>(
      selector:
          (state) =>
              state is MushafReaderReady ? state.page : QuranMetrics.firstPage,
      builder: (context, page) {
        final value = _dragValue ?? page.toDouble();
        return SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 3,
            activeTrackColor: colors.accent,
            inactiveTrackColor: colors.gold.withValues(alpha: 0.35),
            thumbColor: colors.accent,
            overlayColor: colors.accent.withValues(alpha: 0.12),
            tickMarkShape: SliderTickMarkShape.noTickMark,
            valueIndicatorColor: colors.accent,
            valueIndicatorTextStyle: QuranTextStyles.sliderLabel(colors),
          ),
          child: Slider(
            value: value,
            min: QuranMetrics.firstPage.toDouble(),
            max: QuranMetrics.pageCount.toDouble(),
            divisions: QuranMetrics.pageCount - QuranMetrics.firstPage,
            label: _label(value.round()),
            semanticFormatterCallback: (v) => 'الصفحة ${v.round()}',
            onChanged: (v) => setState(() => _dragValue = v),
            onChangeEnd: (v) {
              setState(() => _dragValue = null);
              widget.onJumpToPage(v.round());
            },
          ),
        );
      },
    );
  }
}

class _PageChip extends StatelessWidget {
  final MushafColors colors;
  final VoidCallback onTap;

  const _PageChip({required this.colors, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<MushafReaderCubit, MushafReaderState, int>(
      selector:
          (state) =>
              state is MushafReaderReady ? state.page : QuranMetrics.firstPage,
      builder:
          (context, page) => Tooltip(
            message: 'الانتقال إلى صفحة',
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(10.r),
              child: Ink(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: QuranDecorations.pageChip(colors),
                child: Text(
                  toArabicNumerals(page),
                  style: QuranTextStyles.pageChip(colors),
                ),
              ),
            ),
          ),
    );
  }
}
