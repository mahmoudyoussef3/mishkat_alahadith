import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/app_palette_override.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/core/widgets/app_icon_button.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_metrics.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_surah.dart';
import 'package:mishkat_almasabih/features/quran/presentation/logic/mushaf_reader/mushaf_reader_cubit.dart';
import 'package:mushaf_text/mushaf_text.dart' show toArabicNumerals;

/// Index, page scrubber, page number and the page's rules — the ways to move
/// around the mushaf, kept below the page so the page keeps its height.
class MushafReaderBottomBar extends StatelessWidget {
  final List<QuranSurah> surahs;
  final ValueChanged<int> onJumpToPage;
  final VoidCallback onOpenIndex;
  final VoidCallback onGoToPage;
  final VoidCallback onOpenPageRules;

  const MushafReaderBottomBar({
    super.key,
    required this.surahs,
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
              Expanded(
                child: _PageSlider(surahs: surahs, onJumpToPage: onJumpToPage),
              ),
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

/// Scrubs through all 604 pages, naming the surah under the thumb, and only
/// turns the page when the thumb is let go.
class _PageSlider extends StatefulWidget {
  final List<QuranSurah> surahs;
  final ValueChanged<int> onJumpToPage;

  const _PageSlider({required this.surahs, required this.onJumpToPage});

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
    final palette = AppPaletteOverride.of(context);
    // The bubble over the thumb is drawn like the theme's tooltips.
    final (bubble, onBubble) =
        palette.isDark
            ? (palette.elevatedSurface, palette.primaryText)
            : (palette.primaryText, palette.cardBackground);

    return BlocSelector<MushafReaderCubit, MushafReaderState, int>(
      selector:
          (state) =>
              state is MushafReaderReady ? state.page : QuranMetrics.firstPage,
      builder: (context, page) {
        final value = _dragValue ?? page.toDouble();
        return SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            activeTrackColor: palette.primaryPurple,
            inactiveTrackColor: palette.mediumGray,
            thumbColor: palette.primaryPurple,
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
