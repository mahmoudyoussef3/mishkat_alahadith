import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/core/theming/app_palette_override.dart';
import 'package:mishkat_almasabih/core/theming/app_theme.dart';
import 'package:mishkat_almasabih/core/theming/mushaf_palette.dart';
import 'package:mishkat_almasabih/core/widgets/detail_header.dart';
import 'package:mishkat_almasabih/core/widgets/snackbars.dart';
import 'package:mishkat_almasabih/core/widgets/state_message.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/mushaf_reader_settings.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_metrics.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_surah.dart';
import 'package:mishkat_almasabih/features/quran/presentation/logic/mushaf_reader/mushaf_reader_cubit.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/helpers/quran_ui_helpers.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/widgets/reader/go_to_page_dialog.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/widgets/reader/mushaf_page_item.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/widgets/reader/mushaf_reader_bottom_bar.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/widgets/reader/mushaf_reader_header.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/widgets/reader/tajweed_focus_bar.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/widgets/sheets/ayah_actions_sheet.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/widgets/sheets/page_rules_sheet.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/widgets/sheets/reader_index_sheet.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/widgets/sheets/reader_settings_sheet.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/widgets/sheets/tajweed_rule_sheet.dart';
import 'package:mushaf_text/mushaf_text.dart';
import 'package:share_plus/share_plus.dart';

/// The Madinah Mushaf, page by page, read right to left.
///
/// The whole reader — page, bars, sheets and dialogs — is drawn in the
/// palette of the paper the reader chose, which may differ from the app's.
class MushafReaderScreen extends StatelessWidget {
  final int initialPage;

  const MushafReaderScreen({super.key, required this.initialPage});

  @override
  Widget build(BuildContext context) {
    // Read here, outside the override below, so it is the app's brightness.
    final appBrightness = Theme.of(context).brightness;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocBuilder<MushafReaderCubit, MushafReaderState>(
        // Only the state kind and the paper reshape the whole screen;
        // everything else is picked up by the small selectors below.
        buildWhen:
            (previous, current) =>
                previous.runtimeType != current.runtimeType ||
                (previous is MushafReaderReady &&
                    current is MushafReaderReady &&
                    previous.settings.themeMode != current.settings.themeMode),
        builder: (context, state) {
          final mode = switch (state) {
            MushafReaderReady(:final settings) => settings.themeMode,
            _ => MushafThemeMode.system,
          };
          final palette = readerPalette(mode, appBrightness);
          return AppPaletteOverride(
            palette: palette,
            child: AnnotatedRegion<SystemUiOverlayStyle>(
              value: AppTheme.systemBarsStyle(palette.brightness),
              child: switch (state) {
                MushafReaderLoading() => const _ReaderLoading(),
                MushafReaderFailure(:final message) => _ReaderFailure(
                  message: message,
                  initialPage: initialPage,
                ),
                MushafReaderReady() => _MushafReaderView(
                  initialPage: state.page,
                  surahs: state.surahs,
                  appBrightness: appBrightness,
                ),
              },
            ),
          );
        },
      ),
    );
  }
}

class _MushafReaderView extends StatefulWidget {
  final int initialPage;
  final List<QuranSurah> surahs;

  /// The app's own brightness, which automatic paper follows.
  final Brightness appBrightness;

  const _MushafReaderView({
    required this.initialPage,
    required this.surahs,
    required this.appBrightness,
  });

  @override
  State<_MushafReaderView> createState() => _MushafReaderViewState();
}

class _MushafReaderViewState extends State<_MushafReaderView> {
  late final PageController _pageController;

