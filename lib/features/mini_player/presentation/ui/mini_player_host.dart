import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/core/widgets/snackbars.dart';
import 'package:mishkat_almasabih/features/azkar/presentation/logic/azkar_audio/azkar_audio_cubit.dart';
import 'package:mishkat_almasabih/features/mini_player/presentation/logic/mini_player_placement_cubit.dart';
import 'package:mishkat_almasabih/features/mini_player/presentation/ui/mini_player.dart';
import 'package:mishkat_almasabih/features/quran/presentation/logic/recitation/quran_recitation_cubit.dart';

/// Stacked over the app's navigator: the mini player, floating at the
/// bottom of whichever page is on top while something plays, so it goes
/// with the listener from screen to screen. The pages are given room for
/// it at their bottom, as for a system bar.
///
/// It stands down for pages that dock it in their own bottom bar, for
/// sheets and dialogs opened over a page, and for the keyboard. A
/// recitation of the azkar that fails says so here, wherever the listener
/// is.
class MiniPlayerHost extends StatefulWidget {
  const MiniPlayerHost({
    super.key,
    required this.navigatorKey,
    required this.child,
  });

  /// The key of the navigator in [child], what plays is opened on.
  final GlobalKey<NavigatorState> navigatorKey;

  /// The app's navigator.
  final Widget child;

  @override
  State<MiniPlayerHost> createState() => _MiniPlayerHostState();
}

class _MiniPlayerHostState extends State<MiniPlayerHost> {
  /// How much of the bottom of the screen the floating player takes, the
  /// system's own bottom inset included.
  double _playerHeight = 0;

  void _onPlayerHeight(double height) {
    if (mounted && height != _playerHeight) {
      setState(() => _playerHeight = height);
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final keyboardOpen = media.viewInsets.bottom > 0;
    final floatingSpot = context.select<MiniPlayerPlacementCubit, bool>(
      (placement) => placement.state.spot == MiniPlayerSpot.floating,
    );
    final quranOn = context.select<QuranRecitationCubit, bool>(
      (cubit) => cubit.state is! RecitationIdle,
    );
    final azkarOn = context.select<AzkarAudioCubit, bool>(
      (cubit) => switch (cubit.state) {
        AzkarAudioActive() || AzkarAudioSuspended() => true,
        AzkarAudioIdle() || AzkarAudioFailure() => false,
      },
    );
    final floating = floatingSpot && !keyboardOpen && (quranOn || azkarOn);
    final room = floating ? _playerHeight : 0.0;
    return BlocListener<AzkarAudioCubit, AzkarAudioState>(
      listenWhen: (_, current) => current is AzkarAudioFailure,
      listener: (context, state) {
        showErrorSnackbar(context, (state as AzkarAudioFailure).message);
        context.read<AzkarAudioCubit>().dismissFailure();
      },
      // Its own overlay, for the player's tooltips: the navigator's is
      // beneath it.
      child: Overlay.wrap(
        child: Stack(
          children: [
            MediaQuery(
              data: media.copyWith(
                padding: media.padding.copyWith(
                  bottom: math.max(media.padding.bottom, room),
                ),
                viewPadding: media.viewPadding.copyWith(
                  bottom: math.max(media.viewPadding.bottom, room),
                ),
              ),
              child: widget.child,
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _HeightReporter(
                onHeight: _onPlayerHeight,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child:
                      floating
                          ? _FloatingPlayer(navigatorKey: widget.navigatorKey)
                          : const SizedBox(width: double.infinity),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatingPlayer extends StatelessWidget {
  const _FloatingPlayer({required this.navigatorKey});

  final GlobalKey<NavigatorState> navigatorKey;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 8),
        child: MiniPlayer(navigator: () => navigatorKey.currentState),
      ),
    );
  }
}

/// Tells [onHeight] how tall [child] is laid out, after each frame it
/// changes in.
class _HeightReporter extends SingleChildRenderObjectWidget {
  const _HeightReporter({required this.onHeight, super.child});

  final ValueChanged<double> onHeight;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderHeightReporter(onHeight);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderHeightReporter renderObject,
  ) => renderObject.onHeight = onHeight;
}

class _RenderHeightReporter extends RenderProxyBox {
  _RenderHeightReporter(this.onHeight);

  ValueChanged<double> onHeight;
  double? _reported;

  @override
  void performLayout() {
    super.performLayout();
    final height = size.height;
    if (height == _reported) return;
    _reported = height;
    // Not during layout: the pages are laid out again for it.
    SchedulerBinding.instance.addPostFrameCallback((_) => onHeight(height));
  }
}
