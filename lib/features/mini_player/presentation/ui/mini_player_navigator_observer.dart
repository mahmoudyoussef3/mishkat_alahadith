import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:mishkat_almasabih/features/mini_player/presentation/logic/mini_player_placement_cubit.dart';

/// Follows the route on top of the app's navigator, for the mini player to
/// make way for sheets and dialogs and for pages that dock it.
class MiniPlayerNavigatorObserver extends NavigatorObserver {
  MiniPlayerNavigatorObserver(this._placement);

  final MiniPlayerPlacementCubit _placement;

  /// The navigator's routes, bottom first.
  final List<Route<dynamic>> _routes = [];
  var _reportScheduled = false;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _routes.add(route);
    _report();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _routes.remove(route);
    _report();
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _routes.remove(route);
    _report();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    final index = oldRoute == null ? -1 : _routes.indexOf(oldRoute);
    if (index >= 0) {
      if (newRoute == null) {
        _routes.removeAt(index);
      } else {
        _routes[index] = newRoute;
      }
    } else if (newRoute != null) {
      _routes.add(newRoute);
    }
    _report();
  }

  /// The navigator tells of its routes while it builds, when the player
  /// above it must not rebuild: it is told once the frame is done.
  void _report() {
    if (_reportScheduled) return;
    _reportScheduled = true;
    SchedulerBinding.instance
      ..addPostFrameCallback((_) {
        _reportScheduled = false;
        if (!_placement.isClosed) _placement.showRoute(_routes.lastOrNull);
      })
      ..ensureVisualUpdate();
  }
}