  MushafReaderCubit get _cubit => context.read<MushafReaderCubit>();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: QuranMetrics.clampPage(widget.initialPage) - 1,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = MushafPalette.of(AppPaletteOverride.of(context));
    return Scaffold(
      backgroundColor: colors.paper,
      bottomNavigationBar: MushafReaderBottomBar(
        surahs: widget.surahs,
        onJumpToPage: _jumpToPage,
        onOpenIndex: _openIndex,
        onGoToPage: _goToPage,
        onOpenPageRules: _openPageRules,
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            MushafReaderHeader(
              onToggleTajweed: _toggleTajweed,
              onTogglePageBookmark: _togglePageBookmark,
              onOpenSettings: _openSettings,
            ),
            Expanded(
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    // Keeps the neighbouring pages laid out, so a swipe never
                    // reveals a blank page.
                    allowImplicitScrolling: true,
                    itemCount: QuranMetrics.pageCount,
                    onPageChanged: (index) => _cubit.onPageChanged(index + 1),
                    itemBuilder:
                        (context, index) => MushafPageItem(
                          page: index + 1,
                          colors: colors,
                          onAyahTap: _onAyahTap,
                          onTajweedTap: _onTajweedTap,
                        ),
                  ),
                  const Align(
                    alignment: Alignment.bottomCenter,
                    child: TajweedFocusBar(),
                  ),
                  const _FocusBackHandler(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  int get _currentPage {
    final state = _cubit.state;
    return state is MushafReaderReady ? state.page : widget.initialPage;
  }

  void _jumpToPage(int page) {
    if (!_pageController.hasClients) return;
    _pageController.jumpToPage(QuranMetrics.clampPage(page) - 1);
  }

  // ── page taps ───────────────────────────────────────────────────────────

  Future<void> _onAyahTap(int ayahId) async {
    final cubit = _cubit;
    cubit.selectAyah(ayahId);
    final intent = await showAyahActionsSheet(
      context,
      readerCubit: cubit,
      ayahId: ayahId,
    );
    if (!mounted) return;
    cubit.clearSelection();

    switch (intent) {
      case null:
        return;
      case CopyAyahIntent(:final details):
        await Clipboard.setData(
          ClipboardData(text: formatAyahForSharing(details)),
        );
        if (mounted) showInfoSnackbar(context, 'تم نسخ الآية');
      case ShareAyahIntent(:final details):
        await SharePlus.instance.share(
          ShareParams(
            text: formatAyahForSharing(details),
            subject: 'آية من القرآن الكريم',
          ),
        );
      case ToggleAyahBookmarkIntent(:final details):
        final result = await cubit.toggleAyahBookmark(details);
        if (mounted) _showBookmarkResult(result, ayah: true);
      case FollowRuleIntent(:final ruleKey):
        await _followRule(ruleKey);
    }
  }

  Future<void> _onTajweedTap(TajweedHit hit) async {
    final follow = await showTajweedRuleSheet(
      context,
      rule: hit.rule,
      word: hit.word,
      start: hit.start,
      end: hit.end,
      canFollow: true,
    );
    if (follow == true && mounted) await _followRule(hit.rule.name);
  }

  Future<void> _followRule(String ruleKey) async {
    final following = await _cubit.followRule(ruleKey);
    if (!following && mounted) {
      showErrorSnackbar(context, 'تعذر تتبّع هذا الحكم في هذه الصفحة');
    }
  }

  // ── header ──────────────────────────────────────────────────────────────

  Future<void> _toggleTajweed() async {
    final state = _cubit.state;
    if (state is! MushafReaderReady) return;
    final saved = await _cubit.setTajweedEnabled(
      !state.settings.tajweedEnabled,
    );
    if (!saved && mounted) {
      showErrorSnackbar(
        context,
        'تعذر حفظ الإعداد، سيُطبَّق في هذه الجلسة فقط',
      );
    }
  }

  Future<void> _togglePageBookmark() async {
    final result = await _cubit.togglePageBookmark();
    if (mounted) _showBookmarkResult(result, ayah: false);
  }

  void _showBookmarkResult(BookmarkToggleResult result, {required bool ayah}) {
    final target = ayah ? 'الآية' : 'الصفحة';
    switch (result) {
      case BookmarkToggleResult.added:
        showInfoSnackbar(context, 'تم حفظ $target في العلامات');
      case BookmarkToggleResult.removed:
        showInfoSnackbar(context, 'تمت إزالة علامة $target');
      case BookmarkToggleResult.failed:
        showErrorSnackbar(context, 'تعذر تحديث العلامات، حاول مرة أخرى');
    }
  }

  Future<void> _openSettings() => showReaderSettingsSheet(
    context,
    readerCubit: _cubit,
    appBrightness: widget.appBrightness,
  );

  // ── bottom bar ──────────────────────────────────────────────────────────

  Future<void> _openIndex() async {
    final cubit = _cubit;
    final target = await showReaderIndexSheet(
      context,
      currentPage: _currentPage,
    );
    if (!mounted) return;
    // Bookmarks may have been removed from the sheet.
    await cubit.reloadBookmarks();
    if (target == null) return;
    _jumpToPage(target.page);
    final ayahId = target.ayahId;
    if (ayahId != null) cubit.selectAyah(ayahId);
  }

  Future<void> _goToPage() async {
    final page = await showGoToPageDialog(context, currentPage: _currentPage);
    if (page != null && mounted) _jumpToPage(page);
  }

  Future<void> _openPageRules() async {
    final cubit = _cubit;
    final ruleKey = await showPageRulesSheet(context, readerCubit: cubit);
    if (ruleKey != null && mounted) await _followRule(ruleKey);
  }
}

/// While a rule is being followed, back ends the walk instead of leaving the
/// mushaf.
class _FocusBackHandler extends StatelessWidget {
  const _FocusBackHandler();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<MushafReaderCubit, MushafReaderState, bool>(
      selector: (state) => state is MushafReaderReady && state.isFocusing,
      builder:
          (context, focusing) => PopScope(
            canPop: !focusing,
            onPopInvokedWithResult: (didPop, _) {
              if (!didPop) context.read<MushafReaderCubit>().clearFocus();
            },
            child: const SizedBox.shrink(),
          ),
    );
  }
}

class _ReaderLoading extends StatelessWidget {
  const _ReaderLoading();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          MushafPalette.of(AppPaletteOverride.of(context)).paper,
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _ReaderFailure extends StatelessWidget {
  final String message;
  final int initialPage;

  const _ReaderFailure({required this.message, required this.initialPage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          MushafPalette.of(AppPaletteOverride.of(context)).paper,
      body: SafeArea(
        child: Column(
          children: [
            const DetailHeader(title: 'المصحف الشريف', showDivider: false),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: StateMessage(
                    icon: Icons.menu_book_outlined,
                    title: 'تعذر فتح المصحف',
                    subtitle: message,
                    actionLabel: 'إعادة المحاولة',
                    actionIcon: Icons.refresh_rounded,
                    onAction:
                        () => context.read<MushafReaderCubit>().init(
                          initialPage: initialPage,
                        ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
