import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/app_palette_override.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/core/widgets/app_icon_button.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_metrics.dart';
import 'package:mishkat_almasabih/features/quran/presentation/logic/mushaf_reader/mushaf_reader_cubit.dart';
import 'package:mushaf_text/mushaf_text.dart' show toArabicNumerals;

/// Index, the surah's page scrubber, page number and the page's rules — the
/// ways to move around the mushaf, kept below the page so it keeps its height.
class MushafReaderBottomBar extends StatelessWidget {
  final ValueChanged<int> onJumpToPage;
  final VoidCallback onOpenIndex;
  final VoidCallback onGoToPage;
  final VoidCallback onOpenPageRules;

  const MushafReaderBottomBar({
    super.key,
    required this.onJumpToPage,
    required this.onOpenIndex,
    required this.onGoToPage,
    required this.onOpenPageRules,
  });

  @override
  Widget build(BuildContext context) {
    final palette = AppPaletteOverride.of(context);
    // A Material of its own, so the ink of the page chip is painted above the
    // bar rather than on the page's surface beneath it.
    return Material(
      color: palette.cardBackground,
      shape: Border(top: BorderSide(color: palette.border)),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 10.h),
          child: Row(
            children: [
              AppIconButton(
                tooltip: 'فهرس السور والأجزاء',
                icon: Icons.menu_book_rounded,
                onPressed: onOpenIndex,
              ),
              Expanded(child: _PageSlider(onJumpToPage: onJumpToPage)),
              _PageChip(onTap: onGoToPage),
              SizedBox(width: 8.w),
              AppIconButton(
                tooltip: 'أحكام التجويد في الصفحة',
                icon: Icons.auto_awesome_rounded,
                onPressed: onOpenPageRules,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Scrubs through the pages of the surah being read, and only turns the page
/// when the thumb is let go. Once the reader turns past the surah's last
/// page, the slider spans the next surah.
class _PageSlider extends StatefulWidget {
  final ValueChanged<int> onJumpToPage;

  const _PageSlider({required this.onJumpToPage});

  @override
  State<_PageSlider> createState() => _PageSliderState();
}

class _PageSliderState extends State<_PageSlider> {
  double? _dragValue;

  @override
  Widget build(BuildContext context) {
    final palette = AppPaletteOverride.of(context);
    // The bubble over the thumb is drawn like the theme's tooltips.
    final (bubble, onBubble) =
        palette.isDark
            ? (palette.elevatedSurface, palette.primaryText)
            : (palette.primaryText, palette.cardBackground);

    return BlocSelector<
      MushafReaderCubit,
      MushafReaderState,
      ({int page, String? surahName, int first, int last})
    >(
      selector: (state) {
        if (state is! MushafReaderReady) {
          return (
            page: QuranMetrics.firstPage,
            surahName: null,
            first: QuranMetrics.firstPage,
            last: QuranMetrics.pageCount,
          );
        }
        final pages = state.surahPages;
        return (
          page: state.page,
          surahName: state.readingSurah?.nameArabic,
          first: pages.first,
          last: pages.last,
        );
      },
      builder: (context, slider) {
        final first = slider.first.toDouble();
        final last = slider.last.toDouble();
        final value = (_dragValue ?? slider.page.toDouble()).clamp(first, last);
        // A surah on a single page has nothing to scrub.
        final scrubbable = last > first;
        final number = 'ص ${toArabicNumerals(value.round())}';
        final surahName = slider.surahName;
        return SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            activeTrackColor: palette.primaryPurple,
            inactiveTrackColor: palette.mediumGray,
            thumbColor: palette.primaryPurple,
            disabledActiveTrackColor: palette.mediumGray,
            disabledInactiveTrackColor: palette.mediumGray,
            disabledThumbColor: palette.gray,
            overlayColor: palette.primaryPurple.withValues(alpha: 0.12),
            tickMarkShape: SliderTickMarkShape.noTickMark,
            valueIndicatorColor: bubble,
            valueIndicatorTextStyle: TextStyles.chipLabel.copyWith(
              color: onBubble,
            ),
          ),
          // A slider takes all the height it is offered, and a bottom bar
          // is offered the whole screen.
          child: SizedBox(
            height: 44.r,
            child: Slider(
              value: value,
              min: first,
              max: last,
              divisions: scrubbable ? slider.last - slider.first : null,
              label: surahName == null ? number : '$number · $surahName',
              semanticFormatterCallback: (v) => 'الصفحة ${v.round()}',
              onChanged:
                  scrubbable ? (v) => setState(() => _dragValue = v) : null,
              onChangeEnd: (v) {
                setState(() => _dragValue = null);
                widget.onJumpToPage(v.round());
              },
            ),
          ),
        );
      },
    );
  }
}

/// The current page number; tapping it asks for a page to go to.
class _PageChip extends StatelessWidget {
  final VoidCallback onTap;

  const _PageChip({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final palette = AppPaletteOverride.of(context);
    return BlocSelector<MushafReaderCubit, MushafReaderState, int>(
      selector:
          (state) =>
              state is MushafReaderReady ? state.page : QuranMetrics.firstPage,
      builder:
          (context, page) => Semantics(
            button: true,
            label: 'الصفحة ${toArabicNumerals(page)}، الانتقال إلى صفحة',
            onTap: onTap,
            excludeSemantics: true,
            child: Tooltip(
              message: 'الانتقال إلى صفحة',
              child: Material(
                color: palette.primarySoft,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: InkWell(
                  onTap: onTap,
                  child: Container(
                    height: 42.r,
                    constraints: BoxConstraints(minWidth: 48.r),
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    alignment: Alignment.center,
                    child: Text(
                      toArabicNumerals(page),
                      style: TextStyles.titleSmall.copyWith(
                        fontWeight: FontWeight.w800,
                        color: palette.purpleText,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
    );
  }
}
