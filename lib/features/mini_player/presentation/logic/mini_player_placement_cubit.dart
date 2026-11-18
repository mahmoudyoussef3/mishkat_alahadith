import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';

part 'mini_player_placement_state.dart';

/// Where the mini player goes for the route on top of the app's navigator:
/// floating over the bottom of the page, docked in the page's own bottom
/// bar, or out of the way.
///
/// Told of the route on top by a navigator observer, and of the pages that
/// dock the player by the pages themselves.
class MiniPlayerPlacementCubit extends Cubit<MiniPlayerPlacement> {
  MiniPlayerPlacementCubit() : super(const MiniPlayerPlacement.hidden());

  /// Screens shown before the app proper, which nothing should cover.
  static const _clearRoutes = {Routes.splashScreen, Routes.onBoardingScreen};

  Route<dynamic>? _top;
  final Set<Route<dynamic>> _docking = {};

  /// [route] is on top of the navigator now; null once it is empty.
  void showRoute(Route<dynamic>? route) {
    _top = route;
    _update();
  }

  /// [route]'s page shows the player in its own bottom bar.
  void dock(Route<dynamic> route) {
    if (_docking.add(route)) _update();
  }

  void undock(Route<dynamic> route) {
    if (_docking.remove(route)) _update();
  }

  void _update() {
    final next = switch (_top) {
      // A sheet, dialog or menu over the page: the player would cover it.
      null || PopupRoute() => const MiniPlayerPlacement.hidden(),
      final Route<dynamic> page
          when _clearRoutes.contains(page.settings.name) =>
        const MiniPlayerPlacement.hidden(),
      final Route<dynamic> page when _docking.contains(page) =>
        MiniPlayerPlacement(spot: MiniPlayerSpot.docked, page: page.settings),
      final Route<dynamic> page => MiniPlayerPlacement(
        spot: MiniPlayerSpot.floating,
        page: page.settings,
      ),
    };
    if (next != state) emit(next);
  }
}
