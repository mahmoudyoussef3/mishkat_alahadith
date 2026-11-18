import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/features/mini_player/presentation/logic/mini_player_placement_cubit.dart';
import 'package:mishkat_almasabih/features/mini_player/presentation/ui/mini_player.dart';

/// The mini player in a page's own bottom bar, above the bar's contents —
/// for a page whose bar the floating player would otherwise sit under.
/// While the page is on top, the floating player stands down for it.
class DockedMiniPlayer extends StatefulWidget {
  const DockedMiniPlayer({super.key, this.onOpenQuran});

  /// Overrides opening the mushaf when the Quran's player is tapped — in
  /// the mushaf itself, with the recitation's options.
  final VoidCallback? onOpenQuran;

  @override
  State<DockedMiniPlayer> createState() => _DockedMiniPlayerState();
}

class _DockedMiniPlayerState extends State<DockedMiniPlayer> {
  MiniPlayerPlacementCubit? _placement;
  Route<dynamic>? _route;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    // Absent where the app's player is not set up, as in a lone screen.
    final placement = context.read<MiniPlayerPlacementCubit?>();
    if (identical(route, _route) && identical(placement, _placement)) return;
    _undock();
    _route = route;
    _placement = placement;
    if (route != null) placement?.dock(route);
  }

  @override
  void dispose() {
    _undock();
    super.dispose();
  }

  void _undock() {
    final route = _route;
    final placement = _placement;
    if (route != null && placement != null && !placement.isClosed) {
      placement.undock(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MiniPlayer(
      navigator: () => Navigator.maybeOf(context),
      onOpenQuran: widget.onOpenQuran,
    );
  }
}
