import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/mushaf_reader_settings.dart';
import 'package:mishkat_almasabih/features/quran/presentation/logic/mushaf_reader/mushaf_reader_cubit.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/helpers/quran_ui_helpers.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/widgets/reader/flowing_page_item.dart';
import 'package:mushaf_text/mushaf_text.dart';

typedef _PageView =
    ({
      bool tajweed,
      bool naturalMadd,
      String? focusRuleKey,
      int focusIndex,
      int? selectedAyahId,
    });

/// One page of the mushaf in the layout the reader chose: the printed page,
/// or its ayahs as running text at the reader's size.
class MushafPageItem extends StatelessWidget {
  final int page;
  final MushafColors colors;
  final ValueChanged<int> onAyahTap;
  final ValueChanged<TajweedHit> onTajweedTap;

  const MushafPageItem({
    super.key,
    required this.page,
    required this.colors,
    required this.onAyahTap,
    required this.onTajweedTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocSelector<MushafReaderCubit, MushafReaderState, MushafLayoutMode>(
      selector:
          (state) =>
              state is MushafReaderReady
                  ? state.settings.layoutMode
                  : MushafLayoutMode.page,
      builder:
          (context, layout) => switch (layout) {
            MushafLayoutMode.page => _PrintedPage(
              page: page,
              colors: colors,
              onAyahTap: onAyahTap,
              onTajweedTap: onTajweedTap,
            ),
            MushafLayoutMode.flowing => FlowingPageItem(
              page: page,
              colors: colors,
              onAyahTap: onAyahTap,
              onTajweedTap: onTajweedTap,
            ),
          },
    );
  }
}

/// The printed page, rebuilt only when something drawn on it changes.
///
/// [MushafPage] lays every word out again on each build, so the selector
/// keeps focus and selection changes on the current page from rebuilding its
/// neighbours.
class _PrintedPage extends StatelessWidget {
  /// Ceiling for the page's computed font size. The page sizes its text to
  /// fill the width it is given; the ceiling only matters on wide screens.
  static const double _maxFontSize = 48;

  final int page;
  final MushafColors colors;
  final ValueChanged<int> onAyahTap;
  final ValueChanged<TajweedHit> onTajweedTap;

  const _PrintedPage({
    required this.page,
    required this.colors,
    required this.onAyahTap,
    required this.onTajweedTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocSelector<MushafReaderCubit, MushafReaderState, _PageView>(
      selector: (state) {
        if (state is! MushafReaderReady) {
          return (
            tajweed: false,
            naturalMadd: false,
            focusRuleKey: null,
            focusIndex: 0,
            selectedAyahId: null,
          );
        }
        final isCurrent = state.page == page;
        return (
          tajweed: state.settings.tajweedEnabled,
          naturalMadd: state.settings.naturalMaddEnabled,
          focusRuleKey:
              isCurrent && state.isFocusing ? state.focusRuleKey : null,
          focusIndex: isCurrent ? state.focusIndex : 0,
          selectedAyahId: isCurrent ? state.selectedAyahId : null,
        );
      },
      builder: (context, view) {
        final focusKey = view.focusRuleKey;
        final selected = view.selectedAyahId;
        return Semantics(
          label: 'صفحة ${toArabicNumerals(page)} من المصحف',
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            child: MushafPage(
              page: page,
              colors: colors,
              tajweed: view.tajweed,
              tajweedNaturalMadd: view.naturalMadd,
              maxFontSize: _maxFontSize,
              focusRule: focusKey == null ? null : tajweedRuleOf(focusKey),
              focusIndex: view.focusIndex,
              highlightedAyahs: selected == null ? const <int>{} : {selected},
              onAyahTap: onAyahTap,
              onTajweedTap: onTajweedTap,
            ),
          ),
        );
      },
    );
  }
}
