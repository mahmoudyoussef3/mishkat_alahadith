part of 'mini_player_placement_cubit.dart';

enum MiniPlayerSpot {
  /// Over the bottom of the page, which makes room for it.
  floating,

  /// In the page's own bottom bar, which shows it itself.
  docked,

  /// Out of the way: of a sheet or dialog, or a screen before the app's own.
  hidden,
}

@immutable
final class MiniPlayerPlacement {
  final MiniPlayerSpot spot;

  /// The page on top, to tell whether opening what plays would open it
  /// again; null while it is [MiniPlayerSpot.hidden].
  final RouteSettings? page;

  const MiniPlayerPlacement({required this.spot, this.page});

  const MiniPlayerPlacement.hidden()
    : spot = MiniPlayerSpot.hidden,
      page = null;

  @override
  bool operator ==(Object other) =>
      other is MiniPlayerPlacement &&
      other.spot == spot &&
      identical(other.page, page);

  @override
  int get hashCode => Object.hash(spot, identityHashCode(page));

  @override
  String toString() => 'MiniPlayerPlacement(${spot.name}, ${page?.name})';
}
