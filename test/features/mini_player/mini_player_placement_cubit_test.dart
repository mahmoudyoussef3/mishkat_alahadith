import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';
import 'package:mishkat_almasabih/features/mini_player/presentation/logic/mini_player_placement_cubit.dart';

MaterialPageRoute<void> _page(String name) => MaterialPageRoute(
  settings: RouteSettings(name: name),
  builder: (_) => const SizedBox(),
);

/// A sheet, dialog or menu, as far as the placement can tell.
class _Popup extends PopupRoute<void> {
  @override
  Color? get barrierColor => null;

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => null;

  @override
  Duration get transitionDuration => Duration.zero;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) => const SizedBox();
}

void main() {
  late MiniPlayerPlacementCubit placement;

  setUp(() => placement = MiniPlayerPlacementCubit());
  tearDown(() => placement.close());

  test('stays out of the way before any page', () {
    expect(placement.state.spot, MiniPlayerSpot.hidden);
  });

  test('floats over a page, naming it', () {
    final azkar = _page(Routes.azkarReader);

    placement.showRoute(azkar);

    expect(placement.state.spot, MiniPlayerSpot.floating);
    expect(placement.state.page, same(azkar.settings));
  });

  test('makes way for a sheet or dialog over the page', () {
    placement
      ..showRoute(_page(Routes.azkarReader))
      ..showRoute(_Popup());

    expect(placement.state.spot, MiniPlayerSpot.hidden);
  });

  test('keeps off the screens before the app proper', () {
    placement.showRoute(_page(Routes.splashScreen));
    expect(placement.state.spot, MiniPlayerSpot.hidden);

    placement.showRoute(_page(Routes.onBoardingScreen));
    expect(placement.state.spot, MiniPlayerSpot.hidden);
  });

  test('hides the mini player while the Quran player is open', () {
    placement.showRoute(_page(Routes.quranAudio));

    expect(placement.state.spot, MiniPlayerSpot.hidden);
  });

  test('is docked on a page that shows it in its own bar', () {
    final home = _page(Routes.mainNavigationScreen);

    placement
      ..dock(home)
      ..showRoute(home);

    expect(placement.state.spot, MiniPlayerSpot.docked);
  });

  test('floats again over a page pushed over a docking one', () {
    final home = _page(Routes.mainNavigationScreen);
    placement
      ..dock(home)
      ..showRoute(home)
      ..showRoute(_page(Routes.quranScreen));

    expect(placement.state.spot, MiniPlayerSpot.floating);
  });

  test('floats once the page stops docking it', () {
    final home = _page(Routes.mainNavigationScreen);
    placement
      ..dock(home)
      ..showRoute(home)
      ..undock(home);

    expect(placement.state.spot, MiniPlayerSpot.floating);
  });
}
