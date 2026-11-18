import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/widgets/snackbars.dart';
import 'package:mishkat_almasabih/core/widgets/state_message.dart';
import 'package:mishkat_almasabih/features/azkar/presentation/logic/azkar_reader/azkar_reader_cubit.dart';
import 'package:mishkat_almasabih/features/azkar/presentation/ui/models/azkar_reader_args.dart';
import 'package:mishkat_almasabih/features/azkar/presentation/ui/widgets/reader/azkar_chapter_intro.dart';
import 'package:mishkat_almasabih/features/azkar/presentation/ui/widgets/reader/azkar_reader_toolbar.dart';
import 'package:mishkat_almasabih/features/azkar/presentation/ui/widgets/reader/zikr_card.dart';

/// One chapter of Hisn Al-Muslim, read and counted zikr by zikr, with its
/// recitations — played on the app's mini player, which stays on with the
/// chapter closed.
class AzkarReaderScreen extends StatefulWidget {
  const AzkarReaderScreen({super.key, required this.args});

  final AzkarReaderArgs args;

  @override
  State<AzkarReaderScreen> createState() => _AzkarReaderScreenState();
}

class _AzkarReaderScreenState extends State<AzkarReaderScreen> {
  final ScrollController _scroll = ScrollController();

  /// Every card is built at once — a chapter has at most a couple of dozen
  /// azkar — so any of them can be scrolled to by its key.
  final Map<int, GlobalKey> _cardKeys = {};

  /// Back from the background, possibly on a new day with fresh counts.
  late final AppLifecycleListener _lifecycle = AppLifecycleListener(
    onResume: () {
      if (mounted) context.read<AzkarReaderCubit>().refreshProgress();
    },
  );

  @override
  void initState() {
    super.initState();
    _lifecycle;
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _scroll.dispose();
    super.dispose();
  }

  GlobalKey _keyFor(int zikrId) => _cardKeys.putIfAbsent(zikrId, GlobalKey.new);

  void _bringIntoView(int zikrId) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final card = _cardKeys[zikrId]?.currentContext;
      if (!mounted || card == null) return;
      Scrollable.ensureVisible(
        card,
        alignment: 0.04,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: ColorsManager.secondaryBackground,
        body: MultiBlocListener(
          listeners: [
            BlocListener<AzkarReaderCubit, AzkarReaderState>(
              listenWhen:
                  (previous, current) =>
                      current is AzkarReaderLoaded &&
                      current.focus != null &&
                      (previous is! AzkarReaderLoaded ||
                          previous.focus != current.focus),
              listener: (context, state) {
                final focus = (state as AzkarReaderLoaded).focus;
                if (focus != null) _bringIntoView(focus.zikrId);
              },
            ),
            BlocListener<AzkarReaderCubit, AzkarReaderState>(
              listenWhen:
                  (previous, current) =>
                      previous is AzkarReaderLoaded &&
                      current is AzkarReaderLoaded &&
                      current.failedSaves > previous.failedSaves,
              listener:
                  (context, _) => showErrorSnackbar(
                    context,
                    'تعذر الحفظ على جهازك، سيبقى التغيير ظاهراً حتى تغلق الصفحة',
                  ),
            ),
          ],
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [const AzkarReaderToolbar(), Expanded(child: _body())],
            ),
          ),
        ),
      ),
    );
  }

  Widget _body() {
    return BlocBuilder<AzkarReaderCubit, AzkarReaderState>(
      buildWhen:
          (previous, current) =>
              previous.runtimeType != current.runtimeType ||
              (previous is AzkarReaderLoaded &&
                  current is AzkarReaderLoaded &&
                  (previous.category != current.category ||
                      previous.settings != current.settings)),
      builder:
          (context, state) => switch (state) {
            AzkarReaderLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            AzkarReaderFailure(:final message) => Center(
              child: StateMessage.error(
                message: message,
                onRetry:
                    () => context.read<AzkarReaderCubit>().load(
                      widget.args.categoryId,
                      zikrId: widget.args.zikrId,
                    ),
              ),
            ),
            AzkarReaderLoaded(:final category, :final settings) =>
              SingleChildScrollView(
                controller: _scroll,
                padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AzkarChapterIntro(category: category),
                    for (final (index, zikr) in category.azkar.indexed)
                      Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: ZikrCard(
                          key: _keyFor(zikr.id),
                          category: category,
                          zikr: zikr,
                          position: index + 1,
                          settings: settings,
                        ),
                      ),
                    const AzkarCompletionCard(),
                    SizedBox(height: MediaQuery.paddingOf(context).bottom),
                  ],
                ),
              ),
          },
    );
  }
}
