import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/core/widgets/app_icon_button.dart';
import 'package:mishkat_almasabih/core/widgets/detail_header.dart';
import 'package:mishkat_almasabih/features/quran/presentation/logic/mushaf_reader/mushaf_reader_cubit.dart';
import 'package:mushaf_text/mushaf_text.dart' show toArabicNumerals;

/// The surah and juz of the page, with the reader's three quick switches:
/// tajweed colouring, the page bookmark, and the reading settings.
class MushafReaderHeader extends StatelessWidget {
  final VoidCallback onToggleTajweed;
  final VoidCallback onTogglePageBookmark;
  final VoidCallback onOpenSettings;

  const MushafReaderHeader({
    super.key,
    required this.onToggleTajweed,
    required this.onTogglePageBookmark,
    required this.onOpenSettings,
  });

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
          (context, header) => DetailHeader(
            title: header.title.isEmpty ? 'المصحف الشريف' : header.title,
            subtitle: header.subtitle,
            actions: [
              _TajweedToggle(onPressed: onToggleTajweed),
              _PageBookmarkToggle(onPressed: onTogglePageBookmark),
              AppIconButton(
                tooltip: 'إعدادات القراءة',
                icon: Icons.tune_rounded,
                onPressed: onOpenSettings,
              ),
            ],
          ),
    );
  }
}

class _TajweedToggle extends StatelessWidget {
  final VoidCallback onPressed;

  const _TajweedToggle({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<MushafReaderCubit, MushafReaderState, bool>(
      selector:
          (state) =>
              state is MushafReaderReady && state.settings.tajweedEnabled,
      builder:
          (context, enabled) => Semantics(
            toggled: enabled,
            child: AppIconButton(
              tooltip: enabled ? 'إخفاء ألوان التجويد' : 'تلوين أحكام التجويد',
              icon: enabled ? Icons.palette_rounded : Icons.palette_outlined,
              variant:
                  enabled
                      ? AppIconButtonVariant.tonal
                      : AppIconButtonVariant.outlined,
              onPressed: onPressed,
            ),
          ),
    );
  }
}

class _PageBookmarkToggle extends StatelessWidget {
  final VoidCallback onPressed;

  const _PageBookmarkToggle({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<MushafReaderCubit, MushafReaderState, bool>(
      selector: (state) => state is MushafReaderReady && state.isPageBookmarked,
      builder:
          (context, bookmarked) => Semantics(
            toggled: bookmarked,
            child: AppIconButton(
              tooltip:
                  bookmarked ? 'إزالة علامة الصفحة' : 'حفظ علامة على الصفحة',
              icon:
                  bookmarked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
              variant:
                  bookmarked
                      ? AppIconButtonVariant.tonal
                      : AppIconButtonVariant.outlined,
              onPressed: onPressed,
            ),
          ),
    );
  }
}
