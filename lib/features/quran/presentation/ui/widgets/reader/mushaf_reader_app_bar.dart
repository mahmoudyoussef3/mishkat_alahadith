import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/core/theming/quran_styles.dart';
import 'package:mishkat_almasabih/features/quran/presentation/logic/mushaf_reader/mushaf_reader_cubit.dart';
import 'package:mushaf_text/mushaf_text.dart';

/// The surah and juz of the page, with the reader's three quick switches:
/// tajweed colouring, the page bookmark, and the reading settings.
class MushafReaderAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final MushafColors colors;
  final VoidCallback onToggleTajweed;
  final VoidCallback onTogglePageBookmark;
  final VoidCallback onOpenSettings;

  const MushafReaderAppBar({
    super.key,
    required this.colors,
    required this.onToggleTajweed,
    required this.onTogglePageBookmark,
    required this.onOpenSettings,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context) {
    final isLightPaper = colors.paper.computeLuminance() > 0.5;
    return AppBar(
      backgroundColor: colors.paper,
      foregroundColor: colors.accent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle:
          isLightPaper ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
      titleSpacing: 0,
      title: _ReaderTitle(colors: colors),
      actions: [
        _TajweedToggle(colors: colors, onPressed: onToggleTajweed),
        _PageBookmarkToggle(colors: colors, onPressed: onTogglePageBookmark),
        IconButton(
          tooltip: 'إعدادات القراءة',
          onPressed: onOpenSettings,
          icon: Icon(Icons.tune_rounded, color: colors.accent),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: ColoredBox(
          color: colors.gold.withValues(alpha: 0.5),
          child: const SizedBox(height: 1, width: double.infinity),
        ),
      ),
    );
  }
}

class _ReaderTitle extends StatelessWidget {
  final MushafColors colors;

  const _ReaderTitle({required this.colors});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      MushafReaderCubit,
      MushafReaderState,
      ({String title, String subtitle})
    >(
      selector: (state) {
        if (state is! MushafReaderReady) return (title: '', subtitle: '');
        final surah = state.headerSurah;
        final juz = state.pageInfo?.juz;
        return (
          title: surah == null ? '' : 'سورة ${surah.nameArabic}',
          subtitle: [
            if (juz != null) 'الجزء ${toArabicNumerals(juz)}',
            'الصفحة ${toArabicNumerals(state.page)}',
          ].join(' · '),
        );
      },
      builder:
          (context, header) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                header.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: QuranTextStyles.readerTitle(colors),
              ),
              Text(
                header.subtitle,
                style: QuranTextStyles.readerSubtitle(colors),
              ),
            ],
          ),
    );
  }
}

class _TajweedToggle extends StatelessWidget {
  final MushafColors colors;
  final VoidCallback onPressed;

  const _TajweedToggle({required this.colors, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<MushafReaderCubit, MushafReaderState, bool>(
      selector:
          (state) =>
              state is MushafReaderReady && state.settings.tajweedEnabled,
      builder:
          (context, enabled) => IconButton(
            tooltip: enabled ? 'إخفاء ألوان التجويد' : 'تلوين أحكام التجويد',
            isSelected: enabled,
            onPressed: onPressed,
            icon: Icon(Icons.palette_outlined, color: colors.accent),
            selectedIcon: Icon(
              Icons.palette_rounded,
              color: colors.tajweedColor(TajweedRule.idghamGhunna),
            ),
          ),
    );
  }
}

class _PageBookmarkToggle extends StatelessWidget {
  final MushafColors colors;
  final VoidCallback onPressed;

  const _PageBookmarkToggle({required this.colors, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<MushafReaderCubit, MushafReaderState, bool>(
      selector: (state) => state is MushafReaderReady && state.isPageBookmarked,
      builder:
          (context, bookmarked) => IconButton(
            tooltip: bookmarked ? 'إزالة علامة الصفحة' : 'حفظ علامة على الصفحة',
            isSelected: bookmarked,
            onPressed: onPressed,
            icon: Icon(Icons.bookmark_border_rounded, color: colors.accent),
            selectedIcon: Icon(Icons.bookmark_rounded, color: colors.gold),
          ),
    );
  }
}
